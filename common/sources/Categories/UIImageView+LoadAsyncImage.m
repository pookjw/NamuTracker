//
//  UIImageView+LoadAsyncImage.m
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import "UIImageView+LoadAsyncImage.h"
#import "SpinnerView.h"
#import "DataCacheService.h"
#import <objc/runtime.h>

static int const UIImageView_LoadAsyncImage_backgroundQueue = 0;
static int const UIImageView_LoadAsyncImage_spinnerViewKey = 0;
static int const UIImageView_LoadAsyncImage_dataCacheServiceKey = 0;
static int const UIImageView_LoadAsyncImage_currentURLKey = 0;
static int const UIImageView_LoadAsyncImage_sessionTaskKey = 0;

@interface UIImageView (LoadAsyncImage)
@property (nonatomic, strong) NSOperationQueue *loadAsyncImage_backgroundQueue;
@property (nonatomic, strong) SpinnerView * _Nullable loadAsyncImage_spinnerView;
@property (nonatomic, strong) DataCacheService * _Nullable loadAsyncImage_dataCacheService;
@property (nonatomic, copy) NSURL * _Nullable loadAsyncImage_currentURL;
@property (nonatomic, strong) NSURLSessionTask * _Nullable loadAsyncImage_sessionTask;
@end

@implementation UIImageView (LoadAsyncImage)

- (void)loadAsyncImageWithURL:(NSURL *)url indicator:(BOOL)indicator completion:(UIImageViewLoadAsyncImageCompletion)completion {
    if (url == nil) return;
    
    [self configureLoadAsyncImageBackgroundQueueIfNeeded];
    [self configureLoadAsyncImageDataCacheServiceIfNeeded];
    
    __weak typeof(self) weakSelf = self;
    
    [self.loadAsyncImage_backgroundQueue addOperationWithBlock:^{
        if ([url isEqual:weakSelf.loadAsyncImage_currentURL]) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                completion(weakSelf.image, nil);
            }];
            return;
        }
        
        if (indicator) {
            // TODO: Add Indicator
        } else {
            // TODO: Remove Indicator
        }
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            weakSelf.image = nil;
        }];
        
        [weakSelf.loadAsyncImage_sessionTask cancel];
        weakSelf.loadAsyncImage_currentURL = url;
        
        NSString *identity = url.absoluteString;
        
        [weakSelf.loadAsyncImage_dataCacheService fetchDataCachesWithIdentity:identity completion:^(NSArray<DataCache *> * _Nullable dataCaches, NSError * _Nullable error) {
            [weakSelf.loadAsyncImage_backgroundQueue addOperationWithBlock:^{
                if (![url isEqual:weakSelf.loadAsyncImage_currentURL]) {
                    // TODO: Error
                    completion(nil, [NSError new]);
                }
                
                NSData * _Nullable data = dataCaches.lastObject.data;
                
                if (data) {
                    NSLog(@"Found cache!");
                    UIImage *image = [UIImage imageWithData:data];
                    [NSOperationQueue.mainQueue addOperationWithBlock:^{
                        // TODO: Remove Indicator
                        weakSelf.image = image;
                        completion(image, nil);
                    }];
                } else {
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                    request.HTTPMethod = @"GET";
                    NSURLSession *session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration];
                    NSURLSessionTask *loadAsyncImage_sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        [weakSelf.loadAsyncImage_backgroundQueue addOperationWithBlock:^{
                            weakSelf.loadAsyncImage_sessionTask = nil;
                            
                            if (![url isEqual:weakSelf.loadAsyncImage_currentURL]) {
                                // TODO: Error
                                completion(nil, [NSError new]);
                                return;
                            }
                            
                            if (error) {
                                completion(nil, error);
                                return;
                            }
                            
                            UIImage * _Nullable image = [UIImage imageWithData:data];
                            if (image == nil) {
                                // TODO: Error
                                completion(nil, [NSError new]);
                                return;
                            }
                            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                                // TODO: Remove Indicator
                                weakSelf.image = image;
                                completion(image, nil);
                            }];
                            
                            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                            [weakSelf.loadAsyncImage_dataCacheService createDataCacheWithCompletion:^(DataCache * _Nullable dataCache, NSError * _Nullable error) {
                                dataCache.identity = identity;
                                dataCache.data = data;
                                [weakSelf.loadAsyncImage_dataCacheService saveChangesWithCompletion:^(NSError * _Nullable error) {
                                    dispatch_semaphore_signal(semaphore);
                                }];
                            }];
                            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        }];
                    }];
                    
                    [loadAsyncImage_sessionTask resume];
                    [session finishTasksAndInvalidate];
                    weakSelf.loadAsyncImage_sessionTask = loadAsyncImage_sessionTask;
                }
            }];
        }];
    }];
}

- (void)cancelAsyncImage {
    __weak typeof(self) weakSelf = self;
    [self.loadAsyncImage_backgroundQueue addOperationWithBlock:^{
        [weakSelf.loadAsyncImage_sessionTask cancel];
        weakSelf.loadAsyncImage_sessionTask = nil;
    }];
}

- (NSOperationQueue *)loadAsyncImage_backgroundQueue {
    return objc_getAssociatedObject(self, &UIImageView_LoadAsyncImage_backgroundQueue);
}

- (void)setLoadAsyncImage_backgroundQueue:(NSOperationQueue *)loadAsyncImage_backgroundQueue {
    objc_setAssociatedObject(self, &UIImageView_LoadAsyncImage_backgroundQueue, loadAsyncImage_backgroundQueue, OBJC_ASSOCIATION_RETAIN);
}

- (SpinnerView *)loadAsyncImage_spinnerView {
    return objc_getAssociatedObject(self, &UIImageView_LoadAsyncImage_spinnerViewKey);
}

- (void)setLoadAsyncImage_spinnerView:(SpinnerView *)loadAsyncImage_spinnerView {
    objc_setAssociatedObject(self, &UIImageView_LoadAsyncImage_spinnerViewKey, loadAsyncImage_spinnerView, OBJC_ASSOCIATION_RETAIN);
}

- (DataCacheService *)loadAsyncImage_dataCacheService {
    return objc_getAssociatedObject(self, &UIImageView_LoadAsyncImage_dataCacheServiceKey);
}

- (void)setLoadAsyncImage_dataCacheService:(DataCacheService *)loadAsyncImage_dataCacheService {
    objc_setAssociatedObject(self, &UIImageView_LoadAsyncImage_dataCacheServiceKey, loadAsyncImage_dataCacheService, OBJC_ASSOCIATION_RETAIN);
}

- (NSURL *)loadAsyncImage_currentURL {
    return objc_getAssociatedObject(self, &UIImageView_LoadAsyncImage_currentURLKey);
}

- (void)setLoadAsyncImage_currentURL:(NSURL *)loadAsyncImage_currentURL {
    objc_setAssociatedObject(self, &UIImageView_LoadAsyncImage_currentURLKey, loadAsyncImage_currentURL, OBJC_ASSOCIATION_COPY);
}

- (NSURLSessionTask *)loadAsyncImage_sessionTask {
    return objc_getAssociatedObject(self, &UIImageView_LoadAsyncImage_sessionTaskKey);
}

- (void)setLoadAsyncImage_sessionTask:(NSURLSessionTask *)loadAsyncImage_sessionTask {
    objc_setAssociatedObject(self, &UIImageView_LoadAsyncImage_sessionTaskKey, loadAsyncImage_sessionTask, OBJC_ASSOCIATION_RETAIN);
}

- (void)configureLoadAsyncImageBackgroundQueueIfNeeded {
    NSOperationQueue *loadAsyncImage_backgroundQueue = [NSOperationQueue new];
    loadAsyncImage_backgroundQueue.qualityOfService = NSQualityOfServiceUserInitiated;
    loadAsyncImage_backgroundQueue.maxConcurrentOperationCount = 1;
    self.loadAsyncImage_backgroundQueue = loadAsyncImage_backgroundQueue;
}

- (void)configureLoadAsyncImageDataCacheServiceIfNeeded {
    DataCacheService *loadAsyncImage_dataCacheService = DataCacheService.sharedInstance;
    self.loadAsyncImage_dataCacheService = loadAsyncImage_dataCacheService;
}

@end

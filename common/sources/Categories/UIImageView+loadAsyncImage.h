//
//  UIImageView+loadAsyncImage.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UIImageViewLoadAsyncImageCompletion)(UIImage * _Nullable, NSError * _Nullable);

@interface UIImageView (LoadAsyncImage)
- (void)loadAsyncImageWithURL:(NSURL * _Nullable)url indicator:(BOOL)indicator;
- (void)loadAsyncImageWithURL:(NSURL * _Nullable)url indicator:(BOOL)indicator completion:(UIImageViewLoadAsyncImageCompletion)completion;
- (void)cancelAsyncImage;
- (void)clearLoadAsyncImageContexts;
@end

NS_ASSUME_NONNULL_END

//
//  UIImageView+LoadAsyncImage.h
//  NamuTrackerApp
//
//  Created by Jinwoo Kim on 10/17/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UIImageViewLoadAsyncImageCompletion)(UIImage * _Nullable image, NSError * _Nullable error);

@interface UIImageView (LoadAsyncImage)
- (void)loadAsyncImageWithURL:(NSURL * _Nullable)url indicator:(BOOL)indicator completion:(UIImageViewLoadAsyncImageCompletion _Nullable)completion;
- (void)cancelAsyncImage;
@end

NS_ASSUME_NONNULL_END

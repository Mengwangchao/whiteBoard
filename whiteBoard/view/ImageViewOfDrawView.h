//
//  ImageViewOfDrawView.h
//  whiteBoard
//
//  Created by Dynasty Dream on 2022/10/29.
//

#import <UIKit/UIKit.h>
#import "UpdateToMQTT.h"
NS_ASSUME_NONNULL_BEGIN
@class ImageViewOfDrawView;
@protocol ImageViewOfDrawViewDelegate <NSObject>
- (void) gestureHandler:(UIPanGestureRecognizer *)sender imageId:(int)imageId;

- (void) rotationGestureHanlder:(UIRotationGestureRecognizer *) sender;

- (void) pinchGestureHanlder:(UIPinchGestureRecognizer *) sender;

-(void)okButtonClick:(ImageViewOfDrawView *)view;
@end
@interface ImageViewOfDrawView : UIImageView
@property (nonatomic, weak) UpdateToMQTT * uploadMQTT;
@property (nonatomic) int  currentPage;
@property (nonatomic,weak) id<ImageViewOfDrawViewDelegate> imageViewOfDrawViewDelegate;
-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image imageId:(int)imageId userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt;
@end

NS_ASSUME_NONNULL_END

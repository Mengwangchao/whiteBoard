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
- (void) gestureHandler:(UIPanGestureRecognizer *)sender imageId:(int)imageId imageNum:(int)imageNum;
- (void) rotationGestureHanlder:(UIRotationGestureRecognizer *) sender imageNum:(int)imageNum;

- (void) pinchGestureHanlder:(UIPinchGestureRecognizer *) sender imageNum:(int)imageNum;

-(void)okButtonClick:(ImageViewOfDrawView *)view sender:(UIButton *)sender imageNum:(int)imageNum;
@end
@interface ImageViewOfDrawView : UIImageView
@property (nonatomic, weak) UpdateToMQTT * uploadMQTT;
@property (nonatomic) int  currentPage;
@property (nonatomic) int  imageNum;
@property (nonatomic , strong)UIButton *okButton;
@property (nonatomic,weak) id<ImageViewOfDrawViewDelegate> imageViewOfDrawViewDelegate;
-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image imageId:(int)imageId userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt;
@end

NS_ASSUME_NONNULL_END

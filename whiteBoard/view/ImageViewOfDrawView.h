//
//  ImageViewOfDrawView.h
//  whiteBoard
//
//  Created by Dynasty Dream on 2022/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ImageViewOfDrawView;
@protocol ImageViewOfDrawViewDelegate <NSObject>

-(void)okButtonClick:(ImageViewOfDrawView *)view;
@end
@interface ImageViewOfDrawView : UIImageView
@property (nonatomic,weak) id<ImageViewOfDrawViewDelegate> imageViewOfDrawViewDelegate;
-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END

//
//  DrawViewAndImageView.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/31.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "UpdateToMQTT.h"
NS_ASSUME_NONNULL_BEGIN

@interface DrawViewAndImageView : UIView
@property (nonatomic, weak) UpdateToMQTT * uploadMQTT;
@property (nonatomic) int  currentPage;
@property (nonatomic)BOOL isEraser;
- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt;
-(void)setDrawHidden:(BOOL)hidden;
-(void)addImageView:(UIImage *)image imageId:(int)imageId;
- (void)setLineColor:(UIColor *)color;
- (UIColor*)getLineColor;
-(void)addGraphical:(GraphicalState)graphical;
-(void)setLineWith:(float)lineWith;
-(void)deleteView;
@end

NS_ASSUME_NONNULL_END

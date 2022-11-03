//
//  DrawView.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <UIKit/UIKit.h>
#import "UpdateToMQTT.h"
#import "DrawBoardGraphicalModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol controlDelegate <NSObject>
-(void)addGraphicalFromDelegate:(GraphicalState)graphical;
-(void)deleteGraphical:(GraphicalState)graphical color:(UIColor *)color lineWidth:(float)lineWidth array:(NSArray *)array;

@end
@interface DrawView : UIView

@property (nonatomic, weak) UpdateToMQTT * uploadMQTT;
@property (nonatomic) int  currentPage;
@property (nonatomic)BOOL isEraser;
@property (nonatomic) BOOL imageScrolling;
@property (nonatomic,weak) id<controlDelegate> controldelegate;
- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt;
-(void)setDrawHidden:(BOOL)hidden;
- (void)setLineColor:(UIColor *)color;
-(void)addGraphical:(GraphicalState)graphical;
-(void)setLineWith:(float)lineWith;
- (UIColor*)getLineColor;
-(void)deleteView;
-(void)undoClick:(BOOL)isLine;
@end

NS_ASSUME_NONNULL_END

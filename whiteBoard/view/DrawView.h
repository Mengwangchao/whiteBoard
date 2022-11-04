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
-(void)deleteGraphical:(GraphicalState)graphical color:(UIColor *)color lineWidth:(float)lineWidth array:(NSArray *)array userId:(NSString *)userId;
-(void)deleteGraphicalNetwork:(GraphicalState)graphical color:(UIColor *)color lineWidth:(float)lineWidth array:(NSArray *)array userId:(NSString *)userId;

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
-(void)redoClick:(GraphicalState)graphicalState color:(UIColor*)color width:(float)width array:(NSArray *)array userId:(NSString *)userId;
-(void)undoNetwork:(BOOL)isLine userId:(NSString *)userId;
-(void)redoNetwork:(GraphicalState)graphical color:(UIColor*)color width:(float)width array:(NSArray *)array userId:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END

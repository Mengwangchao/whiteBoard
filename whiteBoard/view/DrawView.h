//
//  DrawView.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <UIKit/UIKit.h>
#import "UpdateToMQTT.h"
NS_ASSUME_NONNULL_BEGIN

@interface DrawView : UIView

@property (nonatomic, weak) UpdateToMQTT * uploadMQTT;
- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt;

- (void)setLineColor:(UIColor *)color;
- (UIColor*)getLineColor;
-(void)deleteView;
@end

NS_ASSUME_NONNULL_END

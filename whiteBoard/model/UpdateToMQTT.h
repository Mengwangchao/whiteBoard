//
//  UpdateToMQTT.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol UpdateToMQTTDelegate <NSObject>

-(void)getMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color;

@end

@interface UpdateToMQTT : NSObject

@property (nonatomic,strong,readonly)NSString *topic;
@property (nonatomic,weak) id<UpdateToMQTTDelegate> updateToMQTTdelegate;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithTopic:(NSString *)topic;


-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color;
-(void)closeMQTTClient;
@end

NS_ASSUME_NONNULL_END

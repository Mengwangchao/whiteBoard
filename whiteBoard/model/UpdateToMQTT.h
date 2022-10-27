//
//  UpdateToMQTT.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UpdateToMQTT : NSObject

@property (nonatomic,strong,readonly)NSString *topic;
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithTopic:(NSString *)topic;
-(void)connectMQTT : (NSString *)host port : (int) port userName:(NSString *)userName password:(NSString *)password;
-(void)sendMassage:(NSData *)msg topic:(NSString *)topic;
-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color;
@end

NS_ASSUME_NONNULL_END

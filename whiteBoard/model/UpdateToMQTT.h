//
//  UpdateToMQTT.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface UpdateToMQTT : NSObject
-(void)connectMQTT : (NSString *)host port : (int) port userName:(NSString *)userName password:(NSString *)password;
-(void)sendMassage:(NSData *)msg topic:(NSString *)topic;
@end

NS_ASSUME_NONNULL_END

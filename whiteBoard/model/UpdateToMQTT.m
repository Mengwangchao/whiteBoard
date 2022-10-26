//
//  UpdateToMQTT.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "UpdateToMQTT.h"
//#import "MQTTClient.h"
#import <UIKit/UIKit.h>
@interface UpdateToMQTT()

@end
@implementation UpdateToMQTT
-(void)connectMQTT : (NSString *)host port : (int) port userName:(NSString *)userName password:(NSString *)password{
    
//    MQTTCFSocketTransport *tranport = [[MQTTCFSocketTransport alloc]init];
//    tranport.host = host;
//    tranport.port = port;
//    MQTTSession * sesson = [[MQTTSession alloc]init];
//    sesson.transport = tranport;
//    sesson.delegate = self;
//    [sesson setUserName: userName];
//    [sesson setPassword:password];
//    [sesson connectAndWaitTimeout:5];
    
    
//    NSString *clientID =[NSString stringWithFormat:@"%@|iOS|%@",[[NSBundle mainBundle] bundleIdentifier],[UIDevice currentDevice].identifierForVendor.UUIDString];
//    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
////    transport.host = [NSString stringWithFormat:@"%@",server_ip];
////    transport.port =  9999;  // 端口号
//    NSURL *url=[NSURL URLWithString:_server_ip];
//    transport.url=url;
////    transport.path=@"ws";
//    transport.tls = YES; //  根据需要配置  YES 开起 SSL 验证 此处为单向验证 双向验证 根据SDK 提供方法直接添加
//    MQTTSession *session = [[MQTTSession alloc] init];
//    NSString *linkUserName = _userName;
//    NSString *linkPassWord = _passWord;
//    [session setUserName:linkUserName];
//    [session setClientId:clientID];
//    [session setPassword:linkPassWord];
//    [session setKeepAliveInterval:5];
//    session.transport = transport;
//    session.delegate = self;
//    [session connectAndWaitTimeout:10];
//    self.mySession = session;
//    [self.mySession connect];//self reconnect
//    [self.mySession addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil]; //添加事件监听
}
@end

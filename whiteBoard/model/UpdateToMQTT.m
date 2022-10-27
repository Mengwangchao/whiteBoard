//
//  UpdateToMQTT.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "UpdateToMQTT.h"
#import <MQTTClient/MQTTClient.h>
//#import "MQTTClient.h"
#import <UIKit/UIKit.h>
@interface UpdateToMQTT()<MQTTSessionDelegate>
@property(nonatomic,strong)MQTTSession *mySession;
//@property(nonatomic,strong)NSString *server_ip;
//@property(nonatomic,strong)NSString *userName;
//@property(nonatomic,strong)NSString *passWord;
@property(nonatomic,strong)NSMutableArray *topics;
@end
@implementation UpdateToMQTT
-(void)connectMQTT : (NSString *)host port : (int) port userName:(NSString *)userName password:(NSString *)password{
    
    
    _topics = [NSMutableArray array];
    [_topics addObject:@"saf"];
    [_topics addObject:@"agf"];
    MQTTCFSocketTransport *tranport = [[MQTTCFSocketTransport alloc]init];
    tranport.host = @"od434124.cn-shenzhen.emqx.cloud";
    tranport.port = 11753;
    self.mySession = [[MQTTSession alloc]init];
    self.mySession.transport = tranport;
    self.mySession.delegate = self;
    [self.mySession setUserName: @"emqx_user"];
    [self.mySession setPassword: @"emqx_password"];
    [self.mySession connectAndWaitTimeout:5];
    [self.mySession connect];
    [self.mySession addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//    NSString *clientID =[NSString stringWithFormat:@"%@|iOS|%@",[[NSBundle mainBundle] bundleIdentifier],[UIDevice currentDevice].identifierForVendor.UUIDString];
//    MQTTWebsocketTransport *transport = [[MQTTWebsocketTransport alloc] init];
////    transport.host = [NSString stringWithFormat:@"%@",server_ip];
////    transport.port =  9999;  // 端口号
//    NSURL *url=[NSURL URLWithString:_server_ip];
//    transport.url=url;
////    transport.path=@"ws";
//    transport.tls = YES; //  根据需要配置  YES 开起 SSL 验证 此处为单向验证 双向验证 根据SDK 提供方法直接添加
//    MQTTSession *session = [[MQTTSession alloc] init];
//    NSString *linkUserName = userName;
//    NSString *linkPassWord = password;
//    [session setUserName:linkUserName];
//    [session setClientId:clientID];
//    session
//    [session setPassword:linkPassWord];
//    [session setKeepAliveInterval:5];
//    session.transport = transport;
//    session.delegate = self;
//    [session connectAndWaitTimeout:10];
//    self.mySession = session;
//    [self.mySession connect];//self reconnect
//    [self.mySession addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil]; //添加事件监听
}
-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    if (eventCode == MQTTSessionEventConnected) {
        NSLog(@"链接MQTT 成功");
        
        // 方法 封装 可外部调用
        for (NSString *topic in _topics) {
            [session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
                if (error) {
                    NSLog(@"Subscription failed %@", error.localizedDescription);
                } else {
                    NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);
 
    //                [self send];
                }
             }];
        }
 // this is part of the block API
 
    }else if (eventCode == MQTTSessionEventConnectionRefused) {
            NSLog(@"MQTT拒绝链接");
   }else if (eventCode == MQTTSessionEventConnectionClosed){
            NSLog(@"MQTT链接关闭");
  }else if (eventCode == MQTTSessionEventConnectionError){
            NSLog(@"MQTT 链接错误");
  }else if (eventCode == MQTTSessionEventProtocolError){
            NSLog(@"MQTT 不可接受的协议");
  }else{//MQTTSessionEventConnectionClosedByBroker
            NSLog(@"MQTT链接 其他错误");
  }
   if (error) {
        NSLog(@"链接报错  -- %@",error);
   }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.mySession.status) {
        case MQTTSessionManagerStateClosed:
            NSLog(@"连接已经关闭");
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"连接正在关闭");
            break;
        case MQTTSessionManagerStateConnected:
            NSLog(@"已经连接");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"正在连接中");
            
            break;
        case MQTTSessionManagerStateError: {
            //            NSString *errorCode = self.mySession.lastErrorCode.localizedDescription;
            NSString *errorCode = self.mySession.description;
            NSLog(@"连接异常 ----- %@",errorCode);
        }
            break;
        case MQTTSessionManagerStateStarting:
            NSLog(@"开始连接");
            break;
        default:
            NSLog(@"default");
            break;
    }
}

-(void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"EasyMqttService mqtt connect success  %@",dic);
    // 做相对应的操作
}

-(void)closeMQTTClient{
    [self.mySession disconnect];
    [self.mySession unsubscribeTopics:@[@"已经订阅的主题"] unsubscribeHandler:^(NSError *error) {
        if (error) {
            NSLog(@"取消订阅失败");
        }else{
            NSLog(@"取消订阅成功");
        }
    }];
}

-(void)connectServer:(NSString *)urlString userName:(NSString *)userName passWord:(NSString *)passWord topic:(NSArray *)topics{
//    _server_ip=urlString;
//    _userName=userName;
//    _passWord=passWord;
//    _topics=topics;
//    [self websocket];
   
}
-(void)disConnectServer{
//    [_mySession closeAndWait:1];
//    self.mySession.delegate=nil;//代理
//    _mySession=nil;
////    _transport=nil;//连接服务器属性
//    _server_ip=nil;//服务器ip地址
////    _port=0;//服务器ip地址
//    _userName=nil;//用户名
//    _passWord=nil;//密码
////    _topic=nil;//单个主题订阅
//    _topics=nil;//多个主题订阅
}
-(void)sendMassage:(NSData *)msg topic:(NSString *)topic{
    
    [self.mySession publishData:msg onTopic:topic retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
        if (error) {
            NSLog(@"发送失败 - %@",error);
 
            
        }else{
            NSLog(@"发送成功");
           
            
        }
    }];
}
@end

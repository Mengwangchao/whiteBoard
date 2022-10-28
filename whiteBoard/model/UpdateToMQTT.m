//
//  UpdateToMQTT.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "UpdateToMQTT.h"
#import <MQTTClient/MQTTClient.h>
//#import "MQTTClient.h"
@interface UpdateToMQTT()<MQTTSessionDelegate>
@property(nonatomic,strong)MQTTSession *mySession;
@property(nonatomic,strong)NSMutableArray<NSString *> *topics;
@property (nonatomic,strong,readwrite)NSString *topic;
@end
@implementation UpdateToMQTT
-(instancetype)initWithTopic:(NSString *)topic{
    self = [super init];
    if (self) {
        self.topic = topic;
        self.topics = [NSMutableArray array];
        [self.topics addObject:@"touchStart"];
        [self.topics addObject:@"touchEnd"];
        [self.topics addObject:@"joinRoom"];
        [self.topics addObject:@"joinRoomReturn"];
        [self.topics addObject:@"createRoom"];
        [self.topics addObject:@"deleteRoom"];
        [self.topics addObject:@"deletePage"];
        [self.topics addObject:@"addPage"];
        self.currentPage = 1;
        self.pageCount = 1;
        [self connectMQTT];
    }
    return self;
}
-(void)connectMQTT{
    
    
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

}
-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    if (eventCode == MQTTSessionEventConnected) {
        NSLog(@"链接MQTT 成功");
        [session subscribeToTopic:self.topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
            if (error) {
                NSLog(@"Subscription failed %@", error.localizedDescription);
            } else {
                NSLog(@"Subscription sucessfull!");
                
                //                [self send];
            }
        }];
        // 方法 封装 可外部调用
        for (NSString *topic in _topics) {
            [session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
                if (error) {
                    NSLog(@"Subscription failed %@", error.localizedDescription);
                } else {
                    NSLog(@"Subscription sucessfull!");
                    
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
    __weak typeof(self) weakSelf = self;

    
    dispatch_queue_t que = dispatch_queue_create("getMessage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *pointDic = dic[@"point"];
        float x = [pointDic[@"x"] floatValue];
        float y = [pointDic[@"y"] floatValue];
        CGPoint point = CGPointMake(x, y);
        NSDictionary *colorDic = dic[@"color"];
        if(![dic[@"roomId"] isEqual:self.topic]){
            return;
        }
        if ([topic isEqual:@"touchStart"]) {
            
            if (weakSelf.updateToMQTTdelegate!=nil && [weakSelf.updateToMQTTdelegate respondsToSelector:@selector(getStartMassagePoint:userId:color:)]){
                [weakSelf.updateToMQTTdelegate getStartMassagePoint:point userId:dic[@"userId"] color:[weakSelf stringToUIColor:colorDic]];
            }
        }
        else if([topic isEqual:@"touchEnd"]){
            if (weakSelf.updateToMQTTdelegate!=nil && [weakSelf.updateToMQTTdelegate respondsToSelector:@selector(getEndMassagePoint:userId:color:)]){
                [weakSelf.updateToMQTTdelegate getEndMassagePoint:point userId:dic[@"userId"] color:[weakSelf stringToUIColor:colorDic]];
            }
        }else{
            if (weakSelf.updateToMQTTdelegate!=nil && [weakSelf.updateToMQTTdelegate respondsToSelector:@selector(getMassagePoint:userId:color:)]){
                [weakSelf.updateToMQTTdelegate getMassagePoint:point userId:dic[@"userId"] color:[weakSelf stringToUIColor:colorDic]];
            }
        }
    });
    // 做相对应的操作
}
-(UIColor *)stringToUIColor:(NSDictionary *)colorDic{
    
    float r = [colorDic[@"r"] floatValue];
    float g = [colorDic[@"g"] floatValue];
    float b = [colorDic[@"b"] floatValue];
    float a = [colorDic[@"a"] floatValue];
    return  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}
-(void)closeMQTTClient{
    [self.mySession disconnect];
    [self.mySession unsubscribeTopic:self.topic unsubscribeHandler:^(NSError *error) {
            if (error) {
                NSLog(@"取消订阅失败");
            }else{
                NSLog(@"取消订阅成功");
            }
    }];
    for (NSString *top in self.topics) {
        [self.mySession unsubscribeTopic:top unsubscribeHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"取消订阅失败");
                }else{
                    NSLog(@"取消订阅成功");
                }
        }];
    }
}

-(void)connectServer:(NSString *)urlString userName:(NSString *)userName passWord:(NSString *)passWord topic:(NSArray *)topics{
//    _server_ip=urlString;
//    _userName=userName;
//    _passWord=passWord;
//    _topics=topics;
//    [self websocket];
   
}
-(void)disConnectServer{
    [_mySession closeAndWait:1];
    self.mySession.delegate=nil;//代理
    self.updateToMQTTdelegate = nil;
    _mySession=nil;
//    _transport=nil;//连接服务器属性
//    _server_ip=nil;//服务器ip地址
//    _port=0;//服务器ip地址
//    _userName=nil;//用户名
//    _passWord=nil;//密码
    _topic=nil;//单个主题订阅
    _topics=nil;//多个主题订阅
}
-(void)sendPointMassage:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color topic:(NSString *)topic roomId:(NSString *)roomId{
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("uploadPoint", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *pointDic = [NSMutableDictionary dictionary];
        [pointDic setValue:[NSString stringWithFormat:@"%f",point.x] forKey:@"x"];
        [pointDic setValue:[NSString stringWithFormat:@"%f",point.y] forKey:@"y"];
        [dic setValue:pointDic forKey:@"point"];
        
        NSMutableDictionary *colorDic = [NSMutableDictionary dictionary];
        CGFloat cmp[4];
        [weakSelf cx_getRGBComponents:cmp forColor:color];
        NSArray *rgbaName = @[@"r",@"g",@"b",@"a"];
        for (int i = 0 ; i < 4; i++) {
            float f = cmp[i];
            [colorDic setValue:[NSString stringWithFormat:@"%f",f] forKey:rgbaName[i]];
        }
        [dic setValue:colorDic forKey:@"color"];
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.pageCount] forKey:@"pageCount"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:topic retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
         
                    
                }else{
                    NSLog(@"发送成功");
                   
                    
                }
        }];
    });
}
-(void)sendStartPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color roomId:(NSString *)roomId{
    [self sendPointMassage:point userId:userId color:color topic:@"touchStart" roomId:roomId];
}
-(void)sendEndPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color roomId:(NSString *)roomId{
    [self sendPointMassage:point userId:userId color:color topic:@"touchEnd" roomId:roomId];
}
-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color roomId:(NSString *)roomId{
    [self sendPointMassage:point userId:userId color:color topic:self.topic roomId:roomId];
}
-(void)sendJoinRoom:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("sendJoinRoom", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *pointDic = [NSMutableDictionary dictionary];
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"joinRoom" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendCreateRoom:(NSString *)roomId userId:(NSString *)userId authority :(AuthorityState) authority{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("createRoom", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *pointDic = [NSMutableDictionary dictionary];
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)authority] forKey:@"authority"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"createRoom" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendDeleteRoom:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("deleteRoom", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"deleteRoom" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendAddPageMessage:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("deleteRoom", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"addPage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}

-(void)sendDeletePageMessage:(NSString *)roomId userId:(NSString *)userId pageNum:(int)pageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("deleteRoom", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",pageNum] forKey:@"pageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"deletePage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}

//cmp 0 -> r  1 -> g  2 -> b  3 -> a
- (void)cx_getRGBComponents:(CGFloat [4])cmp forColor:(UIColor *)color {
    unsigned long int fNum = CGColorGetNumberOfComponents(color.CGColor);
    if (fNum == 4) {
        const CGFloat *resultPixel = CGColorGetComponents(color.CGColor);
        
        for (int i = 0; i < 3; i++) {
            
            cmp[i] = resultPixel[i]*255.0;
        }
        cmp[3] = resultPixel[3];
    }else{
        CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
        unsigned char resultPixel[4];
        CGContextRef ctx = CGBitmapContextCreate(&resultPixel, 1, 1, 8, 4, spaceRef, kCGImageAlphaNoneSkipLast);
        CGContextSetFillColorWithColor(ctx, [color CGColor]);
        CGContextFillRect(ctx, CGRectMake(0, 0, 1, 1));
        CGContextRelease(ctx);
        CGColorSpaceRelease(spaceRef);
        
        for (int i = 0; i < 3; i++) {
            cmp[i] = resultPixel[i];
        }
        
        cmp[3] = 1.0;
    }
    
}

@end

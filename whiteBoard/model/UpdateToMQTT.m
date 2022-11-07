//
//  UpdateToMQTT.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "UpdateToMQTT.h"
//#import <MQTTClient/MQTTClient.h>
//#import "MQTTClient.h"
@interface UpdateToMQTT()<MQTTSessionDelegate>
//@property(nonatomic,strong)MQTTSession *mySession;
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
        [self.topics addObject:@"readWriteAuthority"];
        [self.topics addObject:@"createRoom"];
        [self.topics addObject:@"deleteRoom"];
        [self.topics addObject:@"deletePage"];
        [self.topics addObject:@"addPage"];
        [self.topics addObject:@"nextPage"];
        [self.topics addObject:@"upPage"];
        [self.topics addObject:@"addImageStart"];
        [self.topics addObject:@"addImageScrolling"];
        [self.topics addObject:@"addImageEnd"];
        [self.topics addObject:@"lockImage"];
        [self.topics addObject:@"translationImage"];
        [self.topics addObject:@"rotateImage"];
        [self.topics addObject:@"zoomImage"];
        [self.topics addObject:@"undo"];
        [self.topics addObject:@"redo"];
        [self.topics addObject:@"clearAll"];
        [self.topics addObject:@"userList"];
        [self.topics addObject:@"leaveRoom"];
        self.currentPage = 1;
        self.pageCount = 1;
//        [self connectMQTT];
    }
    return self;
}
-(void)connectMQTT{
    
    
    MQTTCFSocketTransport *tranport = [[MQTTCFSocketTransport alloc]init];
    tranport.host = @"39.105.149.69";
    tranport.port = 1883;
    self.mySession = [[MQTTSession alloc]init];
    self.mySession.transport = tranport;
    self.mySession.delegate = self;
    [self.mySession setUserName: @"emqx_user"];
    [self.mySession setPassword: @"emqx_password"];
    [self.mySession connectAndWaitTimeout:5];
//    [self.mySession connect];
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
                
            }
        }];
        __weak typeof(self) weakSelf = self;
        dispatch_queue_t que = dispatch_queue_create("subscribeToTopic", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(que, ^{
        // 方法 封装 可外部调用
            for (NSString *topic in weakSelf.topics) {
                [session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
                    if (error) {
                        NSLog(@"Subscription failed %@", error.localizedDescription);
                    } else {
                        NSLog(@"Subscription sucessfull!");
                        
                    }
                }];
            }
        });
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
            
            if (weakSelf.updateToMQTTdelegate!=nil && [weakSelf.updateToMQTTdelegate respondsToSelector:@selector(getStartMassagePoint:userId:color:currentPage:graphical:lineWidth:)]){
                [weakSelf.updateToMQTTdelegate getStartMassagePoint:point userId:dic[@"userId"] color:[weakSelf stringToUIColor:colorDic] currentPage:[dic[@"currentPage"] intValue] graphical:[dic[@"graphical"] intValue] lineWidth:[dic[@"lineWidth"] floatValue]];
            }
        }
        else if([topic isEqual:@"touchEnd"]){
            if (weakSelf.updateToMQTTdelegate!=nil && [weakSelf.updateToMQTTdelegate respondsToSelector:@selector(getEndMassagePoint:userId:color:currentPage:graphical:lineWidth:)]){
                [weakSelf.updateToMQTTdelegate getEndMassagePoint:point userId:dic[@"userId"] color:[weakSelf stringToUIColor:colorDic] currentPage:[dic[@"currentPage"] intValue]  graphical:[dic[@"graphical"] intValue] lineWidth:[dic[@"lineWidth"] floatValue]];
            }
        }else if([topic isEqual:@"addPage"]){
            if (weakSelf.pageMQTTdelegate!=nil && [weakSelf.pageMQTTdelegate respondsToSelector:@selector(addPage:userId:)]){
                [weakSelf.pageMQTTdelegate addPage:dic[@"roomId"] userId:dic[@"userId"]];
            }
        }else if([topic isEqual:@"deletePage"]){
            if (weakSelf.pageMQTTdelegate!=nil && [weakSelf.pageMQTTdelegate respondsToSelector:@selector(deletePage:userId:pageNum:)]){
                [weakSelf.pageMQTTdelegate deletePage:dic[@"roomId"] userId:dic[@"userId"] pageNum:[dic[@"pageNum"] intValue]];
            }
        }
        else if([topic isEqual:@"nextPage"]){
            if (weakSelf.pageMQTTdelegate!=nil && [weakSelf.pageMQTTdelegate respondsToSelector:@selector(nextPage:userId:)]){
                [weakSelf.pageMQTTdelegate nextPage:dic[@"roomId"] userId:dic[@"userId"]];
            }
        }
        else if([topic isEqual:@"upPage"]){
            if (weakSelf.pageMQTTdelegate!=nil && [weakSelf.pageMQTTdelegate respondsToSelector:@selector(upPage:userId:)]){
                [weakSelf.pageMQTTdelegate upPage:dic[@"roomId"] userId:dic[@"userId"]];
            }
        }else if ([topic isEqual:@"addImageStart"]){
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getAddImageStart:userId:imageId:currentPage:point:imageNum:)]){
                [weakSelf.imageMQTTdelegate getAddImageStart:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] currentPage:[dic[@"currentPage"] intValue] point:point imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"addImageScrolling"]){
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getAddImageScrolling:userId:imageId:currentPage:point:imageNum:)]){
                [weakSelf.imageMQTTdelegate getAddImageScrolling:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] currentPage:[dic[@"currentPage"] intValue] point:point imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"addImageEnd"]){
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getAddImageEnd:userId:imageId:currentPage:point:imageNum:)]){
                [weakSelf.imageMQTTdelegate getAddImageEnd:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] currentPage:[dic[@"currentPage"] intValue] point:point imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"lockImage"]){
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getLockImage:userId:imageId:currentPage:imageNum:)]){
                [weakSelf.imageMQTTdelegate getLockImage:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] currentPage:[dic[@"currentPage"] intValue] imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"translationImage"]){
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getTranslationImage:userId:imageId:point:currentPage:imageNum:)]){
                [weakSelf.imageMQTTdelegate getTranslationImage:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] point:point currentPage:[dic[@"currentPage"] intValue] imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"rotateImage"]){
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getRotateImage:userId:imageId:rotate:currentPage:imageNum:)]){
                [weakSelf.imageMQTTdelegate getRotateImage:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] rotate:[dic[@"rotate"] floatValue] currentPage:[dic[@"currentPage"] intValue] imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"zoomImage"]){
            
            if (weakSelf.imageMQTTdelegate!=nil && [weakSelf.imageMQTTdelegate respondsToSelector:@selector(getZoomImage:userId:imageId:size:currentPage:imageNum:)]){
                NSDictionary *dicSize = dic[@"scale"];
                CGSize size = CGSizeMake([dicSize[@"width"] floatValue], [dicSize[@"height"] floatValue]);
                [weakSelf.imageMQTTdelegate getZoomImage:dic[@"roomId"] userId:dic[@"userId"] imageId:[dic[@"imageId"] intValue] size:size currentPage:[dic[@"currentPage"] intValue] imageNum:[dic[@"imageNum"] intValue]];
            }
        }
        else if ([topic isEqual:@"undo"]){
            
            if (weakSelf.controldelegate!=nil && [weakSelf.controldelegate respondsToSelector:@selector(undoWithRoomId:userId:graphical:currentPage:)]){
               
                [weakSelf.controldelegate undoWithRoomId:dic[@"roomId"] userId:dic[@"userId"] graphical:[dic[@"graphical"] intValue] currentPage:[dic[@"currentPage"] intValue]];
            }
        }
        else if ([topic isEqual:@"redo"]){
            
            if (weakSelf.controldelegate!=nil && [weakSelf.controldelegate respondsToSelector:@selector(redoWithRoomId:userId:graphical:currentPage:)]){
               
                [weakSelf.controldelegate redoWithRoomId:dic[@"roomId"] userId:dic[@"userId"] graphical:[dic[@"graphical"] intValue] currentPage:[dic[@"currentPage"] intValue]];
            }
        }
        else if ([topic isEqual:@"clearAll"]){
            
            if (weakSelf.controldelegate!=nil && [weakSelf.controldelegate respondsToSelector:@selector(clearAll:userId:currentPage:)]){
               
                [weakSelf.controldelegate clearAll:dic[@"roomId"] userId:dic[@"userId"] currentPage:[dic[@"currentPage"] intValue]];
            }
        }
        else if ([topic isEqual:@"readWriteAuthority"]){
            
            if (weakSelf.authorityStatelegate!=nil && [weakSelf.authorityStatelegate respondsToSelector:@selector(getAuthorityState:roomId:userId:isCreater:)]){
                BOOL creater;
                if([dic[@"isCreater"]intValue] == 0){
                    creater = NO;
                }else{
                    creater = YES;
                }
                [weakSelf.authorityStatelegate getAuthorityState:[dic[@"authority"]intValue] roomId:dic[@"roomId"] userId:dic[@"userId"] isCreater:creater];
            }
        }
        else if ([topic isEqual:@"userList"]){
            
            if (weakSelf.userListMQTTDelegateDelegate!=nil && [weakSelf.userListMQTTDelegateDelegate respondsToSelector:@selector(getUserList:userId:Authorith:)]){
                [weakSelf.userListMQTTDelegateDelegate getUserList:dic[@"roomId"] userId:dic[@"userId"] Authorith:[dic[@"authority"]intValue]];
            }
        }
        else if ([topic isEqual:@"leaveRoom"]){
            
            if (weakSelf.userListMQTTDelegateDelegate!=nil && [weakSelf.userListMQTTDelegateDelegate respondsToSelector:@selector(getLeaveRoom:userId:)]){
                [weakSelf.userListMQTTDelegateDelegate getLeaveRoom:dic[@"roomId"] userId:dic[@"userId"]];
            }
        }
        else if ([topic isEqual:@"joinRoom"]){
            
            if (weakSelf.userListMQTTDelegateDelegate!=nil && [weakSelf.userListMQTTDelegateDelegate respondsToSelector:@selector(getJoinRoom:userId:)]){
                [weakSelf.userListMQTTDelegateDelegate getJoinRoom:dic[@"roomId"] userId:dic[@"userId"]];
            }
        }
        else{
            if (weakSelf.updateToMQTTdelegate!=nil && [weakSelf.updateToMQTTdelegate respondsToSelector:@selector(getMassagePoint:userId:color:currentPage:graphical:lineWidth:)]){
                [weakSelf.updateToMQTTdelegate getMassagePoint:point userId:dic[@"userId"] color:[weakSelf stringToUIColor:colorDic] currentPage:[dic[@"currentPage"] intValue] graphical:[dic[@"graphical"] intValue] lineWidth:[dic[@"lineWidth"] floatValue]];
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
    self.pageMQTTdelegate = nil;
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
-(void)sendPointMassage:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color topic:(NSString *)topic roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth{
    
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
        [dic setValue:[NSString stringWithFormat:@"%d",graphical] forKey:@"graphical"];
        [dic setValue:[NSString stringWithFormat:@"%f",lineWidth] forKey:@"lineWidth"];
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
-(void)sendStartPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth{
    [self sendPointMassage:point userId:userId color:color topic:@"touchStart" roomId:roomId graphical:graphical lineWidth:lineWidth];
}
-(void)sendEndPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth{
    [self sendPointMassage:point userId:userId color:color topic:@"touchEnd" roomId:roomId graphical:graphical lineWidth:lineWidth];
}
-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth{
    [self sendPointMassage:point userId:userId color:color topic:self.topic roomId:roomId graphical:graphical lineWidth:lineWidth];
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
-(void)sendNextPageMessage:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("nextPage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"nextPage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendUpPageMessage:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("upPage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"upPage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}

-(void)sendAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("addImageStart", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        NSMutableDictionary *dicPoint = [NSMutableDictionary dictionary];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.x] forKey:@"x"];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.y] forKey:@"y"];
        [dic setValue:dicPoint forKey:@"point"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"addImageStart" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("addImageScrolling", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        NSMutableDictionary *dicPoint = [NSMutableDictionary dictionary];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.x] forKey:@"x"];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.y] forKey:@"y"];
        [dic setValue:dicPoint forKey:@"point"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"addImageScrolling" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("addImageEnd", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        NSMutableDictionary *dicPoint = [NSMutableDictionary dictionary];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.x] forKey:@"x"];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.y] forKey:@"y"];
        [dic setValue:dicPoint forKey:@"point"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"addImageEnd" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("lockImage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"lockImage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("translationImage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        NSMutableDictionary *dicPoint = [NSMutableDictionary dictionary];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.x] forKey:@"x"];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",point.y] forKey:@"y"];
        [dic setValue:dicPoint forKey:@"point"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"translationImage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("rotateImage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        [dic setValue:[NSString stringWithFormat:@"%f",rotate] forKey:@"rotate"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"rotateImage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size imageNum:(int)imageNum{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("zoomImage", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageId] forKey:@"imageId"];
        
        NSMutableDictionary *dicPoint = [NSMutableDictionary dictionary];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",size.width] forKey:@"width"];
        [dicPoint setValue:[NSString stringWithFormat:@"%f",size.height] forKey:@"height"];
        [dic setValue:dicPoint forKey:@"scale"];
        [dic setValue:[NSString stringWithFormat:@"%d",imageNum] forKey:@"imageNum"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"zoomImage" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendUndo:(NSString *)roomId userId:(NSString *)userId graphical:(int)graphical{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("undo", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",graphical] forKey:@"graphical"];
        
  
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"undo" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}

-(void)sendRedo:(NSString *)roomId userId:(NSString *)userId graphical:(int)graphical{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("redo", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        [dic setValue:[NSString stringWithFormat:@"%d",graphical] forKey:@"graphical"];
        
  
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"redo" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}

-(void)sendClearAll:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("clearAll", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",self.currentPage] forKey:@"currentPage"];
        
  
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"clearAll" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}


-(void)sendAuthority:(NSString *)roomId userId:(NSString *)userId Authorith:(AuthorityState)authorith  isCreater:(BOOL)isCreater{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("readWrite", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)authorith] forKey:@"authority"];
        if(isCreater == YES){
            [dic setValue:[NSString stringWithFormat:@"1"] forKey:@"isCreater"];
        }else{
            [dic setValue:[NSString stringWithFormat:@"0"] forKey:@"isCreater"];
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"readWriteAuthority" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendUserList:(NSString *)roomId userId:(NSString *)userId Authorith:(AuthorityState)authorith{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("userList", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)authorith] forKey:@"authority"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"userList" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"发送失败 - %@",error);
                }else{
                    NSLog(@"发送成功");
                }
        }];
    });
}
-(void)sendLeaveRoom:(NSString *)roomId userId:(NSString *)userId{
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t que = dispatch_queue_create("leaveRoom", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(que, ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:roomId forKey:@"roomId"];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
        [weakSelf.mySession publishData:data onTopic:@"leaveRoom" retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
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

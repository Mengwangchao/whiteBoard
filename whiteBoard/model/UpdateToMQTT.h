//
//  UpdateToMQTT.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MQTTClient/MQTTClient.h>
NS_ASSUME_NONNULL_BEGIN
@protocol UpdateToMQTTDelegate <NSObject>

-(void)getMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage;
-(void)getStartMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage;
-(void)getEndMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage;

//-(void)getJoinRoomReturn:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color;

@end

@protocol PageMQTTDelegate <NSObject>

-(void)addPage:(NSString *)roomId userId:(NSString *)userId;
-(void)deletePage:(NSString *)roomId userId:(NSString *)userId pageNum:(int)pageNum;
-(void)nextPage:(NSString *)roomId userId:(NSString *)userId;
-(void)upPage:(NSString *)roomId userId:(NSString *)userId;

//-(void)getJoinRoomReturn:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color;

@end
typedef NS_ENUM(NSInteger, AuthorityState){
    ONLY_READ = 2, //只读
    READ_WRITE = 1 //协作
};

@interface UpdateToMQTT : NSObject

@property (nonatomic,strong,readonly)NSString *topic;
@property (nonatomic)int pageCount;
@property (nonatomic)int currentPage;
@property(nonatomic,strong)MQTTSession *mySession;
@property (nonatomic,weak) id<UpdateToMQTTDelegate> updateToMQTTdelegate;
@property (nonatomic,weak) id<PageMQTTDelegate> pageMQTTdelegate;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithTopic:(NSString *)topic;


-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId;

-(void)sendStartPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId;
-(void)sendEndPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId;
-(void)sendJoinRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)sendCreateRoom:(NSString *)roomId userId:(NSString *)userId authority :(AuthorityState) authority;
-(void)sendDeleteRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAddPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendDeletePageMessage:(NSString *)roomId userId:(NSString *)userId pageNum:(int) pageNum;
-(void)sendUpPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendNextPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAddImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId;
-(void)sendLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId;
-(void)sendTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point;
-(void)sendRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate;
-(void)sendZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size;

-(void)closeMQTTClient;
-(void)connectMQTT;
-(void)disConnectServer;
@end

NS_ASSUME_NONNULL_END

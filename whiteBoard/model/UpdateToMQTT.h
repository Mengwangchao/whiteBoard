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
typedef NS_ENUM(NSInteger, AuthorityState){
    ONLY_READ = 2, //只读
    READ_WRITE = 1 //协作
};
@protocol AuthorityStateMQTTDelegate <NSObject>

-(void)getAuthorityState:(int)authority roomId:(NSString *)roomId userId:(NSString *)userId isCreater:(BOOL)isCteater;

@end
@protocol UserListMQTTDelegate <NSObject>

-(void)getUserList:(NSString *)roomId userId:(NSString *)userId Authorith:(AuthorityState)authorith;
-(void)getLeaveRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)getJoinRoom:(NSString *)roomId userId:(NSString *)userId;

@end

@protocol UpdateToMQTTDelegate <NSObject>

-(void)getMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage graphical:(int)graphical lineWidth:(float)lineWidth;
-(void)getStartMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage graphical:(int)graphical lineWidth:(float)lineWidth;
-(void)getEndMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage graphical:(int)graphical lineWidth:(float)lineWidth;

//-(void)getJoinRoomReturn:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color;

@end

@protocol controlMQTTDelegate <NSObject>

-(void)undoWithRoomId :(NSString *)roomId userId:(NSString *)userId graphical : (int)graphical currentPage :(int)currentPage;
-(void)redoWithRoomId :(NSString *)roomId userId:(NSString *)userId graphical : (int)graphical currentPage :(int)currentPage;

-(void)clearAll :(NSString *)roomId userId:(NSString *)userId currentPage :(int)currentPage;
//-(void)getJoinRoomReturn:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color;

@end

@protocol PageMQTTDelegate <NSObject>

-(void)addPage:(NSString *)roomId userId:(NSString *)userId;
-(void)deletePage:(NSString *)roomId userId:(NSString *)userId pageNum:(int)pageNum;
-(void)nextPage:(NSString *)roomId userId:(NSString *)userId;
-(void)upPage:(NSString *)roomId userId:(NSString *)userId;

//-(void)getJoinRoomReturn:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color;

@end

@protocol ImageMQTTDelegate <NSObject>

-(void)getAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point imageNum:(int)imageNum;
-(void)getAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point imageNum:(int)imageNum;
-(void)getAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point imageNum:(int)imageNum;
-(void)getLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage imageNum:(int)imageNum;
-(void)getTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point currentPage:(int)currentPage imageNum:(int)imageNum;
-(void)getRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate currentPage:(int)currentPage imageNum:(int)imageNum;
-(void)getZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size currentPage:(int)currentPage imageNum:(int)imageNum;

@end


@interface UpdateToMQTT : NSObject

@property (nonatomic,strong,readonly)NSString *topic;
@property (nonatomic)int pageCount;
@property (nonatomic)int currentPage;
@property(nonatomic,strong)MQTTSession *mySession;
@property (nonatomic,weak) id<UpdateToMQTTDelegate> updateToMQTTdelegate;
@property (nonatomic,weak) id<ImageMQTTDelegate> imageMQTTdelegate;
@property (nonatomic,weak) id<PageMQTTDelegate> pageMQTTdelegate;
@property (nonatomic,weak) id<controlMQTTDelegate> controldelegate;
@property (nonatomic,weak) id<AuthorityStateMQTTDelegate> authorityStatelegate;
@property (nonatomic,weak) id<UserListMQTTDelegate> userListMQTTDelegateDelegate;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithTopic:(NSString *)topic;


-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth;

-(void)sendStartPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth;
-(void)sendEndPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId graphical:(int)graphical lineWidth:(float)lineWidth;
-(void)sendJoinRoom:(NSString *)roomId userId:(NSString *)userId authority:(AuthorityState)authority;
-(void)sendCreateRoom:(NSString *)roomId userId:(NSString *)userId authority :(AuthorityState) authority;
-(void)sendDeleteRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAddPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendDeletePageMessage:(NSString *)roomId userId:(NSString *)userId pageNum:(int) pageNum;
-(void)sendUpPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendNextPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum;
-(void)sendAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum;
-(void)sendAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum;
-(void)sendLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId imageNum:(int)imageNum;
-(void)sendTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point imageNum:(int)imageNum;
-(void)sendRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate imageNum:(int)imageNum;
-(void)sendZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size imageNum:(int)imageNum;
-(void)sendUndo:(NSString *)roomId userId:(NSString *)userId graphical:(int)graphical;
-(void)sendRedo:(NSString *)roomId userId:(NSString *)userId graphical:(int)graphical;
-(void)sendClearAll:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAuthority:(NSString *)roomId userId:(NSString *)userId Authorith:(AuthorityState)authorith isCreater:(BOOL)isCreater;
-(void)sendUserList:(NSString *)roomId userId:(NSString *)userId Authorith:(AuthorityState)authorith;
-(void)sendLeaveRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)closeMQTTClient;
-(void)connectMQTT;
-(void)disConnectServer;
@end

NS_ASSUME_NONNULL_END

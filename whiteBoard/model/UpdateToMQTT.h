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

-(void)getMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage graphical:(int)graphical;
-(void)getStartMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage graphical:(int)graphical;
-(void)getEndMassagePoint:(CGPoint)point userId:(NSString *)userId color : (UIColor *)color currentPage:(int)currentPage graphical:(int)graphical;

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

-(void)getAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point;
-(void)getAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point;
-(void)getAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point;
-(void)getLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage;
-(void)getTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point currentPage:(int)currentPage;
-(void)getRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate currentPage:(int)currentPage;
-(void)getZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size currentPage:(int)currentPage;

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
@property (nonatomic,weak) id<ImageMQTTDelegate> imageMQTTdelegate;
@property (nonatomic,weak) id<PageMQTTDelegate> pageMQTTdelegate;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithTopic:(NSString *)topic;


-(void)sendPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId graphical:(int)graphical;

-(void)sendStartPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId graphical:(int)graphical;
-(void)sendEndPoint:(CGPoint)point userId:(NSString *)userId color:(UIColor*) color roomId:(NSString *)roomId graphical:(int)graphical;
-(void)sendJoinRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)sendCreateRoom:(NSString *)roomId userId:(NSString *)userId authority :(AuthorityState) authority;
-(void)sendDeleteRoom:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAddPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendDeletePageMessage:(NSString *)roomId userId:(NSString *)userId pageNum:(int) pageNum;
-(void)sendUpPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendNextPageMessage:(NSString *)roomId userId:(NSString *)userId;
-(void)sendAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point;
-(void)sendAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point;
-(void)sendAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point;
-(void)sendLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId;
-(void)sendTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point;
-(void)sendRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate;
-(void)sendZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size;

-(void)closeMQTTClient;
-(void)connectMQTT;
-(void)disConnectServer;
@end

NS_ASSUME_NONNULL_END
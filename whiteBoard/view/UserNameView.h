//
//  UserNameView.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/11/7.
//

#import <UIKit/UIKit.h>
#import "UpdateToMQTT.h"

NS_ASSUME_NONNULL_BEGIN


@protocol UserNameViewDelegate <NSObject>
-(void)selectTableCellWithRoomId:(NSString *)roomId userId:(NSString *)userId;

@end
@interface UserNameView : UIView

@property (nonatomic, weak) UpdateToMQTT * uploadMQTT;
@property (nonatomic)BOOL authority;
@property (nonatomic,strong)NSString* createrName;
@property (nonatomic,weak) id<UserNameViewDelegate> userNameViewDelegatedelegate;

-(instancetype)initWithFrame:(CGRect)frame MQTT:(UpdateToMQTT *)mqtt isCreater:(BOOL)isCreater roomId:(NSString *)roomId userId:(NSString *)userId;
-(void)setUserName:(NSString *)userId authority:(int)authority;
@end

NS_ASSUME_NONNULL_END

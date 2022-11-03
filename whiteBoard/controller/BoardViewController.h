//
//  BoardViewController.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BoardViewController : UIViewController

@property (nonatomic)BOOL isCreater;
@property (nonatomic)BOOL authority;
//房间名
@property (nonatomic,strong)NSString * roomId;
//用户名
@property (nonatomic,strong)NSString * userId;
@end

NS_ASSUME_NONNULL_END

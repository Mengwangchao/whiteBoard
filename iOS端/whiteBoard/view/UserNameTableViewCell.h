//
//  UserNameTableViewCell.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserNameTableViewCell : UITableViewCell
@property (nonatomic)BOOL authority;
-(instancetype)initWithUserName:(NSString *)userName;
@end

NS_ASSUME_NONNULL_END

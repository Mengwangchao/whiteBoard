//
//  UserNameTableViewCell.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/11/7.
//

#import "UserNameTableViewCell.h"
@interface UserNameTableViewCell()
@property(nonatomic,strong)UILabel* userNameLabel;
@property(nonatomic,strong)UILabel* authorityLabel;
@end
@implementation UserNameTableViewCell

-(instancetype)initWithUserName:(NSString *)userName{
    self = [super init];
    if(self){
        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2)];
        self.userNameLabel.backgroundColor = [UIColor clearColor];
        self.userNameLabel.font = [UIFont systemFontOfSize:12];
        self.userNameLabel.textColor = [UIColor blackColor];
        self.userNameLabel.textAlignment = NSTextAlignmentLeft;
        self.userNameLabel.text = userName;
        self.userNameLabel.numberOfLines = 0;
        [self.contentView addSubview:self.userNameLabel];
        
        self.authorityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height/2, 80, self.frame.size.height/2)];
        self.authorityLabel.backgroundColor = [UIColor whiteColor];
        self.authorityLabel.font = [UIFont systemFontOfSize:12];
        self.authorityLabel.textColor = [UIColor blackColor];
        self.authorityLabel.textAlignment = NSTextAlignmentRight;
        self.authorityLabel.text = @"权限：只读";
        self.authorityLabel.numberOfLines = 0;
        [self.contentView addSubview:self.authorityLabel];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setAuthority:(BOOL)authority{
    _authority = authority;
    if(authority == YES){
        self.authorityLabel.text = @"权限：读写";
        self.authorityLabel.textColor = [UIColor greenColor];
    }else{
        
        self.authorityLabel.text = @"权限：只读";
        self.authorityLabel.textColor = [UIColor blackColor];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

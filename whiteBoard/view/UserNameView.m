//
//  UserNameView.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/11/7.
//

#import "UserNameView.h"
#import "UserNameTableViewCell.h"
@interface UserNameView()<UITableViewDelegate,UITableViewDataSource,UserListMQTTDelegate>
@property(nonatomic)BOOL isCreater;
@property(nonatomic,strong)UITableView *rootTableView;
@property(nonatomic,strong)NSMutableArray<NSDictionary*> *userArray;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@end
@implementation UserNameView

-(instancetype)initWithFrame:(CGRect)frame MQTT:(UpdateToMQTT *)mqtt isCreater:(BOOL)isCreater roomId:(NSString *)roomId userId:(nonnull NSString *)userId{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.isCreater = isCreater;
        self.userArray = [NSMutableArray array];
        self.uploadMQTT = mqtt;
        self.roomId = roomId;
        self.userId = userId;
        self.uploadMQTT.userListMQTTDelegateDelegate = self;
        self.rootTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.rootTableView.delegate = self;
        self.rootTableView.dataSource = self;
        [self addSubview:self.rootTableView];
    }
    return self;
}
-(void)setAuthority:(BOOL)authority{
    _authority = authority;
}
-(void)setCreaterName:(NSString *)createrName{
    _createrName = createrName;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:createrName forKey:@"userId"];
    
    [dic setValue:[NSString stringWithFormat:@"1"] forKey:@"authority"];
    [self.userArray addObject:dic];
}

-(void)setUserName:(NSString *)userId authority:(int)authority{
    for (int i = 0; i<self.userArray.count; i++) {
        NSDictionary *dic = self.userArray[i];
        if([dic[@"userId"] isEqual:userId]){
            [dic setValue:[NSString stringWithFormat:@"%d",(int)authority] forKey:@"authority"];
            self.userArray[i] = dic;
            [self.rootTableView reloadData];
            return;
        }
    }
}
#pragma mark - tableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.userArray[indexPath.row];
    UserNameTableViewCell *cell = [[UserNameTableViewCell alloc]initWithUserName:dic[@"userId"]];
    AuthorityState auth =(AuthorityState)[dic[@"authority"]intValue];
    switch (auth) {
        case ONLY_READ:
            cell.authority = NO;
            break;
        case READ_WRITE:
            cell.authority = YES;
            break;
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = self.userArray[indexPath.row];
    NSString *userId = dic[@"userId"];
    if(self.userNameViewDelegatedelegate != nil &&[self.userNameViewDelegatedelegate respondsToSelector:@selector(selectTableCellWithRoomId:userId:)]){
        [self.userNameViewDelegatedelegate selectTableCellWithRoomId:self.roomId userId:userId];
    }
 
}

#pragma mark - MQTT Delegate
-(void)getUserList:(NSString *)roomId userId:(NSString *)userId Authorith:(AuthorityState)authorith{
    if(self.isCreater){
        return;
    }
    if ([roomId isEqual:self.roomId]) {
        for (int i = 0; i<self.userArray.count; i++) {
            NSDictionary *dic = self.userArray[i];
            if([dic[@"userId"] isEqual:userId]){
                [dic setValue:[NSString stringWithFormat:@"%d",(int)authorith] forKey:@"authority"];
                self.userArray[i] = dic;
                [self.rootTableView reloadData];
                return;
            }
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:userId forKey:@"userId"];
        [dic setValue:[NSString stringWithFormat:@"%d",(int)authorith] forKey:@"authority"];
        [self.userArray addObject:dic];
        [self.rootTableView reloadData];
    }
}


-(void)getLeaveRoom:(NSString *)roomId userId:(NSString *)userId{
    if (![roomId isEqual:self.roomId]){
        return;
    }
    for (NSDictionary *dic in self.userArray) {
        if([dic[@"userId"] isEqual:userId]){
            [self.userArray removeObject:dic];
            [self.rootTableView reloadData];
            return;
        }
    }
}
-(void)getJoinRoom:(NSString *)roomId userId:(NSString *)userId{
    if ([roomId isEqual:self.roomId]){
        BOOL flag = NO;
        for (NSDictionary *dic in self.userArray) {
            if([dic[@"userId"] isEqual:userId]){
                flag = YES;
                break;
            }
        }
        if(flag == NO){
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:userId forKey:@"userId"];
            [dic setValue:@"2" forKey:@"authority"];
            [self.userArray addObject:dic];
            [self.rootTableView reloadData];
        }
        if(self.isCreater){
            for (NSDictionary *dic in self.userArray) {
               
                [self.uploadMQTT sendUserList:roomId userId:dic[@"userId"] Authorith:[dic[@"authority"]intValue]];
            }
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

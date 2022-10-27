//
//  ViewController.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "ViewController.h"
#import "BoardViewController.h"
#import "UpdateToMQTT.h"
@interface ViewController ()
@property (nonatomic , strong)UpdateToMQTT *update;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *boardButton = [[UIButton alloc] initWithFrame:CGRectMake(70, MAIN_SCREEN_HEIGHT/2 - 100, MAIN_SCREEN_WIDTH - 140, 34)];
    boardButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
    boardButton.layer.cornerRadius = 3;
    [boardButton addTarget:self action:@selector(createBoardAction:) forControlEvents:UIControlEventTouchDown];
    [boardButton setTitle:@"创建画板" forState:UIControlStateNormal];
    boardButton.titleLabel.font = FONT_MEDIUM(14);
    [self.view addSubview:boardButton];
    
    UIButton *joinButton = [[UIButton alloc] initWithFrame:CGRectMake(70, MAIN_SCREEN_HEIGHT/2, MAIN_SCREEN_WIDTH - 140, 34)];
    joinButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
    joinButton.layer.cornerRadius = 3;
    [joinButton addTarget:self action:@selector(enterBoardAction:) forControlEvents:UIControlEventTouchDown];
    [joinButton setTitle:@"匿名加入" forState:UIControlStateNormal];
    joinButton.titleLabel.font = FONT_MEDIUM(14);
    [self.view addSubview:joinButton];
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(70, MAIN_SCREEN_HEIGHT/2+100, MAIN_SCREEN_WIDTH - 140, 34)];
    sendButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
    sendButton.layer.cornerRadius = 3;
    [sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchDown];
    [sendButton setTitle:@"发送消息" forState:UIControlStateNormal];
    sendButton.titleLabel.font = FONT_MEDIUM(14);
    [self.view addSubview:sendButton];
    self.update = [[UpdateToMQTT alloc]init];
    [self.update connectMQTT:@"" port:0 userName:@"" password:@""];
    // Do any additional setup after loading the view.
}


#pragma mark --进入各个界面
- (void)sendButtonAction:(UIButton *)button {
    NSString *msg = @"ssss";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:msg forKey:@"key"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    [self.update sendMassage:data topic:@"saf22"];
}
- (void)createBoardAction:(UIButton *)button {
    BoardViewController *boardViewController = [[BoardViewController alloc] init];
    boardViewController.isCreater = YES;
    boardViewController.userId = [self getUserId];
    boardViewController.roomId = [self getRoomId];
    [self.navigationController pushViewController:boardViewController animated:YES];
}

- (void)enterBoardAction:(UIButton *)button {
    BoardViewController *joinViewController = [[BoardViewController alloc] init];

    [self.navigationController pushViewController:joinViewController animated:YES];
}

-(NSString *)getUserId{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"user%.0f",time];
}

-(NSString *)getRoomId{
    NSString *roomId = @"";
    for (int i = 0 ; i<12; i++) {
        NSString *num = [NSString stringWithFormat:@"%d", arc4random()%10];
        roomId = [roomId stringByAppendingString:num];
    }
    return roomId;
}
@end

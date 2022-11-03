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
//@property (nonatomic , strong)UpdateToMQTT *update;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
//    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(70, MAIN_SCREEN_HEIGHT/2+100, MAIN_SCREEN_WIDTH - 140, 34)];
//    sendButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
//    sendButton.layer.cornerRadius = 3;
//    [sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchDown];
//    [sendButton setTitle:@"发送消息" forState:UIControlStateNormal];
//    sendButton.titleLabel.font = FONT_MEDIUM(14);
//    [self.view addSubview:sendButton];
//    self.update = [[UpdateToMQTT alloc]initWithTopic:@"userid"];
    // Do any additional setup after loading the view.
}


#pragma mark --进入各个界面
//- (void)sendButtonAction:(UIButton *)button {
//    NSString *msg = @"ssss";
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:msg forKey:@"key"];
//
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
//    UIColor *color = [UIColor colorWithRed:1/255.0 green:2/255.0 blue:3/255.0 alpha:0.6];
////    self.update.topic = @"userid";
//    [self.update sendPoint:CGPointMake(1, 1) userId:@"test" color:[UIColor grayColor]];
//}
- (void)createBoardAction:(UIButton *)button {
    BoardViewController *boardViewController = [[BoardViewController alloc] init];
    boardViewController.isCreater = YES;
    boardViewController.userId = [self getUserId];
    boardViewController.roomId = [self getRoomId];
    [self.navigationController pushViewController:boardViewController animated:YES];
}

- (void)enterBoardAction:(UIButton *)button {
    BoardViewController *joinViewController = [[BoardViewController alloc] init];
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"请输入房间名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionDefaut = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertControl.textFields[0];
        if([textField.text isEqual:@""]){
            
        }else{
            joinViewController.roomId = textField.text;
            joinViewController.userId = [self getUserId];
            joinViewController.isCreater = NO;
            joinViewController.authority = NO;
            [self.navigationController pushViewController:joinViewController animated:YES];
        }
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
    }];
    [alertControl addAction:actionDefaut];
    [alertControl addAction:actionCancel];
    [self presentViewController:alertControl animated:NO completion:nil];
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

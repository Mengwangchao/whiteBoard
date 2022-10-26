//
//  ViewController.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "ViewController.h"
#import "BoardViewController.h"
#import "JoinViewController.h"
@interface ViewController ()
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
    
    UIButton *joinButton = [[UIButton alloc] initWithFrame:CGRectMake(70, MAIN_SCREEN_HEIGHT/2 - 100, MAIN_SCREEN_WIDTH - 140, 34)];
    joinButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
    joinButton.layer.cornerRadius = 3;
    [joinButton addTarget:self action:@selector(enterBoardAction:) forControlEvents:UIControlEventTouchDown];
    [joinButton setTitle:@"匿名加入" forState:UIControlStateNormal];
    joinButton.titleLabel.font = FONT_MEDIUM(14);
    [self.view addSubview:joinButton];
    // Do any additional setup after loading the view.
}


#pragma mark --进入各个界面
- (void)createBoardAction:(UIButton *)button {
    BoardViewController *boardViewController = [[BoardViewController alloc] init];
    boardViewController.isCreater = YES;
    [self.navigationController pushViewController:boardViewController animated:YES];
}

- (void)enterBoardAction:(UIButton *)button {
    BoardViewController *joinViewController = [[BoardViewController alloc] init];

    [self.navigationController pushViewController:joinViewController animated:YES];
}

@end

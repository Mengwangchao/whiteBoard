//
//  BoardViewController.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "BoardViewController.h"
#import "DrawView.h"
@interface BoardViewController ()
@property (nonatomic,strong)DrawView *rootDrawView;

@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.rootDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    [self.view addSubview:self.rootDrawView];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

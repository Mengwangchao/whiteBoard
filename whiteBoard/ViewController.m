//
//  ViewController.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "ViewController.h"
#import "DrawView.h"
@interface ViewController ()
@property (nonatomic, strong) DrawView *mainDrawView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    [self.view addSubview:self.mainDrawView];
    // Do any additional setup after loading the view.
}


@end

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
@property (nonatomic,strong)UIButton *pancilButton;
@property (nonatomic,strong)UIView *colorRootView;
@property (nonatomic,strong)UIView *colorChangeView;
@property (nonatomic,strong)UISlider *colorAlpha;
@property (nonatomic,strong)UISlider *colorRedColor;
@property (nonatomic,strong)UISlider *colorGreenColor;
@property (nonatomic,strong)UISlider *colorBlueColor;
@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *roomIdLabel = [[UILabel alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2-120, 60, 240, 40)];
    roomIdLabel.backgroundColor = [UIColor clearColor];
    roomIdLabel.text = [NSString stringWithFormat:@"房间名：%@",self.roomId];
    roomIdLabel.textColor = [UIColor blackColor];
    roomIdLabel.font = [UIFont systemFontOfSize:18.0];
    [self.view addSubview:roomIdLabel];
    self.rootDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT) userId:self.userId roomId:self.roomId];
    if(!self.isCreater){
        
//        self.rootDrawView.userInteractionEnabled = NO;  //开启后就是只读模式
    }
    [self.view addSubview:self.rootDrawView];
    
    self.pancilButton = [[UIButton alloc]initWithFrame:CGRectMake(20, MAIN_SCREEN_HEIGHT-80, 28, 45)];
    UIImage * pancilImage =[UIImage imageNamed:@"pancil"];
    
    pancilImage = [pancilImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
//    [self.pancilButton setImage:pancilImage forState:UIControlStateNormal];
    self.pancilButton.backgroundColor = [UIColor clearColor];
    self.pancilButton.tintColor = [UIColor blackColor];
    [self.pancilButton setBackgroundImage:pancilImage forState:UIControlStateNormal];
    [self.pancilButton addTarget:self action:@selector(pancilButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pancilButton];
    

    [self addColorView];
    
    // Do any additional setup after loading the view.
}
-(void)addColorView{
    _colorRootView = [[UIView alloc]initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50)];
        _colorRootView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [self.view addSubview:_colorRootView];
    UILabel *alphaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 420, 70, 30)];
    alphaLabel.backgroundColor = [UIColor clearColor];
    alphaLabel.text = @"透明度";
    [self.colorRootView addSubview:alphaLabel];
    self.colorAlpha = [[UISlider alloc]initWithFrame:CGRectMake(90, 420, self.colorRootView.frame.size.width - 130, 30)];
    self.colorAlpha.maximumValue = 1.0;
    self.colorAlpha.minimumValue = 0.0;
    self.colorAlpha.value = 1.0;
    [self.colorAlpha addTarget:self action:@selector(sliderClick) forControlEvents:UIControlEventValueChanged];
    [self.colorRootView addSubview:self.colorAlpha];
    
    UILabel *redColorLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 460, 70, 30)];
    redColorLabel.backgroundColor = [UIColor clearColor];
    redColorLabel.text = @"红色占比";
    [self.colorRootView addSubview:redColorLabel];
    self.colorRedColor = [[UISlider alloc]initWithFrame:CGRectMake(90, 460, self.colorRootView.frame.size.width - 130, 30)];
    self.colorRedColor.maximumValue = 255.0;
    self.colorRedColor.minimumValue = 0.0;
    self.colorRedColor.value = 255.0/2;
    [self.colorRedColor addTarget:self action:@selector(sliderClick) forControlEvents:UIControlEventValueChanged];
    [self.colorRootView addSubview:self.colorRedColor];
    
    UILabel *greenColorLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 500, 70, 30)];
    greenColorLabel.backgroundColor = [UIColor clearColor];
    greenColorLabel.text = @"绿色占比";
    [self.colorRootView addSubview:greenColorLabel];
    self.colorGreenColor = [[UISlider alloc]initWithFrame:CGRectMake(90, 500, self.colorRootView.frame.size.width - 130, 30)];
    self.colorGreenColor.maximumValue = 255.0;
    self.colorGreenColor.minimumValue = 0.0;
    self.colorGreenColor.value = 255.0/2;

    [self.colorGreenColor addTarget:self action:@selector(sliderClick) forControlEvents:UIControlEventValueChanged];
    [self.colorRootView addSubview:self.colorGreenColor];
    
    UILabel *blueColorLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 540, 70, 30)];
    blueColorLabel.backgroundColor = [UIColor clearColor];
    blueColorLabel.text = @"蓝色占比";
    [self.colorRootView addSubview:blueColorLabel];
    self.colorBlueColor = [[UISlider alloc]initWithFrame:CGRectMake(90, 540, self.colorRootView.frame.size.width - 130, 30)];
    self.colorBlueColor.maximumValue = 255.0;
    self.colorBlueColor.minimumValue = 0.0;
    self.colorBlueColor.value = 255.0/2;
    [self.colorBlueColor addTarget:self action:@selector(sliderClick) forControlEvents:UIControlEventValueChanged];
    [self.colorRootView addSubview:self.colorBlueColor];
    int flag = 0;
    for(int i = 0; i<3;i++){
        for(int j = 0; j<3;j++){
            for(int k = 0; k<3;k++){
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(30+flag%7 * 50,50+ flag/7* 50, 40, 40)];
                view.backgroundColor = [UIColor colorWithRed:i*127.5/255.0 green:j*127.5/255.0 blue:k*127.5/255.0 alpha:1.0];
                [self.colorRootView addSubview:view];
                UITapGestureRecognizer *tages = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapGesClick:)];
                [view addGestureRecognizer:tages];
                flag ++;
            }
        }
    }
    
    self.colorChangeView = [[UIView alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2-50, 300, 100, 100)];
    self.colorChangeView.userInteractionEnabled = NO;
    self.colorChangeView.backgroundColor = [UIColor colorWithRed:self.colorRedColor.value/255.0 green:self.colorGreenColor.value/255.0 blue:self.colorBlueColor.value/255.0 alpha:self.colorAlpha.value];
    [self.colorRootView addSubview:self.colorChangeView];
    
    UIButton *OkButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2-130, 600, 120, 30)];
    OkButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
    [OkButton addTarget:self action:@selector(colorRootViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    OkButton.tag = 10;
    OkButton.layer.cornerRadius = 10;
    [OkButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.colorRootView addSubview:OkButton];
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2, 600, 120, 30)];
    cancelButton.backgroundColor = BUTTON_BACKGROUNDCOLOR;
    [cancelButton addTarget:self action:@selector(colorRootViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 11;
    cancelButton.layer.cornerRadius = 10;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.colorRootView addSubview:cancelButton];
}
#pragma mark - 按钮点击事件
-(void)pancilButtonClick:(UIButton *)sender{
//    self.pancilButton.tintColor = [UIColor greenColor];

        [UIView animateWithDuration:0.3 animations:^{
                    self.colorRootView.frame = CGRectMake(0, 50, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
                }];
    
}
-(void)viewTapGesClick:(UITapGestureRecognizer *)tap{
    self.pancilButton.tintColor = tap.view.backgroundColor;
    [self.rootDrawView setLineColor:tap.view.backgroundColor];
    [UIView animateWithDuration:0.3 animations:^{
                self.colorRootView.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
            }];
}
-(void)sliderClick{
    
    self.colorChangeView.backgroundColor = [UIColor colorWithRed:self.colorRedColor.value/255.0 green:self.colorGreenColor.value/255.0 blue:self.colorBlueColor.value/255.0 alpha:self.colorAlpha.value];
}
-(void)colorRootViewButtonClick:(UIButton *)sender{
    if(sender.tag == 10){
        self.pancilButton.tintColor = self.colorChangeView.backgroundColor;
        [self.rootDrawView setLineColor:self.colorChangeView.backgroundColor];
        [UIView animateWithDuration:0.3 animations:^{
                    self.colorRootView.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
                }];
    }else if (sender.tag ==11){
        [UIView animateWithDuration:0.3 animations:^{
                    self.colorRootView.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
                }];
    }
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

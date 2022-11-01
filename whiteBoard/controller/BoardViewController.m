//
//  BoardViewController.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "BoardViewController.h"
#import "DrawViewAndImageView.h"
#import "UpdateToMQTT.h"
#import "ImageViewOfDrawView.h"
@interface BoardViewController ()<PageMQTTDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong)DrawViewAndImageView *rootDrawView;
@property (nonatomic,strong)UpdateToMQTT *mMQTT;
@property (nonatomic,strong)NSMutableArray<DrawViewAndImageView*> *rootDrawViewArray;
@property (nonatomic,strong)UIButton *pageButton;
@property (nonatomic)int currentPage;
@property (nonatomic)int pageCount;
@property (nonatomic,strong)UIButton *pancilButton;
@property(nonatomic,strong)UIButton *eraserButton;
@property (nonatomic,strong)UIButton *addPageButton;
@property (nonatomic,strong)UIButton *deletePageButton;
@property (nonatomic,strong)UIView *colorRootView;
@property (nonatomic,strong)UIView *colorChangeView;
@property (nonatomic,strong)UISlider *colorAlpha;
@property (nonatomic,strong)UISlider *colorRedColor;
@property (nonatomic,strong)UISlider *colorGreenColor;
@property (nonatomic,strong)UISlider *colorBlueColor;
@property (nonatomic,strong)ImageViewOfDrawView *image;
@end

@implementation BoardViewController
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mMQTT disConnectServer];
    self.mMQTT = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.pageCount = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    self.rootDrawViewArray = [NSMutableArray array];
    UILabel *roomIdLabel = [[UILabel alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2-120, 60, 240, 40)];
    roomIdLabel.backgroundColor = [UIColor clearColor];
    roomIdLabel.text = [NSString stringWithFormat:@"房间名：%@",self.roomId];
    roomIdLabel.textColor = [UIColor blackColor];
    roomIdLabel.font = [UIFont systemFontOfSize:18.0];
    [self.view addSubview:roomIdLabel];
    
    self.mMQTT = [[UpdateToMQTT alloc]initWithTopic:self.roomId];
    self.mMQTT.pageMQTTdelegate = self;
    [self.mMQTT connectMQTT];
    self.rootDrawView = [[DrawViewAndImageView alloc]initWithFrame:CGRectMake(0, 0, 1000, 1000) userId:self.userId roomId:self.roomId MQTT:self.mMQTT];
    [self.rootDrawViewArray addObject:self.rootDrawView];
    if(!self.isCreater){
        
//        self.rootDrawView.userInteractionEnabled = NO;  //开启后就是只读模式
    }
    [self.view addSubview:self.rootDrawView];
    
    self.pancilButton = [[UIButton alloc]initWithFrame:CGRectMake(20, MAIN_SCREEN_HEIGHT-80, 28, 45)];
    UIImage * pancilImage =[UIImage imageNamed:@"pancil"];
    
    pancilImage = [pancilImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.pancilButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.pancilButton.tintColor = [UIColor blackColor];
    [self.pancilButton setBackgroundImage:pancilImage forState:UIControlStateNormal];
    [self.pancilButton addTarget:self action:@selector(pancilButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.pancilButton];
    
    self.eraserButton = [[UIButton alloc]initWithFrame:CGRectMake(50, MAIN_SCREEN_HEIGHT-80, 28, 45)];
    self.eraserButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.eraserButton.tintColor = [UIColor blackColor];
    [self.eraserButton setBackgroundImage:[[UIImage imageNamed:@"eraser"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.eraserButton addTarget:self action:@selector(eraserButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.eraserButton];
    
    UIPanGestureRecognizer *doublePanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doublePanGestureClick:)];
    doublePanGesture.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:doublePanGesture];
    
    self.rootDrawView.layer.borderWidth = 1;
    self.rootDrawView.layer.borderColor = [UIColor blackColor].CGColor;
    self.addPageButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-50, MAIN_SCREEN_HEIGHT-70, 30, 30)];
    self.addPageButton.backgroundColor = [UIColor clearColor];
    [self.addPageButton setImage:[UIImage imageNamed:@"addPage"] forState:UIControlStateNormal];
    [self.addPageButton addTarget:self action:@selector(addPageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPageButton];
    
    self.deletePageButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-100, MAIN_SCREEN_HEIGHT-70, 30, 30)];
    self.deletePageButton.backgroundColor = [UIColor clearColor];
    [self.deletePageButton setImage:[UIImage imageNamed:@"deletePage"] forState:UIControlStateNormal];
    [self.deletePageButton addTarget:self action:@selector(deletePageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deletePageButton];
    
    self.pageButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2-25, MAIN_SCREEN_HEIGHT-70, 50, 30)];
    [self setPageButtonText:self.currentPage pageCount:self.pageCount];
    [self.pageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.pageButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pageButton];
    
    
     UIButton * nextButton = [[UIButton alloc]initWithFrame:CGRectMake(self.pageButton.frame.size.width+self.pageButton.frame.origin.x, self.pageButton.frame.origin.y+5, 20, 20)];
    [nextButton setBackgroundImage:[[UIImage imageNamed:@"nextPage"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    nextButton.tintColor = [UIColor systemBlueColor];
    [nextButton addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UIButton * upButton = [[UIButton alloc]initWithFrame:CGRectMake(self.pageButton.frame.origin.x-25, self.pageButton.frame.origin.y+5, 20, 20)];
   [upButton setBackgroundImage:[[UIImage imageNamed:@"upPage"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    upButton.tintColor = [UIColor systemBlueColor];
   [upButton addTarget:self action:@selector(upButtonClick) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:upButton];
   
//    self.image = [[ImageViewOfDrawView alloc]initWithFrame:CGRectMake(100, 100, 100, 100) image:[UIImage imageNamed:@"LOGO"]];
//    self.image.userInteractionEnabled = YES;
//    [self.view addSubview:self.image];
//    UIButton *bu = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, 50, 50)];
//    bu.backgroundColor = [UIColor redColor];
//    [bu addTarget:self action:@selector(buClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:bu];
    
    
    UIView *buttonRootView = [[UIView alloc]initWithFrame:CGRectMake(10, 90, 50, 100)];
    buttonRootView.backgroundColor = [UIColor clearColor];
    buttonRootView.userInteractionEnabled = YES;
    [self.view addSubview:buttonRootView];
    UIButton *addImage = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    addImage.backgroundColor = [UIColor greenColor];
    [addImage setBackgroundImage:[[UIImage imageNamed:@"addImage"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    addImage.tintColor = [UIColor blackColor];
    [addImage addTarget:self action:@selector(addImageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [buttonRootView addSubview:addImage];
    //保证最后创建
    [self addColorView];
    // Do any additional setup after loading the view.
}
-(void)buClick{
    self.image.userInteractionEnabled = NO;
    [self.view sendSubviewToBack:self.image];
}
-(void)addColorView{
    _colorRootView = [[UIView alloc]initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50)];
        _colorRootView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [self.view addSubview:_colorRootView];
    UILabel *alphaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 420, 70, 30)];
    alphaLabel.backgroundColor = [UIColor clearColor];
    alphaLabel.text = @"透明度";
    alphaLabel.textColor = [UIColor blackColor];
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
    redColorLabel.textColor = [UIColor blackColor];
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
    greenColorLabel.textColor = [UIColor blackColor];
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
    blueColorLabel.textColor = [UIColor blackColor];
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
-(void)setPageButtonText:(int)currentPage pageCount:(int)pageCount{
    [self.pageButton setTitle:[NSString stringWithFormat:@"%d/%d",currentPage,pageCount] forState:UIControlStateNormal];
}
#pragma mark - delegate
-(void)addPage:(NSString *)roomId userId:(NSString *)userId{
    if ([roomId isEqual:self.roomId] && ![self.userId isEqual:userId]) {
        [self addPage];
    }
}
-(void)deletePage:(NSString *)roomId userId:(NSString *)userId pageNum:(int)pageNum{
    if ([roomId isEqual:self.roomId] && ![self.userId isEqual:userId]) {
        [self deletePage];
    }
}
-(void)upPage:(NSString *)roomId userId:(NSString *)userId{
    if ([roomId isEqual:self.roomId] && ![self.userId isEqual:userId]) {
        [self selectPage:NO];
    }
}
-(void)nextPage:(NSString *)roomId userId:(NSString *)userId{
    if ([roomId isEqual:self.roomId] && ![self.userId isEqual:userId]) {
        [self selectPage:YES];
    }
}
#pragma mark - 按钮点击事件
-(void)addImageButtonClick{
    
    [self.rootDrawView addImageView:[UIImage imageNamed:@"LOGO"] imageId:1];
}
-(void)pancilButtonClick:(UIButton *)sender{
//    self.pancilButton.tintColor = [UIColor greenColor];
    self.rootDrawView.isEraser = NO;
    self.eraserButton.tintColor = [UIColor blackColor];
        [UIView animateWithDuration:0.3 animations:^{
                    self.colorRootView.frame = CGRectMake(0, 50, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
                }];
    
}
-(void)eraserButtonClick{
    if (self.rootDrawView.isEraser == NO) {
        self.eraserButton.tintColor = [UIColor greenColor];
        self.rootDrawView.isEraser = YES;
    }else{
        self.rootDrawView.isEraser = NO;
        self.eraserButton.tintColor = [UIColor blackColor];
    }
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
-(void)doublePanGestureClick:(UIPanGestureRecognizer *)sender{
    
    CGPoint translation = [sender translationInView:self.view];
    self.rootDrawView.center = CGPointMake(self.rootDrawView.center.x+translation.x, self.rootDrawView.center.y+translation.y);
    [sender setTranslation:CGPointZero inView:self.view];
}
-(void)addPageButtonClick{
    [self.rootDrawView.uploadMQTT sendAddPageMessage:self.roomId userId:self.userId];
    [self addPage];
  
}
-(void)addPage{
    self.currentPage++;
    self.pageCount++;
    self.mMQTT.pageCount = self.pageCount;
    self.mMQTT.currentPage = self.pageCount;
    for (DrawViewAndImageView *view in self.rootDrawViewArray) {
        [view setDrawHidden:YES];
    }
    self.rootDrawView = [[DrawViewAndImageView alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, 2*MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT) userId:self.userId roomId:self.roomId MQTT:self.mMQTT];
    
    [self.rootDrawViewArray addObject:self.rootDrawView];
    if(!self.isCreater){
        
//        self.rootDrawView.userInteractionEnabled = NO;  //开启后就是只读模式
    }
    self.rootDrawView.currentPage = self.currentPage;
    [self.view addSubview:self.rootDrawView];
    self.rootDrawView.layer.borderWidth = 1;
    self.rootDrawView.layer.borderColor = [UIColor blackColor].CGColor;
    [UIView animateWithDuration:0.3 animations:^{
        self.rootDrawView.frame = CGRectMake(0, 0, 2*MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
        [self.view sendSubviewToBack:self.rootDrawView];
    }];
    
    self.pancilButton.tintColor = [self.rootDrawView getLineColor];
    [self setPageButtonText:self.currentPage pageCount:self.pageCount];
}
-(void)nextButtonClick{
    [self.mMQTT sendNextPageMessage:self.roomId userId:self.userId];
    [self selectPage:YES];
    
}
-(void)upButtonClick{
    [self.mMQTT sendUpPageMessage:self.roomId userId:self.userId];
    [self selectPage:NO];
}
-(void)selectPage: (BOOL)isNext{
    if (isNext) {
        self.currentPage ++;
        if (self.currentPage>self.pageCount) {
            self.currentPage = 1;
        }
    }
    else{
        
        self.currentPage --;
        if (self.currentPage<=0) {
            self.currentPage = self.pageCount;
        }
    }
    for (DrawViewAndImageView *view in self.rootDrawViewArray) {
        [view setDrawHidden:YES];
        
    }
    self.rootDrawView = self.rootDrawViewArray[self.currentPage-1];
    [self setPageButtonText:self.currentPage pageCount:self.pageCount];
    self.pancilButton.tintColor = [self.rootDrawView getLineColor];
    [self.rootDrawView setDrawHidden: NO];
}
-(void)deletePageButtonClick{
    [self.rootDrawView.uploadMQTT sendDeletePageMessage:self.roomId userId:self.userId pageNum:self.currentPage];
    [self deletePage];
    
}
-(void)deletePage{
    if (self.pageCount>1) {
        
        self.pageCount--;
        if (self.currentPage>self.pageCount) {
            self.currentPage --;
        }
        int i =1;
        [self.rootDrawView deleteView];
        self.rootDrawView.uploadMQTT = nil;
        [self.rootDrawView removeFromSuperview];
        [self.rootDrawViewArray removeObject:self.rootDrawView];
        self.mMQTT.currentPage = self.currentPage;
        self.mMQTT.pageCount = self.pageCount;
        for (DrawViewAndImageView *view in self.rootDrawViewArray) {
            view.currentPage = i;
            i++;
            [view setDrawHidden:YES];
        }
        self.rootDrawView = self.rootDrawViewArray[self.currentPage-1];
        [self setPageButtonText:self.currentPage pageCount:self.pageCount];
        self.pancilButton.tintColor = [self.rootDrawView getLineColor];
        [self.rootDrawView setDrawHidden:NO];
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

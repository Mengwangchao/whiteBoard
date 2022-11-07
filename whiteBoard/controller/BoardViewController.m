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
@interface BoardViewController ()<PageMQTTDelegate,UIGestureRecognizerDelegate,AuthorityStateMQTTDelegate>
@property (nonatomic,strong)DrawViewAndImageView *rootDrawView;
@property (nonatomic,strong)UpdateToMQTT *mMQTT;
@property (nonatomic,strong)NSMutableArray<DrawViewAndImageView*> *rootDrawViewArray;
@property (nonatomic,strong)UIButton *pageButton;
@property (nonatomic)int currentPage;
@property (nonatomic)int pageCount;
@property (nonatomic,strong)UIButton *colorButton;
@property (nonatomic,strong)UIButton *pancilButton;
@property (nonatomic,strong)UIButton *addImageButton;
@property (nonatomic,strong)UIView *leftButtonRootView;
@property (nonatomic,strong)UIView *rightButtonRootView;
@property (nonatomic,strong)UIButton *graphicalButton;
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
@property (nonatomic,strong)UIView* graphicalView;
@property (nonatomic,strong)UIButton *lineWidthButton;
@property (nonatomic,strong)UISlider *lineWidthSlider;
@property (nonatomic,strong)UIButton *authorityButton;

@end

@implementation BoardViewController
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.mMQTT disConnectServer];
    self.mMQTT = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    self.pageCount = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    self.rootDrawViewArray = [NSMutableArray array];
    UILabel *roomIdLabel = [[UILabel alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH/2-120, 80, 240, 40)];
    roomIdLabel.backgroundColor = [UIColor clearColor];
    roomIdLabel.text = [NSString stringWithFormat:@"房间名：%@",self.roomId];
    roomIdLabel.textColor = [UIColor blackColor];
    roomIdLabel.font = [UIFont systemFontOfSize:18.0];
    [self.view addSubview:roomIdLabel];
    
    self.mMQTT = [[UpdateToMQTT alloc]initWithTopic:self.roomId];
    self.mMQTT.pageMQTTdelegate = self;
    self.mMQTT.authorityStatelegate = self;
    [self.mMQTT connectMQTT];
    self.rootDrawView = [[DrawViewAndImageView alloc]initWithFrame:CGRectMake(0, 0, 1000, 1000) userId:self.userId roomId:self.roomId MQTT:self.mMQTT];
    [self.rootDrawViewArray addObject:self.rootDrawView];
    if(!self.isCreater&&self.authority == NO){
        
        self.rootDrawView.userInteractionEnabled = NO;  //开启后就是只读模式
    }
    [self.view addSubview:self.rootDrawView];
    

    
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
   

    
    
    UIPanGestureRecognizer *doublePanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doublePanGestureClick:)];
    doublePanGesture.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:doublePanGesture];
    self.leftButtonRootView = [[UIView alloc]initWithFrame:CGRectMake(10, 90, 40, 210)];
    self.leftButtonRootView.backgroundColor = [UIColor clearColor];
    self.leftButtonRootView.userInteractionEnabled = YES;
    [self.view addSubview:self.leftButtonRootView];
    self.pancilButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 35, 30, 30)];
//    addImage.backgroundColor = [UIColor greenColor];
    [self.pancilButton setBackgroundImage:[[UIImage imageNamed:@"pancil"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.pancilButton.tintColor = [UIColor greenColor];
    [self.pancilButton addTarget:self action:@selector(pancilButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButtonRootView addSubview:self.pancilButton];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHandler:)];
    [panGesture setDelegate:self];
    [self.leftButtonRootView addGestureRecognizer:panGesture];
    self.addImageButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, 30, 30)];
//    addImage.backgroundColor = [UIColor greenColor];
    [self.addImageButton setBackgroundImage:[[UIImage imageNamed:@"addImage"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.addImageButton.tintColor = [UIColor blackColor];
    [self.addImageButton addTarget:self action:@selector(addImageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButtonRootView addSubview:self.addImageButton];

    
    self.eraserButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 70, 30, 30)];
    self.eraserButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.eraserButton.tintColor = [UIColor blackColor];
    [self.eraserButton setBackgroundImage:[[UIImage imageNamed:@"eraser"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.eraserButton addTarget:self action:@selector(eraserButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButtonRootView addSubview:self.eraserButton];
    
    self.graphicalButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 105, 30, 30)];
    self.graphicalButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.graphicalButton.tintColor = [UIColor blackColor];
    [self.graphicalButton setBackgroundImage:[[UIImage imageNamed:@"2"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.graphicalButton addTarget:self action:@selector(graphicalButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButtonRootView addSubview:self.graphicalButton];
    
    self.lineWidthButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 140, 30, 30)];
    self.lineWidthButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    self.lineWidthButton.tintColor = [UIColor blackColor];
    [self.lineWidthButton setBackgroundImage:[[UIImage imageNamed:@"lineWidth"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.lineWidthButton addTarget:self action:@selector(lineWidthButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButtonRootView addSubview:self.lineWidthButton];
    self.lineWidthSlider = [[UISlider alloc]initWithFrame:CGRectMake(30, MAIN_SCREEN_HEIGHT-120, MAIN_SCREEN_WIDTH-60, 30)];
    self.lineWidthSlider.maximumValue = 50.0;
    self.lineWidthSlider.minimumValue = 0.0;
    self.lineWidthSlider.hidden = YES;
    [self.lineWidthSlider addTarget:self action:@selector(lineWidthSliderChange) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.lineWidthSlider];
    self.colorButton = [[UIButton alloc]initWithFrame:CGRectMake(5,175, 30, 30)];
//    UIImage * pancilImage =[UIImage imageNamed:@"pancil"];
    
//    pancilImage = [pancilImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.colorButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
//    self.colorButton.tintColor = [UIColor blackColor];
    self.colorButton.backgroundColor = [UIColor blackColor];
    self.colorButton.layer.cornerRadius = 15;
//    [self.colorButton setBackgroundImage:pancilImage forState:UIControlStateNormal];
    [self.colorButton addTarget:self action:@selector(colorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButtonRootView addSubview:self.colorButton];
    
    
    self.rightButtonRootView = [[UIView alloc]initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-50,90, 40, 150)];
    self.rightButtonRootView.backgroundColor = [UIColor clearColor];
    self.rightButtonRootView.userInteractionEnabled = YES;
    [self.view addSubview:self.rightButtonRootView];
    [self.rightButtonRootView addGestureRecognizer:panGesture];
    UIButton *undoButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    undoButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [undoButton setImage:[[UIImage imageNamed:@"undo"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    undoButton.tintColor = [UIColor blackColor];
    [undoButton addTarget:self action:@selector(undoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButtonRootView addSubview:undoButton];
    
    UIButton *redoButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 35, 30, 30)];
    redoButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [redoButton setImage:[[UIImage imageNamed:@"redo"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    redoButton.tintColor = [UIColor blackColor];
    [redoButton addTarget:self action:@selector(redoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButtonRootView addSubview:redoButton];
    
    UIButton *clearAllButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 70, 30, 30)];
    clearAllButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [clearAllButton setImage:[[UIImage imageNamed:@"clear"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    clearAllButton.tintColor = [UIColor blackColor];
    [clearAllButton addTarget:self action:@selector(clearAllButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButtonRootView addSubview:clearAllButton];
    
    self.authorityButton = [[UIButton alloc]initWithFrame:CGRectMake(20, MAIN_SCREEN_HEIGHT-70, 30, 30)];
    self.authorityButton.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [self.authorityButton setImage:[[UIImage imageNamed:@"auth"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.authorityButton.tintColor = [UIColor blackColor];
    [self.authorityButton addTarget:self action:@selector(authorityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.authorityButton];
    //保证最后创建
    [self addGraphicalView];
    [self addColorView];
    // Do any additional setup after loading the view.
}
-(void)buClick{
    self.image.userInteractionEnabled = NO;
    [self.view sendSubviewToBack:self.image];
}
-(void)addGraphicalView{
    self.graphicalView = [[UIView alloc]initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50)];
    self.graphicalView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [self.view addSubview:self.graphicalView];
    int flag = 2;
    for(int i = 0; i<1;i++){
        for(int j = 0; j<7;j++){
            UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(30+j * 50,50+ i* 50, 40, 40)];
            view.tintColor = [UIColor blackColor];
            view.backgroundColor = [UIColor clearColor];
            view.userInteractionEnabled = YES;
            [view setImage:[[UIImage imageNamed:[NSString stringWithFormat:@"%d",flag]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.graphicalView addSubview:view];
            view.tag = flag;
            UITapGestureRecognizer *tages = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(graphicalViewTapGesClick:)];
            [view addGestureRecognizer:tages];
            flag ++;
            
        }
    }
    
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
-(void)lightButton:(UIButton *)sender{
    self.addImageButton.tintColor = [UIColor blackColor];
    self.pancilButton.tintColor = [UIColor blackColor];
    self.eraserButton.tintColor = [UIColor blackColor];
    self.graphicalButton.tintColor = [UIColor blackColor];
    self.lineWidthButton.tintColor = [UIColor blackColor];
    sender.tintColor = [UIColor greenColor];
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
-(void)getAuthorityState:(int)authority roomId:(NSString *)roomId userId:(NSString *)userId isCreater:(BOOL)isCteater{
    if(self.isCreater == YES && isCteater == YES){
        return;
    }
    if(self.isCreater ==  NO && isCteater == NO){
        return;
    }
    if ([roomId isEqual:self.roomId] && [self.userId isEqual:userId]) {
        if(self.isCreater == NO){
            switch (authority) {
                case 1:
                    self.authority = YES;
                    self.authorityButton.tintColor = [UIColor greenColor];
                    self.rootDrawView.userInteractionEnabled = YES;
                    break;
                case 2:
                    self.authority = NO;
                    self.authorityButton.tintColor = [UIColor blackColor];
                    self.rootDrawView.userInteractionEnabled = NO;
                    break;
                default:
                    NSLog(@"authority 错误");
                    break;
            }
        }
        
    }
    else if(self.isCreater == YES){
        
            UIAlertController *alert =[UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否同意申请协作权限"] message:userId preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.mMQTT sendAuthority:self.roomId userId:userId Authorith:READ_WRITE isCreater:self.isCreater];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.mMQTT sendAuthority:self.roomId userId:userId Authorith:ONLY_READ isCreater:self.isCreater];
        }];
        [alert addAction:confirmAction];
            [alert addAction:cancel];
            [self presentViewController:alert animated:NO completion:nil];
    }
}
#pragma mark - 按钮点击事件
-(void)pancilButtonClick:(UIButton *)sender{
    
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self lightButton:sender];
    self.rootDrawView.isEraser = NO;
    self.eraserButton.tintColor = [UIColor blackColor];
    [self.rootDrawView addGraphical:LINE];
}
-(void)graphicalButtonClick:(UIButton *)sender{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self lightButton:sender];
    self.rootDrawView.isEraser = NO;
    self.eraserButton.tintColor = [UIColor blackColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.graphicalView.frame = CGRectMake(0, 50, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
    }];
}
-(void)addImageButtonClick:(UIButton *)sender{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
//    [self lightButton:sender];
    [self.rootDrawView addImageView:[UIImage imageNamed:@"LOGO"] imageId:1];
}
-(void)colorButtonClick:(UIButton *)sender{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    
//    self.pancilButton.tintColor = [UIColor greenColor];
    self.rootDrawView.isEraser = NO;
    self.eraserButton.tintColor = [UIColor blackColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.colorRootView.frame = CGRectMake(0, 50, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
    }];
    
}
-(void)eraserButtonClick:(UIButton *)sender{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    if (self.rootDrawView.isEraser == NO) {
        self.rootDrawView.isEraser = YES;
        [self lightButton:sender];
    }
}
-(void)viewTapGesClick:(UITapGestureRecognizer *)tap{
    self.colorButton.backgroundColor = tap.view.backgroundColor;
    [self.rootDrawView setLineColor:tap.view.backgroundColor];
//    self.graphicalButton.tintColor = tap.view.backgroundColor;
    [UIView animateWithDuration:0.3 animations:^{
        self.colorRootView.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
    }];
}
-(void)graphicalViewTapGesClick:(UITapGestureRecognizer *)tap{
    [self.graphicalButton setBackgroundImage:[[UIImage imageNamed:[NSString stringWithFormat:@"%ld",tap.view.tag]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.rootDrawView setLineColor:self.colorButton.backgroundColor];
    [self.rootDrawView addGraphical:(GraphicalState)tap.view.tag];
    [UIView animateWithDuration:0.3 animations:^{
        self.graphicalView.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT-50);
    }];
}
-(void)sliderClick{
    
    self.colorChangeView.backgroundColor = [UIColor colorWithRed:self.colorRedColor.value/255.0 green:self.colorGreenColor.value/255.0 blue:self.colorBlueColor.value/255.0 alpha:self.colorAlpha.value];
}
-(void)colorRootViewButtonClick:(UIButton *)sender{
    if(sender.tag == 10){
        self.colorButton.backgroundColor = self.colorChangeView.backgroundColor;
        [self.rootDrawView setLineColor:self.colorChangeView.backgroundColor];
        //        self.graphicalButton.tintColor = self.colorChangeView.backgroundColor;
        
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
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self.rootDrawView.uploadMQTT sendAddPageMessage:self.roomId userId:self.userId];
    [self addPage];
    if (self.lineWidthSlider.value != 0) {
        [self.rootDrawView setLineWith:self.lineWidthSlider.value];
    }
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
    if(self.authority == NO && self.isCreater == NO){
        
        self.rootDrawView.userInteractionEnabled = NO;  //开启后就是只读模式
    }
    self.rootDrawView.currentPage = self.currentPage;
    [self.view addSubview:self.rootDrawView];
    self.rootDrawView.layer.borderWidth = 1;
    self.rootDrawView.layer.borderColor = [UIColor blackColor].CGColor;
    [UIView animateWithDuration:0.3 animations:^{
        self.rootDrawView.frame = CGRectMake(0, 0, 2*MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
        [self.view sendSubviewToBack:self.rootDrawView];
    }];
    
    self.colorButton.tintColor = [self.rootDrawView getLineColor];
    [self setPageButtonText:self.currentPage pageCount:self.pageCount];
}
-(void)nextButtonClick{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self.mMQTT sendNextPageMessage:self.roomId userId:self.userId];
    [self selectPage:YES];
    
    [self.rootDrawView setLineWith:self.lineWidthSlider.value];
}
-(void)upButtonClick{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self.mMQTT sendUpPageMessage:self.roomId userId:self.userId];
    [self selectPage:NO];
    [self.rootDrawView setLineWith:self.lineWidthSlider.value];
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
    self.colorButton.tintColor = [self.rootDrawView getLineColor];
    [self.rootDrawView setDrawHidden: NO];
}
-(void)deletePageButtonClick{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self.rootDrawView.uploadMQTT sendDeletePageMessage:self.roomId userId:self.userId pageNum:self.currentPage];
    [self deletePage];
    
    [self.rootDrawView setLineWith:self.lineWidthSlider.value];
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
        self.colorButton.tintColor = [self.rootDrawView getLineColor];
        [self.rootDrawView setDrawHidden:NO];
    }
}
- (void) gestureHandler:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];
    
    sender.view.center = CGPointMake(sender.view.center.x+translation.x, sender.view.center.y+translation.y);
    
    [sender setTranslation:CGPointZero inView:self.view];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isEqual:self.leftButtonRootView]){
        return NO;
    }else{
        return  YES;
    }
}
-(void)lineWidthButtonClick:(UIButton *)sender{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self lightButton:sender];
    if(self.lineWidthSlider.isHidden == YES){
        self.lineWidthSlider.hidden = NO;
    }
    else{
        self.lineWidthSlider.hidden =YES;
    }
}
-(void)lineWidthSliderChange{
    
    [self.rootDrawView setLineWith:self.lineWidthSlider.value];
}

-(void)undoButtonClick{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self.rootDrawView undoClick:YES];
}
-(void)redoButtonClick{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    [self.rootDrawView redoClick];
}
-(void)clearAllButtonClick{
    if (self.authority == NO && self.isCreater == NO) {
        return;
    }
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"删除所有数据？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.rootDrawView clearAll];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:confirmAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:NO completion:nil];
}
-(void)authorityButtonClick:(UIButton *)sender{
    if (self.authority == YES || self.isCreater == YES) {
        UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"您已经是协作者了" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];
        [self presentViewController:alert animated:NO completion:nil];
        return;
    }
    else{
        [self.mMQTT sendAuthority:self.roomId userId:self.userId Authorith:READ_WRITE isCreater:self.isCreater];
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

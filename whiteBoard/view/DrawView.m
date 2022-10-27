//
//  DrawView.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "DrawView.h"
#define SCREEN_SIZE self.frame.size
@interface DrawView()<UIGestureRecognizerDelegate>

//每次触摸结束前经过的点用来连成线
@property (nonatomic,strong) NSMutableArray *pointArray;

//保存线条的数组
@property (nonatomic,strong) NSMutableArray *arrayLine;

@property (nonatomic) int lineNum;
//线条对应的配置
@property (nonatomic,strong) NSMutableDictionary *arrayLineConfig;
//保存线条对应的配置
@property (nonatomic,strong) NSMutableArray *arrayLineConfigArray;

@property (nonatomic,strong) UISlider *sliderWidth;

@property (nonatomic,strong) UIImageView *testImage;

@property (nonatomic,strong) UIColor *blackColor;//画笔默认颜色
@property (nonatomic,strong) UIColor *oldColor;//画笔默认颜色

@property (nonatomic,strong) UIButton *btnCancelDraw;//撤销画笔

@property (nonatomic, strong) UIButton *btnChangeColor;//改变颜色
@end


@implementation DrawView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.sliderWidth];
        _blackColor = [UIColor blackColor];
        self.oldColor = self.blackColor;
        self.lineNum = 0;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.btnChangeColor];
        //        [self addSubview:self.testImage];
        self.arrayLineConfig = [NSMutableDictionary dictionary];
        [self.arrayLineConfig setValue:self.blackColor forKey:@"color"];
        self.arrayLineConfigArray = [NSMutableArray array];
        [self addSubview:self.btnCancelDraw];
        
    }
    return self;
}

#pragma mark --添加图片，设置手势
- (UIImageView *)testImage
{
    if(!_testImage)
    {
        _testImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LOGO"]];
        _testImage.frame = CGRectMake(80, 250, 200, 300);
        _testImage.userInteractionEnabled = YES;
        //添加拖动shous
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHandler:)];
        //旋转手势
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationGestureHanlder:)];
        //缩放手势
        UIPinchGestureRecognizer *pingGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureHanlder:)];
        
        //设置手势代理
        [panGesture setDelegate:self];
        [rotationGesture setDelegate:self];
        [pingGesture setDelegate:self];
        //添加手势
        [_testImage addGestureRecognizer:pingGesture];
        [_testImage addGestureRecognizer:rotationGesture];
        [_testImage addGestureRecognizer:panGesture];
    }
    return _testImage;
}
#pragma mark -- 设置多个手势并存
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
#pragma mark -- 手势事件
- (void) gestureHandler:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x+translation.x, sender.view.center.y+translation.y);
    [sender setTranslation:CGPointZero inView:self];
}
- (void) rotationGestureHanlder:(UIRotationGestureRecognizer *) sender
{
    sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
    sender.rotation = 0;
}
- (void) pinchGestureHanlder:(UIPinchGestureRecognizer *) sender
{
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
}
#pragma  mark - 对外接口
//回滚
- (void) btnCanCelDrawClicked
{
    [self.arrayLine removeLastObject];
    [self setNeedsDisplay];
}
//设置线条颜色
-(void)setLineColor:(UIColor*)color{
    self.blackColor = color;
    [self setNeedsDisplay];
}
#pragma mark --重新绘制
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.sliderWidth.value);
    CGContextSetLineJoin(context, kCGLineJoinRound);//设置拐角样式
    CGContextSetLineCap(context, kCGLineCapRound);//设置线头样式
    if(self.arrayLine.count>0)
    {
        //将里面的线条画出来
        for(int i = 0;i<self.arrayLine.count;i++)
        {
            NSArray *array = [NSArray arrayWithArray:self.arrayLine[i]];
            if(array.count>0)
            {
                CGPoint myStartPoint = CGPointFromString(array[0]);
                //将画笔移动到指定的点
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                for(int j = 1;j<array.count;j++)
                {
                    CGPoint myEndPoint = CGPointFromString(array[j]);
                    CGContextAddLineToPoint(context, myEndPoint.x, myEndPoint.y);
                }
                [self.blackColor setStroke];
                CGContextStrokePath(context);
            }
        }
    }
    for (NSDictionary *dic in self.arrayLineConfigArray) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, self.sliderWidth.value);
        CGContextSetLineJoin(context, kCGLineJoinRound);//设置拐角样式
        CGContextSetLineCap(context, kCGLineCapRound);//设置线头样式
        UIColor *color = [dic valueForKey:@"color"];
        NSArray *arr = [dic valueForKey:@"arrayLine"];
        if(arr.count>0)
        {
            //将里面的线条画出来
            for(int i = 0;i<arr.count;i++)
            {
                NSArray *array = [NSArray arrayWithArray:arr[i]];
                if(array.count>0)
                {
                    CGPoint myStartPoint = CGPointFromString(array[0]);
                    //将画笔移动到指定的点
                    CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                    for(int j = 1;j<array.count;j++)
                    {
                        CGPoint myEndPoint = CGPointFromString(array[j]);
                        CGContextAddLineToPoint(context, myEndPoint.x, myEndPoint.y);
                    }
                    [color setStroke];
                    CGContextStrokePath(context);
                }
            }
        }
        //        }
        
    }
    
    
    
    //    UIFont *helvetica = [UIFont fontWithName:@"HelveticaNeue-Bold"size:30.0f];
    //    NSString *string =@"李先森";
    //
    //    [string drawAtPoint:CGPointMake(25,190)withFont:helvetica];
    //    [string drawAtPoint:CGPointMake(25,190)withAttributes:helvetica];
    
    CGContextRef contextCurrent = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextCurrent, self.sliderWidth.value);
    CGContextSetLineJoin(contextCurrent, kCGLineJoinRound);//设置拐角样式
    CGContextSetLineCap(contextCurrent, kCGLineCapRound);//设置线头样式
    if(self.pointArray.count>0)
    {
        //划线
        CGPoint startPoint = CGPointFromString(self.pointArray[0]);
        CGContextMoveToPoint(contextCurrent, startPoint.x, startPoint.y);
        for(int i = 1;i<self.pointArray.count;i++)
        {
            CGPoint tempPoint = CGPointFromString(self.pointArray[i]);
            CGContextAddLineToPoint(contextCurrent, tempPoint.x, tempPoint.y);
        }
        [_blackColor setStroke];
        CGContextStrokePath(contextCurrent);
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.oldColor == _blackColor) {
        
    }
    else{
        [self.arrayLineConfig setValue:self.oldColor forKey:@"color"];
        [self.arrayLineConfig setValue:self.arrayLine forKey:@"arrayLine"];
        [self.arrayLineConfigArray addObject:self.arrayLineConfig];
        self.arrayLineConfig = [NSMutableDictionary dictionary];
        self.arrayLine = [NSMutableArray array];
    }
}

//画笔触摸的所有点
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //去除每一个点
    CGPoint myBeginPoint = [touch locationInView:self];
    NSString *strPoint = NSStringFromCGPoint(myBeginPoint);
    [self.pointArray addObject:strPoint];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    self.lineNum ++;
    [self addArray];
    if(self.oldColor != self.blackColor){
        self.oldColor = self.blackColor;
    }
}

#pragma mark --Getter
- (UIButton *)btnCancelDraw
{
    if(!_btnCancelDraw)
    {
        _btnCancelDraw = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCancelDraw.frame = CGRectMake(80,120, 50, 50);
        _btnCancelDraw.layer.cornerRadius = 25;
        _btnCancelDraw.backgroundColor = [UIColor blueColor];
        [_btnCancelDraw setTitle:@"撤销" forState:UIControlStateNormal];
        [_btnCancelDraw addTarget:self action:@selector(btnCanCelDrawClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancelDraw;
}
- (UIButton *)btnChangeColor
{
    if(!_btnChangeColor)
    {
        _btnChangeColor = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnChangeColor.frame = CGRectMake(20, 120, 50, 50);
        _btnChangeColor.layer.cornerRadius = 25;
        _btnChangeColor.alpha = 0.5;
        _btnChangeColor.backgroundColor = [UIColor redColor];
        [_btnChangeColor setTitle:@"改变" forState:UIControlStateNormal];
        [_btnChangeColor addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnChangeColor;
}
-(void)btnClicked{
    _blackColor = [UIColor colorWithRed:(float)rand()/RAND_MAX green:(float)rand()/RAND_MAX blue:(float)rand()/RAND_MAX alpha:1.0];
    
}
- (UISlider *)sliderWidth
{
    if(!_sliderWidth)
    {
        _sliderWidth = [[UISlider alloc]init];
        _sliderWidth.maximumValue = 50;
        _sliderWidth.minimumValue = 1;
        _sliderWidth.frame = CGRectMake(10, 80, [UIScreen mainScreen].bounds.size.width-20, 30);
        [_sliderWidth addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
        _sliderWidth.tag = 1000;
    }
    return _sliderWidth;
}
- (void) sliderValueChange:(UISlider *)sender
{
    if(sender.tag == 1000)
    {
        [self setNeedsDisplay];
    }
}
- (NSMutableArray *)arrayLine
{
    if(!_arrayLine)
    {
        _arrayLine = [NSMutableArray array];
    }
    return _arrayLine;
}
- (NSMutableArray *)pointArray
{
    if(!_pointArray)
    {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}
- (void) addArray
{
    if(self.pointArray!=nil)
    {
        
        [self.arrayLine addObject:self.pointArray];//将点得数组放入存到线的数组
        

    }
    self.pointArray = [NSMutableArray array];//将点数组清空
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

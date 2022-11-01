//
//  DrawView.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import "DrawView.h"
#import "DrawBoardModel.h"
#import "UpdateToMQTT.h"
#define SCREEN_SIZE self.frame.size

@interface DrawView()<UIGestureRecognizerDelegate,UpdateToMQTTDelegate>

//每次触摸结束前经过的点用来连成线
@property (nonatomic,strong) NSMutableArray *pointArray;

@property (nonatomic,strong) NSMutableArray *downPointArray;
@property (nonatomic,strong) NSMutableArray *downArrayLine;
@property (nonatomic, strong) DrawBoardModel  *downBoardModel;
@property (nonatomic, strong) NSMutableArray<DrawBoardModel *> *downPointArrayArray;
@property (nonatomic,strong) UIColor *downPointColor;


//保存线条的数组
@property (nonatomic,strong) NSMutableArray *arrayLine;

@property (nonatomic) int lineNum;

@property (nonatomic, strong) NSMutableArray<DrawBoardModel *> *drawBoardModelArray;

@property (nonatomic, strong) DrawBoardModel  *drawBoardModel;

@property (nonatomic,strong) NSMutableArray *graphicalPointArray;
//保存图形始末点的数组
@property (nonatomic,strong) NSMutableArray *graphicalArray;
@property (nonatomic, strong) NSMutableArray<DrawBoardGraphicalModel *> *drawBoardModelGraphicalArray;
@property (nonatomic, strong) DrawBoardGraphicalModel  *drawBoardModelGraphical;
@property (nonatomic) GraphicalState currentGraphical;

@property (nonatomic,strong) UISlider *sliderWidth;

@property (nonatomic,strong) NSMutableArray *imageRootViewArray;

@property (nonatomic) int imageRootViewId;
@property (nonatomic,strong) UIColor *currentColor;//画笔默认颜色
@property (nonatomic,copy) UIColor *oldColor;//画笔默认颜色

@property (nonatomic,strong) UIButton *btnCancelDraw;//撤销画笔

@property (nonatomic, strong) UIButton *btnChangeColor;//改变颜色


@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic) BOOL isEraserFlag;
@end

//  下面这行代码能够将view2  调整到父视图的最下面

//    [self.view sendSubviewToBack:view2];

@implementation DrawView
- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(nonnull UpdateToMQTT *)mqtt
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.sliderWidth];
        self.imageRootViewId = 0;
        self.currentPage = 1;
        self.isEraser = NO;
        self.isEraserFlag =NO;
        self.imageRootViewArray = [NSMutableArray array];
        self.downPointArray = [NSMutableArray array];
        self.downArrayLine = [NSMutableArray array];
        self.downBoardModel = [[DrawBoardModel alloc]init];
        self.downPointArrayArray = [NSMutableArray<DrawBoardModel *> array];
        self.graphicalPointArray = [NSMutableArray array];
        self.currentGraphical = LINE;
        //保存图形始末点的数组
        self.graphicalArray = [NSMutableArray array];
        self.drawBoardModelGraphicalArray = [NSMutableArray array];
        self.drawBoardModelGraphical = [[DrawBoardGraphicalModel alloc]init];
        self.userId = userId;
        self.roomId = roomId;
        _currentColor = [UIColor blackColor];
        self.oldColor = self.currentColor;
        self.lineNum = 0;
        self.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.btnChangeColor];
        self.drawBoardModelArray = [NSMutableArray<DrawBoardModel *> array];
        self.drawBoardModel = [[DrawBoardModel alloc]init];
        self.drawBoardModel.color = self.currentColor;
//        [self addSubview:self.btnCancelDraw];
        self.uploadMQTT = mqtt;
        self.uploadMQTT.updateToMQTTdelegate = self;
        
        self.imageScrolling = NO;
        
    }
    return self;
}

#pragma mark --updateToMQTTdelegate
- (void)getMassagePoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color currentPage:(int)currentPage{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    NSString *strPoint = NSStringFromCGPoint(point);
    [self.downPointArray addObject:strPoint];
    self.downPointColor = color;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}
-(void)getStartMassagePoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color currentPage:(int)currentPage{
    if ([userId isEqual:self.userId]){
        return;
    }
    if (self.currentPage != currentPage) {
        return;
    }
    
    self.downPointArray = [NSMutableArray array];
    if (color != self.downPointColor) {
        self.downBoardModel.color = self.downPointColor;
        self.downBoardModel.lineArray = self.downArrayLine;
        [self.downPointArrayArray addObject:self.downBoardModel];
        self.downBoardModel = [[DrawBoardModel alloc]init];
        self.downArrayLine = [NSMutableArray array];
        
    }
    NSString *strPoint = NSStringFromCGPoint(point);
    [self.downPointArray addObject:strPoint];
    self.downPointColor = color;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });

  
}
-(void)getEndMassagePoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color currentPage:(int)currentPage{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    NSString *strPoint = NSStringFromCGPoint(point);
    [self.downPointArray addObject:strPoint];
    [self.downArrayLine addObject:self.downPointArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
    
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

-(void)OKButtonClick:(UIButton *)but{
    NSLog(@"click %ld",but.tag);
    UIView *midView = self.imageRootViewArray[but.tag];
    midView.userInteractionEnabled = NO;
    
    self.imageRootViewArray[but.tag] = midView;
    [self sendSubviewToBack:midView];
}


#pragma  mark - 对外接口
-(void)addGraphical:(GraphicalState)graphical{
    [self saveArray];
    self.currentGraphical = graphical;
}
-(void)setDrawHidden:(BOOL)hidden{
    self.hidden = hidden;
    if (hidden == NO) {
        self.uploadMQTT.updateToMQTTdelegate = self;
    }
}
-(void)setIsEraser:(BOOL)isEraser{
    _isEraser = isEraser;
    [self setCurrentGraphical:LINE];
}
-(void)saveArray{
    if(self.graphicalArray.count>0){
        self.drawBoardModelGraphical.graphical = self.currentGraphical;
        self.drawBoardModelGraphical.graphicalArray = self.graphicalArray;
        [self.drawBoardModelGraphicalArray addObject:self.drawBoardModelGraphical];
        self.graphicalPointArray = [NSMutableArray array];
        //保存图形始末点的数组
        self.graphicalArray = [NSMutableArray array];
        self.drawBoardModelGraphical = [[DrawBoardGraphicalModel alloc]init];
    }
    if(self.arrayLine.count>0){
        if (self.isEraserFlag == YES) {
            
            self.drawBoardModel.color = [UIColor whiteColor];
        }else{
            
            self.drawBoardModel.color = self.oldColor;
        }
//        [self.arrayLine addObject:self.pointArray];
        self.drawBoardModel.lineArray = self.arrayLine;
        [self.drawBoardModelArray addObject:self.drawBoardModel];
        self.drawBoardModel = [[DrawBoardModel alloc]init];
        self.arrayLine = [NSMutableArray array];
        self.pointArray = [NSMutableArray array];
    }
}
-(void)setCurrentGraphical:(GraphicalState)currentGraphical{
    [self saveArray];
    _currentGraphical = currentGraphical;
    
 
}
//回滚
- (void) btnCanCelDrawClicked
{
    [self.arrayLine removeLastObject];
    [self setNeedsDisplay];
}
//设置线条颜色
-(void)setLineColor:(UIColor*)color{
    [self saveArray];
    self.currentColor = color;
    self.oldColor = color;
//    [self setNeedsDisplay];
}

- (UIColor*)getLineColor{
    return  self.currentColor;
}

-(void)deleteView{
    [self.pointArray removeAllObjects];
    [self.downPointArray removeAllObjects];
    [self.downArrayLine removeAllObjects];
    [self.downPointArrayArray removeAllObjects];
    [self.arrayLine removeAllObjects];
    [self.drawBoardModelArray removeAllObjects];
    self.downBoardModel = nil;
    self.drawBoardModel = nil;
    self.uploadMQTT.updateToMQTTdelegate = nil;
    self.uploadMQTT = nil;
    [self setNeedsDisplay];
    
}

#pragma mark --重新绘制
-(void)drawLineNow:(NSArray*)arr color : (UIColor *)color pencilwidth:(int)pencilwidth{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, pencilwidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);//设置拐角样式
    CGContextSetLineCap(context, kCGLineCapRound);//设置线头样式
    if(arr.count >0){
        
            //划线
        CGPoint startPoint = CGPointFromString(arr[0]);
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        for(int i = 1;i<arr.count;i++)
        {
            CGPoint tempPoint = CGPointFromString(arr[i]);
            CGContextAddLineToPoint(context, tempPoint.x, tempPoint.y);
        }
        [color setStroke];
        CGContextStrokePath(context);
    }
}
-(void)drawLineArrayNow:(NSArray*)arr color : (UIColor *)color pencilwidth:(int)pencilwidth{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, pencilwidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);//设置拐角样式
    CGContextSetLineCap(context, kCGLineCapRound);//设置线头样式
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
}
-(void)drawLineArrayGraphicalNow:(NSArray*)arr{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (DrawBoardGraphicalModel *model in arr) {
        if(model.graphical == CIRCULAR){
            for (CircularModel *cir in model.graphicalArray) {
                
                    [self drawCircular:cir];
            }
        }
    }
    
}
-(void)drawCurrentArrayGraphicalNow:(NSArray*)arr{
        if(self.currentGraphical == CIRCULAR){
            for (CircularModel *cir in arr) {
                [self drawCircular:cir];
            }
        }
}
-(void)drawCircular:(CircularModel *)cir{
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, cir.lineWidth);//线的宽度
    CGContextAddArc(context, cir.cencerPoint.x, cir.cencerPoint.y, cir.radius, 0, 2*M_PI, 0); //添加一个圆
    [cir.color setStroke];
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
}
- (void)drawRect:(CGRect)rect
{

    //网络传过来的保存的所有点
    for (DrawBoardModel *drawBoard in self.downPointArrayArray) {
        UIColor *color = drawBoard.color;
        NSArray *arr = drawBoard.lineArray;
        [self drawLineArrayNow:arr color:color pencilwidth:10];

    }
    
    [self drawLineArrayGraphicalNow:self.drawBoardModelGraphicalArray];
    [self drawCurrentArrayGraphicalNow:self.graphicalArray];
    //保存的所有点
    for (DrawBoardModel *drawBoard in self.drawBoardModelArray) {
        UIColor *color = drawBoard.color;
        NSArray *arr = drawBoard.lineArray;
        [self drawLineArrayNow:arr color:color pencilwidth:10];

    }
    
    
    //网络传过来的
    [self drawLineNow:self.downPointArray color:self.downPointColor pencilwidth:10];
    if (_isEraser == YES) {
        
        //尚未保存的
        [self drawLineArrayNow:self.arrayLine color:[UIColor whiteColor] pencilwidth:10];
        //当前正在画的
        [self drawLineNow:self.pointArray color:[UIColor whiteColor] pencilwidth:10];
    }else{
        
        //尚未保存的
        [self drawLineArrayNow:self.arrayLine color:self.currentColor pencilwidth:10];
        if(self.currentGraphical == LINE){
            //当前正在画的
            [self drawLineNow:self.pointArray color:self.currentColor pencilwidth:10];
        }else if(self.currentGraphical == CIRCULAR){
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 5.0);//线的宽度
            CGPoint startPoint = CGPointFromString(self.pointArray.firstObject);
            CGPoint endPoint = CGPointFromString(self.pointArray.lastObject);
            float width = fabs(startPoint.x-endPoint.x);
            float height = fabs(startPoint.y - endPoint.y);
            float length = sqrtf(width*width + height*height);
            CGContextAddArc(context, (startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2, length/2, 0, 2*M_PI, 0); //添加一个圆
            [self.currentColor setStroke];
            CGContextDrawPath(context, kCGPathStroke); //绘制路径
        }
    }
    //    UIFont *helvetica = [UIFont fontWithName:@"HelveticaNeue-Bold"size:30.0f];
    //    NSString *string =@"李先森";
    //
    //    [string drawAtPoint:CGPointMake(25,190)withFont:helvetica];
    //    [string drawAtPoint:CGPointMake(25,190)withAttributes:helvetica];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        if([touch.view isKindOfClass:[DrawView class]]){
            if(self.imageScrolling){
                [[self nextResponder]touchesBegan:touches withEvent:event];
                return;
            }
            UITouch *touch = [touches anyObject];
            
            //去除每一个点
            CGPoint myBeginPoint = [touch locationInView:self];
            if (self.isEraser == YES) {
                
                [self.uploadMQTT sendStartPoint:myBeginPoint userId:self.userId color:[UIColor whiteColor] roomId:self.roomId];
            }else{
                
                [self.uploadMQTT sendStartPoint:myBeginPoint userId:self.userId color:self.currentColor roomId:self.roomId];
            }
            
            if (self.isEraser == YES && self.isEraserFlag == NO) {
                self.isEraserFlag = YES;
                self.drawBoardModel.color = self.oldColor;
                self.drawBoardModel.lineArray = self.arrayLine;
                [self.drawBoardModelArray addObject:self.drawBoardModel];
                self.drawBoardModel = [[DrawBoardModel alloc]init];
                self.arrayLine = [NSMutableArray array];
            }
            else{
                if (self.isEraser == NO && self.isEraserFlag == YES) {
                    
                    self.drawBoardModel.color = [UIColor whiteColor];
                    self.drawBoardModel.lineArray = self.arrayLine;
                    [self.drawBoardModelArray addObject:self.drawBoardModel];
                    self.drawBoardModel = [[DrawBoardModel alloc]init];
                    self.arrayLine = [NSMutableArray array];
                    self.isEraserFlag = NO;
                    return;
                }else{
                }
            }
            if (self.isEraserFlag == NO) {
                
                if ([self.oldColor isEqual:self.currentColor]) {
                    
                }
                else{
                    self.drawBoardModel.color = self.oldColor;
                    self.drawBoardModel.lineArray = self.arrayLine;
                    [self.drawBoardModelArray addObject:self.drawBoardModel];
                    self.drawBoardModel = [[DrawBoardModel alloc]init];
                    self.arrayLine = [NSMutableArray array];
                    if(self.oldColor != self.currentColor){
                        self.oldColor = self.currentColor;
                    }
                }
            }
            
        }
    }
}

//画笔触摸的所有点
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if(![touch.view isKindOfClass:[DrawView class]]){
            
            return;
            
        }
    }
    if(self.imageScrolling){
        [[self nextResponder]touchesMoved:touches withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    //去除每一个点
    CGPoint myBeginPoint = [touch locationInView:self];
    NSString *strPoint = NSStringFromCGPoint(myBeginPoint);
    [self.pointArray addObject:strPoint];
    if (_isEraser) {
        
        [self.uploadMQTT sendPoint:myBeginPoint userId:self.userId color:[UIColor whiteColor] roomId:self.roomId];
    }else{
        
        [self.uploadMQTT sendPoint:myBeginPoint userId:self.userId color:self.currentColor roomId:self.roomId];
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if(![touch.view isKindOfClass:[DrawView class]]){
            
            return;
            
        }
    }
    if(self.imageScrolling){
        [[self nextResponder]touchesEnded:touches withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    //去除每一个点
    CGPoint myBeginPoint = [touch locationInView:self];
    if (self.isEraser == YES) {
        
        [self.uploadMQTT sendEndPoint:myBeginPoint userId:self.userId color:[UIColor whiteColor] roomId:self.roomId];
    }else{
        
        [self.uploadMQTT sendEndPoint:myBeginPoint userId:self.userId color:self.currentColor roomId:self.roomId];
    }
    self.lineNum ++;
    [self addArray];

    
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
    _currentColor = [UIColor colorWithRed:(float)rand()/RAND_MAX green:(float)rand()/RAND_MAX blue:(float)rand()/RAND_MAX alpha:1.0];
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
        if (self.currentGraphical == LINE) {
            
            [self.arrayLine addObject:self.pointArray];//将点得数组放入存到线的数组
        }
        else if (self.currentGraphical == CIRCULAR){
            CircularModel *cir = [[CircularModel alloc]init];
            CGPoint startPoint = CGPointFromString(self.pointArray.firstObject);
            CGPoint endPoint = CGPointFromString(self.pointArray.lastObject);
            float width = fabs(startPoint.x-endPoint.x);
            float height = fabs(startPoint.y - endPoint.y);
            float length = sqrtf(width*width + height*height);
            cir.cencerPoint = CGPointMake((startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2);
            cir.radius = length/2;
            cir.color = self.currentColor;
            cir.lineWidth = 2.0;
            [self.graphicalArray addObject:cir];
        }
        

    }
    self.pointArray = [NSMutableArray array];//将点数组清空
}
-(void)dealloc{
    NSLog(@"drawView Dealloc");
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

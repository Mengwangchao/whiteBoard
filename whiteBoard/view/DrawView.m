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
@property (nonatomic,strong) NSMutableArray *downGraphicalPointArray;
//保存图形始末点的数组
@property (nonatomic,strong) NSMutableArray *downGraphicalArray;
@property (nonatomic, strong) NSMutableArray<DrawBoardGraphicalModel *> *downDrawBoardModelGraphicalArray;
@property (nonatomic, strong) DrawBoardGraphicalModel  *downDrawBoardModelGraphical;
@property (nonatomic) GraphicalState downGraphical;

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

@property (nonatomic) float lineWidth;
@property (nonatomic) float downLineWidth;
@property (nonatomic,strong) UIButton *btnCancelDraw;//撤销画笔

@property (nonatomic, strong) UIButton *btnChangeColor;//改变颜色


@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *downUserId;
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
        self.lineWidth = 5.0;
        self.downLineWidth = 5.0;
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
        self.downGraphicalPointArray  = [NSMutableArray array];
        //保存图形始末点的数组
        self.downGraphicalArray = [NSMutableArray array];
        self.downDrawBoardModelGraphicalArray = [NSMutableArray array];
        self.downDrawBoardModelGraphical = [[DrawBoardGraphicalModel alloc]init];
        self.downGraphical = LINE;
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
- (void)getMassagePoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color currentPage:(int)currentPage graphical:(int)graphical lineWidth:(float)lineWidth{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    NSString *strPoint = NSStringFromCGPoint(point);
    [self.downPointArray addObject:strPoint];
    self.downPointColor = color;
    self.downLineWidth = lineWidth;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}
-(void)getStartMassagePoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color currentPage:(int)currentPage graphical:(int)graphical lineWidth:(float)lineWidth{
    if ([userId isEqual:self.userId]){
        return;
    }
    if (self.currentPage != currentPage) {
        return;
    }
    
    if(self.downPointArray.count>0){

        [self saveDownGrraphical:self.downGraphical];
    }
    self.downPointArray = [NSMutableArray array];
    if (![userId isEqual: self.downUserId] ||![color isEqual: self.downPointColor] || lineWidth != self.downLineWidth ||(self.downGraphical != (GraphicalState)graphical)) {

        if(self.downArrayLine.count>0){
            self.downBoardModel.lineWidth = self.downLineWidth;
            self.downBoardModel.userId = self.downUserId;
            self.downBoardModel.color = self.downPointColor;
            self.downBoardModel.lineArray = self.downArrayLine;
            if(self.downBoardModel.userId ==nil){
                self.downBoardModel.userId = self.userId;
            }
            [self.downPointArrayArray addObject:self.downBoardModel];
            self.downBoardModel = [[DrawBoardModel alloc]init];
            self.downArrayLine = [NSMutableArray array];
        }
        if(self.downGraphicalArray.count>0){
            
            self.downDrawBoardModelGraphical.graphicalArray = self.downGraphicalArray;
            self.downDrawBoardModelGraphical.graphical = self.downGraphical;
            self.downDrawBoardModelGraphical.userId = self.downUserId;
            [self.downDrawBoardModelGraphicalArray addObject:self.downDrawBoardModelGraphical];
            self.downDrawBoardModelGraphical = [[DrawBoardGraphicalModel alloc]init];
            self.downGraphicalArray = [NSMutableArray array];
        }
        
        
    }else{
        
    }
    self.downGraphical = (GraphicalState)graphical;
    NSString *strPoint = NSStringFromCGPoint(point);
    [self.downPointArray addObject:strPoint];
    self.downPointColor = color;
    self.downLineWidth = lineWidth;
    if(userId !=nil){
        self.downUserId = userId;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });

  
}
-(void)getEndMassagePoint:(CGPoint)point userId:(NSString *)userId color:(UIColor *)color currentPage:(int)currentPage graphical:(int)graphical lineWidth:(float)lineWidth{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    NSString *strPoint = NSStringFromCGPoint(point);
    [self.downPointArray addObject:strPoint];
    if((GraphicalState)graphical == LINE){
        [self.downArrayLine addObject:self.downPointArray];
    }
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


-(void)OKButtonClick:(UIButton *)but{
    NSLog(@"click %ld",but.tag);
    UIView *midView = self.imageRootViewArray[but.tag];
    midView.userInteractionEnabled = NO;
    
    self.imageRootViewArray[but.tag] = midView;
    [self sendSubviewToBack:midView];
}


#pragma  mark - 对外接口
-(void)addGraphical:(GraphicalState)graphical{
//    [self saveArray];
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
        self.drawBoardModel.lineWidth = self.lineWidth;
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

-(void)redoClick:(GraphicalState)graphical color:(UIColor*)color width:(float)width array:(NSArray *)array userId:(NSString *)userId{
    [self saveArray];
    if(graphical == LINE){
        DrawBoardModel *draw = [[DrawBoardModel alloc]init];
        draw.color = color;
        draw.lineWidth = width;
        NSMutableArray *ar = [NSMutableArray array];
        [ar addObject:array];
        draw.lineArray = ar;
        draw.userId = userId;
        [self.drawBoardModelArray addObject:draw];
    }
    else{
        DrawBoardGraphicalModel *draw = [[DrawBoardGraphicalModel alloc]init];
        draw.graphical = graphical;
        draw.graphicalArray = array;
        draw.userId = userId;
        [self.drawBoardModelGraphicalArray addObject:draw];
    }
    [self setNeedsDisplay];
}
-(void)undoNetwork:(BOOL)isLine userId:(NSString *)userId{
    if (isLine) {
        if(self.downArrayLine.count>0){
            self.downPointArray = [NSMutableArray array];
            [self.downArrayLine removeLastObject];
        }else{
           DrawBoardModel *model = [self.downPointArrayArray lastObject];
            
            NSMutableArray *arr = model.lineArray;
            unsigned long num = self.downPointArrayArray.count-1;
            while (model.lineArray.count<=0||![model.userId isEqual:userId]) {
                if(num<0){
                    return;
                }
                if(![model.userId isEqual:userId]){
                    num --;
                    model = self.downPointArrayArray[num];
                }else{
                    [self.downPointArrayArray removeObject:model];
                    model = self.downPointArrayArray[num];
                    arr = model.lineArray;
                    if(self.downPointArrayArray.count<=0){
                        return;
                    }
                    num--;
                }
            }
            [arr removeLastObject];
            
            if(arr.count==0){
                [self.downPointArrayArray removeLastObject];
            }else{
                model.lineArray = arr;
                [self.downPointArrayArray removeLastObject];
                [self.downPointArrayArray addObject:model];
            }
        }
        
    }else{
        if(self.downPointArray.count>0){
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:self.downPointArray.firstObject];
            [arr addObject:self.downPointArray.lastObject];
            self.downPointArray = [NSMutableArray array];
        }
        else if(self.downGraphicalArray.count>0){
            [self.downGraphicalArray removeLastObject];
        }else{
            DrawBoardGraphicalModel *model = self.downDrawBoardModelGraphicalArray.lastObject;
            NSMutableArray *arr = model.graphicalArray;
            unsigned long num = self.downDrawBoardModelGraphicalArray.count-1;
            while (model.graphicalArray.count<=0||![model.userId isEqual:userId]) {
                if(num<0){
                    return;
                }
                if(![model.userId isEqual:userId]){
                    num --;
                    model = self.downDrawBoardModelGraphicalArray[num];
                }else{
                    [self.downDrawBoardModelGraphicalArray removeObject:model];
                    model = self.downDrawBoardModelGraphicalArray[num];
                    arr = model.graphicalArray;
                    if(self.downDrawBoardModelGraphicalArray.count<=0){
                        return;
                    }
                    num--;
                }
            }
            [arr removeLastObject];
            if(arr.count==0){
                [self.downDrawBoardModelGraphicalArray removeLastObject];
            }else{
                model.graphicalArray = arr;
                [self.downDrawBoardModelGraphicalArray removeLastObject];
                [self.downDrawBoardModelGraphicalArray addObject:model];
            }
        }
    }
    [self setNeedsDisplay];
}
//回滚
- (void)undoClick:(BOOL)isLine
{
    [self saveArray];
    if(isLine){
        if(self.pointArray.count>0){
            if(self.controldelegate !=nil && [self.controldelegate respondsToSelector:@selector(deleteGraphical:color:lineWidth:array:userId:)]){
                [self.controldelegate deleteGraphical:LINE color:self.currentColor lineWidth:self.lineWidth array:self.pointArray userId:self.userId];
            }
            self.pointArray = [NSMutableArray array];
        }
        else if(self.arrayLine.count>0){
            if(self.controldelegate !=nil && [self.controldelegate respondsToSelector:@selector(deleteGraphical:color:lineWidth:array:userId:)]){
                [self.controldelegate deleteGraphical:LINE color:self.currentColor lineWidth:self.lineWidth array:self.arrayLine.lastObject userId:self.userId];
            }
            [self.arrayLine removeLastObject];
        }else{
           DrawBoardModel *model = [self.drawBoardModelArray lastObject];
            NSMutableArray *arr = model.lineArray;
            while (model.lineArray.count<=0) {
                [self.drawBoardModelArray removeLastObject];
                model = [self.drawBoardModelArray lastObject];
                arr = model.lineArray;
                if(self.drawBoardModelArray.count<=0){
                    return;
                }
            }
            
            if(self.controldelegate !=nil && [self.controldelegate respondsToSelector:@selector(deleteGraphical:color:lineWidth:array:userId:)]){
                [self.controldelegate deleteGraphical:LINE color:model.color lineWidth:model.lineWidth array:[arr lastObject] userId:self.userId];
            }
            [arr removeLastObject];
            if(arr.count==0){
                [self.drawBoardModelArray removeLastObject];
            }else{
                model.lineArray = arr;
                [self.drawBoardModelArray removeLastObject];
                [self.drawBoardModelArray addObject:model];
            }
        }
        
    }else{
        if(self.pointArray.count>0){
            NSMutableArray *arr = [NSMutableArray array];
            [arr addObject:self.pointArray.firstObject];
            [arr addObject:self.pointArray.lastObject];
            if(self.controldelegate !=nil && [self.controldelegate respondsToSelector:@selector(deleteGraphical:color:lineWidth:array:userId:)]){
                [self.controldelegate deleteGraphical:self.currentGraphical color:self.currentColor lineWidth:self.lineWidth array:arr  userId:self.userId];
            }
            self.pointArray = [NSMutableArray array];
        }
        else if(self.graphicalArray.count>0){
            if(self.controldelegate !=nil && [self.controldelegate respondsToSelector:@selector(deleteGraphical:color:lineWidth:array:userId:)]){
                [self.controldelegate deleteGraphical:self.currentGraphical color:self.currentColor lineWidth:self.lineWidth array:self.graphicalArray.lastObject  userId:self.userId];
            }
            [self.graphicalArray removeLastObject];
        }else{
            DrawBoardGraphicalModel *model = self.drawBoardModelGraphicalArray.lastObject;
            NSMutableArray *arr = model.graphicalArray;
            NSMutableArray *delArr = [NSMutableArray array];
            [delArr addObject:arr.lastObject];
            [arr removeLastObject];
            
            if(self.controldelegate !=nil && [self.controldelegate respondsToSelector:@selector(deleteGraphical:color:lineWidth:array: userId:)]){
                [self.controldelegate deleteGraphical:model.graphical color:nil lineWidth:0 array:delArr userId:self.userId];
            }
            if(arr.count==0){
                [self.drawBoardModelGraphicalArray removeLastObject];
            }else{
                model.graphicalArray = arr;
                [self.drawBoardModelGraphicalArray removeLastObject];
                [self.drawBoardModelGraphicalArray addObject:model];
            }
        }
    }
    [self setNeedsDisplay];
}
//设置线条颜色
-(void)setLineColor:(UIColor*)color{
    [self saveArray];
    self.currentColor = color;
    self.oldColor = color;
//    [self setNeedsDisplay];
}
-(void)setLineWith:(float)lineWith{
    [self saveArray];
    self.lineWidth = lineWith;
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
    [self.graphicalArray removeAllObjects];
    [self.drawBoardModelGraphicalArray removeAllObjects];
    [self.graphicalPointArray removeAllObjects];
    [self.downGraphicalArray removeAllObjects];
    [self.downGraphicalPointArray removeAllObjects];
    [self.downDrawBoardModelGraphicalArray removeAllObjects];
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
    for (DrawBoardGraphicalModel *model in arr) {
        if(model.graphical == CIRCULAR){
            for (CircularModel *cir in model.graphicalArray) {
                
                    [self drawCircular:cir];
            }
        }
        else if(model.graphical == RECTANGLE){
            for (RectangleModel *rect in model.graphicalArray) {
                [self drawRectangle:rect];
            }
        }
        else if(model.graphical == ROUNDED_RECTANGLE){
            for (RoundedRectangleModel *rect in model.graphicalArray) {
                [self drawRoundedRectangle:rect];
            }
        }
        else if (model.graphical == TRIANGLE){
            for (TriangleModel *rect in model.graphicalArray) {
                [self drawTriangleModel:rect];
            }
        }
    }
    
}

-(void)drawCurrentArrayGraphicalNow:(NSArray*)arr graphical:(GraphicalState)graphical{
    if(graphical == CIRCULAR){
        for (CircularModel *cir in arr) {
            [self drawCircular:cir];
        }
    }
    else if(graphical == RECTANGLE){
        for (RectangleModel *rect in arr) {
            [self drawRectangle:rect];
        }
    }
    else if(graphical == ROUNDED_RECTANGLE){
        for (RoundedRectangleModel *rect in arr) {
            [self drawRoundedRectangle:rect];
        }
    }
    else if(graphical == TRIANGLE){
        for (TriangleModel *rect in arr) {
            [self drawTriangleModel:rect];
        }
    }
}
-(void)drawTriangleModel:(TriangleModel *)triangleModel{
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(triangleModel.startPoint.x, triangleModel.startPoint.y);//坐标1
    sPoints[1] =CGPointMake((triangleModel.startPoint.x+triangleModel.endPoint.x)/2, triangleModel.endPoint.y);//坐标2
    sPoints[2] =CGPointMake(triangleModel.endPoint.x, triangleModel.startPoint.y);//坐标3
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, triangleModel.lineWidth);//线的宽度
    CGContextAddLines(context, sPoints, 3);
    CGContextClosePath(context);
    CGContextSetStrokeColorWithColor(context, triangleModel.color.CGColor);//线框颜色
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
}
-(void)drawRectangle:(RectangleModel*)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, rect.lineWidth);//线的宽度
    CGContextAddRect(context, CGRectMake(rect.startPoint.x, rect.startPoint.y, rect.endPoint.x-rect.startPoint.x, rect.endPoint.y-rect.startPoint.y));
    CGContextSetStrokeColorWithColor(context, rect.color.CGColor);//线框颜色
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
}
-(void)drawRoundedRectangle:(RoundedRectangleModel*)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, rect.lineWidth);//线的宽度
    CGContextSetLineJoin(context, kCGLineJoinRound);//设置拐角样式
    
    if(rect.endPoint.y-rect.startPoint.y>0){
        CGContextMoveToPoint(context, rect.startPoint.x, rect.startPoint.y+10);
    }else{
        CGContextMoveToPoint(context, rect.startPoint.x, rect.startPoint.y-10);
    }
    CGContextAddArcToPoint(context, rect.startPoint.x, rect.endPoint.y, rect.endPoint.x, rect.endPoint.y, 10);
    CGContextAddArcToPoint(context, rect.endPoint.x, rect.endPoint.y, rect.endPoint.x, rect.startPoint.y, 10);
    CGContextAddArcToPoint(context, rect.endPoint.x, rect.startPoint.y, rect.startPoint.x, rect.startPoint.y, 10);
    CGContextAddArcToPoint(context, rect.startPoint.x, rect.startPoint.y, rect.startPoint.x, rect.endPoint.y, 10);
//    [rect.color setStroke];
    CGContextSetStrokeColorWithColor(context, rect.color.CGColor);//线框颜色
    CGContextDrawPath(context, kCGPathStroke); //绘制路径

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
        [self drawLineArrayNow:arr color:color pencilwidth:drawBoard.lineWidth];

    }
    
    [self drawLineArrayGraphicalNow:self.drawBoardModelGraphicalArray];
    [self drawLineArrayGraphicalNow:self.downDrawBoardModelGraphicalArray];
    [self drawCurrentArrayGraphicalNow:self.downGraphicalArray graphical:self.downGraphical];
    //保存的所有点
    for (DrawBoardModel *drawBoard in self.drawBoardModelArray) {
        UIColor *color = drawBoard.color;
        NSArray *arr = drawBoard.lineArray;
        [self drawLineArrayNow:arr color:color pencilwidth:drawBoard.lineWidth];

    }
    
    
    //网络传过来的
    if(self.downGraphical == LINE){
        
        [self drawLineArrayNow:self.downArrayLine color:self.downPointColor pencilwidth:self.downLineWidth];
        [self drawLineNow:self.downPointArray color:self.downPointColor pencilwidth:self.downLineWidth];
    }else{
        
        [self drawGraphical:self.downGraphical color:self.downPointColor width:self.downLineWidth point:self.downPointArray];
    }
    if (_isEraser == YES) {
        
        //尚未保存的
        [self drawLineArrayNow:self.arrayLine color:[UIColor whiteColor] pencilwidth:self.lineWidth];
        //当前正在画的
        [self drawLineNow:self.pointArray color:[UIColor whiteColor] pencilwidth:self.lineWidth];
    }else{
        
        [self drawCurrentArrayGraphicalNow:self.graphicalArray graphical:self.currentGraphical];
        //尚未保存的
        [self drawLineArrayNow:self.arrayLine color:self.currentColor pencilwidth:self.lineWidth];
        if(self.currentGraphical == LINE){
            //当前正在画的
            [self drawLineNow:self.pointArray color:self.currentColor pencilwidth:self.lineWidth];
        }else{
            [self drawGraphical:self.currentGraphical color:self.currentColor width:self.lineWidth point:self.pointArray];
        }
    }
    //    UIFont *helvetica = [UIFont fontWithName:@"HelveticaNeue-Bold"size:30.0f];
    //    NSString *string =@"李先森";
    //
    //    [string drawAtPoint:CGPointMake(25,190)withFont:helvetica];
    //    [string drawAtPoint:CGPointMake(25,190)withAttributes:helvetica];
    
}
-(void)drawGraphical:(GraphicalState)graphical color:(UIColor*)color width:(float)fontWidth point:(NSMutableArray *)arr{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, fontWidth);//线的宽度
    CGPoint startPoint = CGPointFromString(arr.firstObject);
    CGPoint endPoint = CGPointFromString(arr.lastObject);
    float width = fabs(startPoint.x-endPoint.x);
    float height = fabs(startPoint.y - endPoint.y);
    if(graphical == CIRCULAR){
        float length = sqrtf(width*width + height*height);
        CGContextAddArc(context, (startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2, length/2, 0, 2*M_PI, 0); //添加一个圆
    }
    else if(graphical == RECTANGLE){
        
//        CGContextStrokeRect(context,CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y));//画方框
        CGContextAddRect(context, CGRectMake(startPoint.x, startPoint.y, endPoint.x-startPoint.x, endPoint.y-startPoint.y));
    }
    else if (graphical == ROUNDED_RECTANGLE){
        
        if(endPoint.y-startPoint.y>0){
            CGContextMoveToPoint(context, startPoint.x, startPoint.y+10);
        }else{
            CGContextMoveToPoint(context, startPoint.x, startPoint.y-10);
        }
        CGContextAddArcToPoint(context, startPoint.x, endPoint.y, endPoint.x, endPoint.y, 10);
        CGContextAddArcToPoint(context, endPoint.x, endPoint.y, endPoint.x, startPoint.y, 10);
        CGContextAddArcToPoint(context, endPoint.x, startPoint.y, startPoint.x, startPoint.y, 10);
        CGContextAddArcToPoint(context, startPoint.x, startPoint.y, startPoint.x, endPoint.y, 10);
        
    }
    else if (graphical == TRIANGLE){
        CGPoint sPoints[3];//坐标点
        sPoints[0] =CGPointMake(startPoint.x, startPoint.y);//坐标1
        sPoints[1] =CGPointMake((startPoint.x+endPoint.x)/2, endPoint.y);//坐标2
        sPoints[2] =CGPointMake(endPoint.x, startPoint.y);//坐标3
        CGContextAddLines(context, sPoints, 3);
        CGContextClosePath(context);
    }
//    [color setStroke];
    CGContextSetStrokeColorWithColor(context, color.CGColor);//线框颜色
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
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
                
                [self.uploadMQTT sendStartPoint:myBeginPoint userId:self.userId color:[UIColor whiteColor] roomId:self.roomId graphical:(int)LINE lineWidth:self.lineWidth];
            }else{
                
                [self.uploadMQTT sendStartPoint:myBeginPoint userId:self.userId color:self.currentColor roomId:self.roomId graphical:(int)self.currentGraphical lineWidth:self.lineWidth];
            }
            
            if (self.isEraser == YES && self.isEraserFlag == NO) {
                self.isEraserFlag = YES;
                self.drawBoardModel.lineWidth = self.lineWidth;
                self.drawBoardModel.color = self.oldColor;
                self.drawBoardModel.lineArray = self.arrayLine;
                [self.drawBoardModelArray addObject:self.drawBoardModel];
                self.drawBoardModel = [[DrawBoardModel alloc]init];
                self.arrayLine = [NSMutableArray array];
            }
            else{
                if (self.isEraser == NO && self.isEraserFlag == YES) {
                    self.drawBoardModel.lineWidth = self.lineWidth;
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
                    self.drawBoardModel.lineWidth = self.lineWidth;
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
        
        [self.uploadMQTT sendPoint:myBeginPoint userId:self.userId color:[UIColor whiteColor] roomId:self.roomId graphical:(int)LINE lineWidth:self.lineWidth];
    }else{
        
        [self.uploadMQTT sendPoint:myBeginPoint userId:self.userId color:self.currentColor roomId:self.roomId graphical:(int)self.currentGraphical lineWidth:self.lineWidth];
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
        
        [self.uploadMQTT sendEndPoint:myBeginPoint userId:self.userId color:[UIColor whiteColor] roomId:self.roomId graphical:(int)LINE lineWidth:self.lineWidth];
    }else{
        
        [self.uploadMQTT sendEndPoint:myBeginPoint userId:self.userId color:self.currentColor roomId:self.roomId graphical:(int)self.currentGraphical lineWidth:self.lineWidth];
    }
    if(self.controldelegate != nil && [self.controldelegate respondsToSelector:@selector(addGraphicalFromDelegate:)]){
        [self.controldelegate addGraphicalFromDelegate:self.currentGraphical];
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
        else {
            [self saveGrraphical:self.currentGraphical];
        }
        

    }
    self.pointArray = [NSMutableArray array];//将点数组清空
}
-(void)saveGrraphical:(GraphicalState)graphical{
    CGPoint startPoint = CGPointFromString(self.pointArray.firstObject);
    CGPoint endPoint = CGPointFromString(self.pointArray.lastObject);
    float width = fabs(startPoint.x-endPoint.x);
    float height = fabs(startPoint.y - endPoint.y);
    if (graphical == CIRCULAR){
        CircularModel *cir = [[CircularModel alloc]init];
        float length = sqrtf(width*width + height*height);
        cir.cencerPoint = CGPointMake((startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2);
        cir.radius = length/2;
        cir.color = self.currentColor;
        
        cir.lineWidth = self.lineWidth;
        [self.graphicalArray addObject:cir];
    }
    else if(graphical == RECTANGLE){
        RectangleModel *rect = [[RectangleModel alloc]init];
        rect.endPoint = endPoint;
        rect.startPoint = startPoint;
        rect.color = self.currentColor;
        rect.lineWidth = self.lineWidth;
        [self.graphicalArray addObject:rect];
    }
    else if(graphical == ROUNDED_RECTANGLE){
        RoundedRectangleModel *rect = [[RoundedRectangleModel alloc]init];
        rect.endPoint = endPoint;
        rect.startPoint = startPoint;
        rect.color = self.currentColor;
        rect.lineWidth = self.lineWidth;
        [self.graphicalArray addObject:rect];
    }
    else if(graphical == TRIANGLE){
        TriangleModel *rect = [[TriangleModel alloc]init];
        rect.endPoint = endPoint;
        rect.startPoint = startPoint;
        rect.color = self.currentColor;
        rect.lineWidth = self.lineWidth;
        [self.graphicalArray addObject:rect];
    }
}
-(void)saveDownGrraphical:(GraphicalState)graphical{
    CGPoint startPoint = CGPointFromString(self.downPointArray.firstObject);
    CGPoint endPoint = CGPointFromString(self.downPointArray.lastObject);
    float width = fabs(startPoint.x-endPoint.x);
    float height = fabs(startPoint.y - endPoint.y);
    if(self.downGraphical == CIRCULAR){
        CircularModel *cir = [[CircularModel alloc]init];
        float length = sqrtf(width*width + height*height);
        cir.cencerPoint = CGPointMake((startPoint.x+endPoint.x)/2, (startPoint.y+endPoint.y)/2);
        cir.radius = length/2;
        cir.color = self.downPointColor;
        cir.lineWidth = self.lineWidth;
        [self.downGraphicalArray addObject:cir];
    }
    else if(graphical == RECTANGLE){
        RectangleModel *rect = [[RectangleModel alloc]init];
        rect.endPoint = endPoint;
        rect.startPoint = startPoint;
        rect.color = self.downPointColor;
        rect.lineWidth = self.lineWidth;
        [self.downGraphicalArray addObject:rect];
    }
    else if(graphical == ROUNDED_RECTANGLE){
        RoundedRectangleModel *rect = [[RoundedRectangleModel alloc]init];
        rect.endPoint = endPoint;
        rect.startPoint = startPoint;
        rect.color = self.downPointColor;
        rect.lineWidth = self.lineWidth;
        [self.downGraphicalArray addObject:rect];
    }
    else if(graphical == TRIANGLE){
        TriangleModel *rect = [[TriangleModel alloc]init];
        rect.endPoint = endPoint;
        rect.startPoint = startPoint;
        rect.color = self.downPointColor;
        rect.lineWidth = self.lineWidth;
        [self.downGraphicalArray addObject:rect];
    }
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

//
//  DrawViewAndImageView.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/31.
//

#import "DrawViewAndImageView.h"
#import "ImageViewOfDrawView.h"
@interface DrawViewAndImageView()<ImageViewOfDrawViewDelegate,ImageMQTTDelegate,controlDelegate>
@property (nonatomic , strong)DrawView *rootDrawView;
@property (nonatomic , strong)ImageViewOfDrawView *imageView;
@property (nonatomic , strong)ImageViewOfDrawView *downImageView;
@property (nonatomic , strong)NSMutableArray<NSDictionary*> * imageViewArray;
@property (nonatomic , strong)NSMutableArray * deleteArray;
@property (nonatomic , strong)NSMutableArray * addArray;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic) BOOL imageScrolling;
@property (nonatomic) CGPoint imageStartPoint;
@property (nonatomic) CGPoint downImageStartPoint;
@property (nonatomic) int  imageNum;
@property (nonatomic) int  downImageNum;
@end
@implementation DrawViewAndImageView
- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.uploadMQTT = mqtt;
        self.userId = userId;
        mqtt.imageMQTTdelegate = self;
        self.roomId = roomId;
        self.currentPage = 1;
        self.imageNum =0;
        self.deleteArray = [NSMutableArray array];
        self.addArray = [NSMutableArray array];
        self.imageScrolling = NO;
        self.imageViewArray = [NSMutableArray array];
        self.rootDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) userId:userId roomId:roomId MQTT:mqtt];
        self.rootDrawView.controldelegate = self;
        [self addSubview:self.rootDrawView];
    }
    return self;
}


#pragma mark - 对外接口
-(void)undoClick:(BOOL)isLine{
    if(self.addArray.count>0){
        int undoId = [[self.addArray lastObject] intValue];
        if(undoId!= -1){
            GraphicalState gra = (GraphicalState)undoId;
            
            if(gra == LINE){
                
                [self.rootDrawView undoClick:YES];
            }else{
                [self.rootDrawView undoClick:NO];
            }
            [self.addArray removeLastObject];
            
        }else{
//            self.deleteArray addObject:self.imag
            for (NSDictionary *dic in self.imageViewArray) {
                NSString *userId = dic[@"userId"];
                if([self.userId isEqual:userId]){
                    ImageViewOfDrawView *image = dic[@"imageView"];
                    [image removeFromSuperview];
                    [self.imageViewArray removeObject:dic];
                    [self.addArray removeLastObject];
                    break;
                    
                }
            }
        }
    }
}
-(void)addImageView:(UIImage *)image imageId:(int)imageId{
    
    ImageViewOfDrawView *imageView = [[ImageViewOfDrawView alloc]initWithFrame:CGRectMake(0, 0, 0 , 0) image:image imageId:imageId userId:self.userId roomId:self.roomId MQTT:self.uploadMQTT];
    imageView.tag = imageId;
    [self addSubview:imageView];
    imageView.imageViewOfDrawViewDelegate = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.userId forKey:@"userId"];
    [dic setValue:imageView forKey:@"imageView"];
    [self.imageViewArray addObject:dic];
    self.imageNum = (int)self.imageViewArray.count;
    imageView.imageNum = self.imageNum;
    self.imageScrolling = YES;
    self.imageView = imageView;
    self.rootDrawView.imageScrolling = YES;
    [self.addArray addObject:[NSString stringWithFormat:@"-1"]];
    
}
-(void)addDownImageView:(UIImage *)image imageId:(int)imageId userId:(NSString *)userId{
    
    ImageViewOfDrawView *imageView = [[ImageViewOfDrawView alloc]initWithFrame:CGRectMake(0, 0, 0 , 0) image:image imageId:imageId userId:self.userId roomId:self.roomId MQTT:self.uploadMQTT];
    imageView.tag = imageId;
    [self addSubview:imageView];
    imageView.imageViewOfDrawViewDelegate = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:userId forKey:@"userId"];
    [dic setValue:imageView forKey:@"imageView"];
    [self.imageViewArray addObject:dic];
    self.downImageNum = (int)self.imageViewArray.count;
    imageView.imageNum = self.downImageNum;
    self.downImageView = imageView;
    
}
-(void)addGraphical:(GraphicalState)graphical{
    [self.rootDrawView addGraphical:graphical];
}
-(void)okButtonClick:(ImageViewOfDrawView *)view sender:(UIButton *)sender imageNum:(int)imageNum{
    sender.hidden = YES;
    view.userInteractionEnabled = NO;
    [self sendSubviewToBack:view];
}
-(void)setDrawHidden:(BOOL)hidden{
    self.hidden = hidden;
    [self.rootDrawView setDrawHidden:hidden];
}
- (void)setLineColor:(UIColor *)color{
    [self.rootDrawView setLineColor:color];
}
- (UIColor*)getLineColor{
    return [self.rootDrawView getLineColor];
}
-(void)deleteView{
    [self.rootDrawView deleteView];
}
-(void)setLineWith:(float)lineWith{
    [self.rootDrawView setLineWith:lineWith];
}
-(void)setIsEraser:(BOOL)isEraser{
    if (_isEraser != isEraser) {
        _isEraser = isEraser;
        self.rootDrawView.isEraser = isEraser;
    }
}
-(void)setCurrentPage:(int)currentPage{
    _currentPage = currentPage;
    self.imageView.currentPage = currentPage;
    self.rootDrawView.currentPage = currentPage;
}
-(void)setUploadMQTT:(UpdateToMQTT *)uploadMQTT{
    _uploadMQTT = uploadMQTT;
    self.rootDrawView.uploadMQTT = uploadMQTT;
}
#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(self.imageScrolling){
        CGPoint startPoint = [touch locationInView:self];
        self.imageStartPoint = startPoint;
        [self.uploadMQTT sendAddImageStart:self.roomId userId:self.userId imageId:(int)self.imageView.tag point:startPoint imageNum:self.imageNum];
        self.imageView.frame = CGRectMake(startPoint.x, startPoint.y, 0, 0);
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(self.imageScrolling){
        CGPoint point = [touch locationInView:self];
        [self.uploadMQTT sendAddImageScrolling:self.roomId userId:self.userId imageId:(int)self.imageView.tag point:point imageNum:self.imageNum];
       self.imageView.frame = [self getImageFrame:point strartPoint:self.imageStartPoint view:self.imageView];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(self.imageScrolling){
        CGPoint point = [touch locationInView:self];
        [self.uploadMQTT sendAddImageEnd:self.roomId userId:self.userId imageId:(int)self.imageView.tag point:point imageNum:self.imageNum];
       self.imageView.frame = [self getImageFrame:point strartPoint:self.imageStartPoint view:self.imageView];
        self.imageScrolling = NO;
        self.rootDrawView.imageScrolling = NO;
    }
}

-(CGRect)getImageFrame:(CGPoint)endPoint strartPoint:(CGPoint)startPoint view:(ImageViewOfDrawView *)view{
        CGPoint originPoint;
        CGSize size ;
        if(endPoint.x-startPoint.x>=0&&endPoint.y-startPoint.y>=0){

            view.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0);
            size = CGSizeMake(endPoint.x-startPoint.x, endPoint.y-startPoint.y);
            originPoint = startPoint;

        }else if (endPoint.x-startPoint.x>=0&&endPoint.y-startPoint.y<0){

            view.layer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
            originPoint = CGPointMake(startPoint.x,endPoint.y);
            size = CGSizeMake(endPoint.x-startPoint.x, startPoint.y-endPoint.y);

        }else if (endPoint.x-startPoint.x<0&&endPoint.y-startPoint.y>=0){

            
            view.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            originPoint = CGPointMake(endPoint.x,startPoint.y);
            size = CGSizeMake(startPoint.x-endPoint.x, endPoint.y-startPoint.y);

        }else if (endPoint.x-startPoint.x<0&&endPoint.y-startPoint.y<0){

            view.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            originPoint = CGPointMake(endPoint.x,endPoint.y);
            size = CGSizeMake(startPoint.x-endPoint.x, startPoint.y-endPoint.y);

        }
        return CGRectMake(originPoint.x, originPoint.y, size.width, size.height);
}

#pragma mark - delegate
-(void)getTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point currentPage:(int)currentPage imageNum:(int)imageNum{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    if (![self.downImageView isEqual:self.imageViewArray[imageNum-1]]) {
        self.downImageView = self.imageViewArray[imageNum-1];
    }
    self.downImageView.center = point;
}

-(void)getZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size currentPage:(int)currentPage imageNum:(int)imageNum{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    if (![self.downImageView isEqual:self.imageViewArray[imageNum-1]]) {
        self.downImageView = self.imageViewArray[imageNum-1];
    }
    CGPoint center = self.downImageView.center;
    self.downImageView.frame = CGRectMake(self.downImageView.frame.origin.x, self.downImageView.frame.origin.y, size.width, size.height);
    self.downImageView.center = center;
}

-(void)getRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate currentPage:(int)currentPage imageNum:(int)imageNum{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    if (self.downImageView.imageNum != imageNum) {
        self.downImageView = self.imageViewArray[imageNum-1];
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.downImageView.transform = CGAffineTransformRotate(transform, rotate/180.0*M_PI);
    
}
-(void)gestureHandler:(UIPanGestureRecognizer *)sender imageId:(int)imageId imageNum:(int)imageNum{
    
    CGPoint translation = [sender translationInView:self];
    
    sender.view.center = CGPointMake(sender.view.center.x+translation.x, sender.view.center.y+translation.y);
    
    [self.uploadMQTT sendTranslationImage:self.roomId userId:self.userId imageId:imageId point:sender.view.center imageNum:imageNum];
    [sender setTranslation:CGPointZero inView:self];
}
- (void)getAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point imageNum:(int)imageNum{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
   self.downImageView.frame = [self getImageFrame:point strartPoint:self.downImageStartPoint view:self.downImageView];
}
-(void)getAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point imageNum:(int)imageNum{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    [self addDownImageView:[UIImage imageNamed:@"LOGO"] imageId:imageId userId:userId];
    self.downImageStartPoint = point;
    self.downImageView.imageNum = imageNum;
    self.downImageView.frame = CGRectMake(point.x, point.y, 0, 0);
}
-(void)getAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point imageNum:(int)imageNum{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
   self.downImageView.frame = [self getImageFrame:point strartPoint:self.downImageStartPoint view:self.downImageView];
}
-(void)getLockImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage imageNum:(int)imageNum{
    self.downImageView = self.imageViewArray[imageNum-1];
    self.downImageView.userInteractionEnabled = NO;
    self.downImageView.okButton.hidden = YES;
    [self sendSubviewToBack:self.downImageView];
}

-(void)addGraphicalFromDelegate:(GraphicalState)graphical{
    [self.addArray addObject:[NSString stringWithFormat:@"%d",(int)graphical]];
}
-(void)deleteGraphical:(GraphicalState)graphical color:(UIColor *)color lineWidth:(float)lineWidth array:(NSArray *)array{
    NSLog(@"delete %d",(int)graphical);
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

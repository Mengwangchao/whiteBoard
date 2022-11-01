//
//  DrawViewAndImageView.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/31.
//

#import "DrawViewAndImageView.h"
#import "ImageViewOfDrawView.h"
@interface DrawViewAndImageView()<ImageViewOfDrawViewDelegate,ImageMQTTDelegate>
@property (nonatomic , strong)DrawView *rootDrawView;
@property (nonatomic , strong)ImageViewOfDrawView *imageView;
@property (nonatomic , strong)NSMutableArray<ImageViewOfDrawView*> * imageViewArray;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic) BOOL imageScrolling;
@property (nonatomic) CGPoint imageStartPoint;
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
        self.imageScrolling = NO;
        self.rootDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) userId:userId roomId:roomId MQTT:mqtt];
        [self addSubview:self.rootDrawView];
    }
    return self;
}


#pragma mark - 对外接口
-(void)addImageView:(UIImage *)image imageId:(int)imageId{
    self.imageView = [[ImageViewOfDrawView alloc]initWithFrame:CGRectMake(0, 0, 0 , 0) image:image imageId:imageId userId:self.userId roomId:self.roomId MQTT:self.uploadMQTT];
    self.imageView.tag = imageId;
    [self addSubview:self.imageView];
    self.imageView.imageViewOfDrawViewDelegate = self;
    [self.imageViewArray addObject:self.imageView];
    self.imageScrolling = YES;
    self.rootDrawView.imageScrolling = YES;
    
}
-(void)okButtonClick:(ImageViewOfDrawView *)view{
    NSLog(@"click");
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
-(void)setIsEraser:(BOOL)isEraser{
    _isEraser = isEraser;
    self.rootDrawView.isEraser = isEraser;
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
        [self.uploadMQTT sendAddImageStart:self.roomId userId:self.userId imageId:(int)self.imageView.tag point:startPoint];
        self.imageView.frame = CGRectMake(startPoint.x, startPoint.y, 0, 0);
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(self.imageScrolling){
        CGPoint point = [touch locationInView:self];
        [self.uploadMQTT sendAddImageScrolling:self.roomId userId:self.userId imageId:(int)self.imageView.tag point:point];
       self.imageView.frame = [self getImageFrame:point];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if(self.imageScrolling){
        CGPoint point = [touch locationInView:self];
        [self.uploadMQTT sendAddImageEnd:self.roomId userId:self.userId imageId:(int)self.imageView.tag point:point];
       self.imageView.frame = [self getImageFrame:point];
        self.imageScrolling = NO;
        self.rootDrawView.imageScrolling = NO;
    }
}

-(CGRect)getImageFrame:(CGPoint)startPoint{
        CGPoint originPoint;
        CGSize size ;
        if(startPoint.x-self.imageStartPoint.x>=0&&startPoint.y-self.imageStartPoint.y>=0){

            self.imageView.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0);
            size = CGSizeMake(startPoint.x-self.imageStartPoint.x, startPoint.y-self.imageStartPoint.y);
            originPoint = self.imageStartPoint;

        }else if (startPoint.x-self.imageStartPoint.x>=0&&startPoint.y-self.imageStartPoint.y<0){

            self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
            originPoint = CGPointMake(self.imageStartPoint.x,startPoint.y);
            size = CGSizeMake(startPoint.x-self.imageStartPoint.x, self.imageStartPoint.y-startPoint.y);

        }else if (startPoint.x-self.imageStartPoint.x<0&&startPoint.y-self.imageStartPoint.y>=0){

            
            self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            originPoint = CGPointMake(startPoint.x,self.imageStartPoint.y);
            size = CGSizeMake(self.imageStartPoint.x-startPoint.x, startPoint.y-self.imageStartPoint.y);

        }else if (startPoint.x-self.imageStartPoint.x<0&&startPoint.y-self.imageStartPoint.y<0){

            self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            originPoint = CGPointMake(startPoint.x,startPoint.y);
            size = CGSizeMake(self.imageStartPoint.x-startPoint.x, self.imageStartPoint.y-startPoint.y);

        }
        return CGRectMake(originPoint.x, originPoint.y, size.width, size.height);
}

#pragma mark - delegate
-(void)getTranslationImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId point:(CGPoint)point currentPage:(int)currentPage{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    self.imageView.center = point;
}

-(void)getZoomImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId size:(CGSize)size currentPage:(int)currentPage{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    CGPoint center = self.imageView.center;
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, size.width, size.height);
    self.imageView.center = center;
}

-(void)getRotateImage:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId rotate:(float)rotate currentPage:(int)currentPage{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.imageView.transform = CGAffineTransformRotate(transform, rotate/180.0*M_PI);
    
}
-(void)gestureHandler:(UIPanGestureRecognizer *)sender imageId:(int)imageId{
    
    CGPoint translation = [sender translationInView:self];
    
    sender.view.center = CGPointMake(sender.view.center.x+translation.x, sender.view.center.y+translation.y);
    
    [self.uploadMQTT sendTranslationImage:self.roomId userId:self.userId imageId:imageId point:sender.view.center];
    [sender setTranslation:CGPointZero inView:self];
}
- (void)getAddImageEnd:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
   self.imageView.frame = [self getImageFrame:point];
}
-(void)getAddImageStart:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
    [self addImageView:[UIImage imageNamed:@"LOGO"] imageId:imageId];
    self.imageStartPoint = point;
    self.imageView.frame = CGRectMake(point.x, point.y, 0, 0);
}
-(void)getAddImageScrolling:(NSString *)roomId userId:(NSString *)userId imageId:(int)imageId currentPage:(int)currentPage point:(CGPoint)point{
    if ([userId isEqual:self.userId]){
        return;
    }
    
    if (self.currentPage != currentPage) {
        return;
    }
   self.imageView.frame = [self getImageFrame:point];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

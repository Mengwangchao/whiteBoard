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
        self.rootDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) userId:userId roomId:roomId MQTT:mqtt];
        [self addSubview:self.rootDrawView];
    }
    return self;
}


#pragma mark - 对外接口
-(void)addImageView:(UIImage *)image imageId:(int)imageId MQTT:(nonnull UpdateToMQTT *)mqtt{
    [mqtt sendAddImage:self.roomId userId:self.userId imageId:imageId];
    self.imageView = [[ImageViewOfDrawView alloc]initWithFrame:CGRectMake(100, 200,200 , 200) image:image imageId:imageId userId:self.userId roomId:self.roomId MQTT:mqtt];
    [self addSubview:self.imageView];
    self.imageView.imageViewOfDrawViewDelegate = self;
    [self.imageViewArray addObject:self.imageView];
    
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

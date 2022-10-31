//
//  ImageViewOfDrawView.m
//  whiteBoard
//
//  Created by Dynasty Dream on 2022/10/29.
//

#import "ImageViewOfDrawView.h"

@interface ImageViewOfDrawView()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray *imageRootViewArray;
@property (nonatomic) int imageRootViewId;
@end
@implementation ImageViewOfDrawView

-(instancetype)initWithFrame:(CGRect)frame imageId:(int)imageId{
    self = [super initWithFrame:frame];
    if (self) {
        [self addImage:imageId];
        self.userInteractionEnabled = YES;
    }
    return self;
}
-(void)addImage:(int)imageId{
//    UIView * imageRootView = [[UIView alloc]initWithFrame:CGRectMake(80, 250, 200, 300)];
//    imageRootView.userInteractionEnabled = YES;
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
    [self addGestureRecognizer:pingGesture];
    [self addGestureRecognizer:rotationGesture];
    [self addGestureRecognizer:panGesture];
    
//    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, self.frame.size.width, self.frame.size.height-20)];
//    [imageView setImage:[UIImage imageNamed:@"LOGO"]];
//    [self addSubview:imageView];
    [self setImage:[UIImage imageNamed:@"LOGO"]];
    
    self.imageRootViewId ++;
//    [self.imageRootViewArray addObject:imageView];
    
    
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
#pragma  mark - touch
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isEqual:[ImageViewOfDrawView class]]){
        return NO;
    }else{
        return  YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

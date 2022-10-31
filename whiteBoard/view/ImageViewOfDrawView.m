//
//  ImageViewOfDrawView.m
//  whiteBoard
//
//  Created by Dynasty Dream on 2022/10/29.
//

#import "ImageViewOfDrawView.h"

@interface ImageViewOfDrawView()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) NSMutableArray *imageRootViewArray;
@property (nonatomic , strong)UIButton *okButton;
@property (nonatomic , strong)UIButton *cancelButton;
@property (nonatomic)float startWidth;
@property (nonatomic)float startHeight;
@end
@implementation ImageViewOfDrawView

-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self) {
        [self addImage:image];
        self.startWidth = frame.size.width;
        self.startHeight = frame.size.height;
        self.userInteractionEnabled = YES;
        self.okButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.okButton.layer.cornerRadius = 15;
        [self.okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
        self.okButton.backgroundColor = [UIColor greenColor];
        [self addSubview:self.okButton];
    }
    return self;
}
-(void)addImage:(UIImage *)image{
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
    [self setImage:image];
    
//    [self.imageRootViewArray addObject:imageView];
    
    
}
-(void)okButtonClick{
    if(self.imageViewOfDrawViewDelegate !=nil && [self.imageViewOfDrawViewDelegate respondsToSelector:@selector(okButtonClick:)]){
        [self.imageViewOfDrawViewDelegate okButtonClick:self];
    }
}
#pragma mark -- 手势事件
- (void) gestureHandler:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self];
    sender.view.center = CGPointMake(sender.view.center.x+translation.x*(self.frame.size.width/self.startWidth), sender.view.center.y+translation.y*(self.frame.size.height/self.startHeight));
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
    self.okButton.transform = CGAffineTransformScale(self.okButton.transform, 1/sender.scale, 1/sender.scale);
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

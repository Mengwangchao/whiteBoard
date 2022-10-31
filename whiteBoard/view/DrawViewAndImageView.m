//
//  DrawViewAndImageView.m
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/31.
//

#import "DrawViewAndImageView.h"
#import "ImageViewOfDrawView.h"
@interface DrawViewAndImageView()<ImageViewOfDrawViewDelegate>
@property (nonatomic , strong)DrawView *rootDrawView;
@property (nonatomic , strong)ImageViewOfDrawView *imageView;
@property (nonatomic , strong)NSMutableArray<ImageViewOfDrawView*> * imageViewArray;
@end
@implementation DrawViewAndImageView
- (instancetype)initWithFrame:(CGRect)frame userId:(NSString *)userId roomId:(NSString *)roomId MQTT:(UpdateToMQTT *)mqtt{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.uploadMQTT = mqtt;
        self.rootDrawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) userId:userId roomId:roomId MQTT:mqtt];
        [self addSubview:self.rootDrawView];
    }
    return self;
}


#pragma mark - 对外接口
-(void)addImageView:(UIImage *)image{
    self.imageView = [[ImageViewOfDrawView alloc]initWithFrame:CGRectMake(100, 200,200 , 200) image:image];
    [self addSubview:self.imageView];
    self.imageView.imageViewOfDrawViewDelegate = self;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    __block int i =0;
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
    self.rootDrawView.isEraser = isEraser;
}
-(void)setCurrentPage:(int)currentPage{
    self.rootDrawView.currentPage = currentPage;
}
-(void)setUploadMQTT:(UpdateToMQTT *)uploadMQTT{
    self.rootDrawView.uploadMQTT = uploadMQTT;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

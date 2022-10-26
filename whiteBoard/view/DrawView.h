//
//  DrawView.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawView : UIView
- (instancetype)initWithFrame:(CGRect)frame;

- (void)setLineColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END

//
//  DrawBoardGraphicalModel.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/11/1.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, GraphicalState){
    LINE = 1, //任意线
    CIRCULAR = 2 //圆形
};
@interface DrawBoardGraphicalModel : NSObject
@property (nonatomic,strong) NSMutableArray *graphicalArray;
@property (nonatomic) GraphicalState graphical;

@end
@interface CircularModel : NSObject
@property (nonatomic) CGPoint cencerPoint;
@property (nonatomic) float radius;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic) float lineWidth;
@end

NS_ASSUME_NONNULL_END

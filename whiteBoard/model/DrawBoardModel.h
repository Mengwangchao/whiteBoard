//
//  DrawBoardModel.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface DrawBoardModel : NSObject
@property (nonatomic,strong) NSMutableArray *lineArray;
@property (nonatomic,strong) UIColor *color;
@end

NS_ASSUME_NONNULL_END

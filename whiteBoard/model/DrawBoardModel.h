//
//  DrawBoardModel.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
NS_ASSUME_NONNULL_BEGIN

@interface DrawBoardModel : NSObject
@property (nonatomic)CGPoint *currentPoint;
@property (nonatomic)CGPoint *startPoint;
@property (nonatomic)int *userId;
@end

NS_ASSUME_NONNULL_END

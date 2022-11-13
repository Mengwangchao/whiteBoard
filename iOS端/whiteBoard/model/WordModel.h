//
//  WordModel.h
//  whiteBoard
//
//  Created by 王声禄 on 2022/10/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WordModel : NSObject
@property(nonatomic,assign) int wordId;
@property(nonatomic,assign) int currentPage;
@property(nonatomic,assign) int allPageCount;

@end

NS_ASSUME_NONNULL_END

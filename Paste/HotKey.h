//
//  HotKey.h
//  Paste
//
//  Created by hanxu on 2022/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HotKey : NSObject

+ (void)addGlobalHotKey:(UInt32)keyCode;

@end

NS_ASSUME_NONNULL_END

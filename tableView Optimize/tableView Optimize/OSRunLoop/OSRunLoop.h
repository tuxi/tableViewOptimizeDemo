//
//  OSRunLoop.h
//  tableView Optimize
//
//  Created by Swae on 2017/11/9.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSRunLoop : NSObject

+ (OSRunLoop *)main;
+ (OSRunLoop *(^)(NSString *))queue;

/// 添加任务
- (OSRunLoop *(^)(dispatch_block_t task))add;
- (OSRunLoop *(^)(dispatch_block_t task))cancel;
- (OSRunLoop *(^)(NSInteger skipCount))skip;
- (OSRunLoop *(^)(NSInteger limitCount))limit;
- (OSRunLoop *)cache;

@end

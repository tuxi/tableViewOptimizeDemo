//
//  OSRunLoop.h
//  tableView Optimize
//
//  Created by Swae on 2017/11/9.
//  Copyright © 2017年 Ossey All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSRunLoop : NSObject

+ (OSRunLoop *)main;
+ (OSRunLoop *(^)(NSString *))queue;

/// 添加任务
- (OSRunLoop *(^)(dispatch_block_t task))add;
- (OSRunLoop *(^)(dispatch_block_t task))cancel;
- (OSRunLoop *(^)(NSInteger skipCount))skip;
/// /// 使用 limit() 限制 Task 个数，超出限制会丢弃最先入列的 Task
- (OSRunLoop *(^)(NSInteger limitCount))limit;
- (OSRunLoop *)cache;

@end

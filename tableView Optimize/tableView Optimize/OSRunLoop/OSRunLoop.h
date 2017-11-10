//
//  OSRunLoop.h
//  tableView Optimize
//
//  Created by Swae on 2017/11/9.
//  Copyright © 2017年 Ossey All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSRunLoopOperation: NSObject

/// 缓存任务
- (OSRunLoopOperation *(^)(BOOL allowCache))cache;

@end

/// 使用OSRunLoop.current().add(^{})添加任务可以将一个大任务拆分成很多个小任务，在 Runloop 当前循环空闲时(kRunLoopBeforeWaiting)，依次执行各个add()的任务

@interface OSRunLoop : NSObject

/// 使用主线程的main runLoop
+ (OSRunLoop *)main;
/// 使用的是当前线程的runLoop, 参数为设置当前runLoop的标识符
+ (OSRunLoop *(^)(NSString *identifier))current;

/// 添加任务，会先将任务添加到taskQueue中，
- (OSRunLoopOperation *(^)(dispatch_block_t task))add;
/// 取消任务，会从taskQueue和cacheQueue中移除，如果此操作已在执行中，则无法完成
- (OSRunLoop *(^)(dispatch_block_t task))cancel;

/// 使用 max() 限制 最多执行Task 个数，默认没有限制
/// 如果开启缓存机制，超出限制会丢弃最先入列的 task,
- (OSRunLoop *(^)(NSInteger maxCount))max;


@end


//
//  OSRunLoop.m
//  tableView Optimize
//
//  Created by Swae on 2017/11/9.
//  Copyright © 2017年 Ossey All rights reserved.
//

#import "OSRunLoop.h"

#define OSRunLoopChainImplement(params, ...) \
    __weak typeof(&*self) weak_self = self; \
    return ^id(params) { \
        __strong typeof(&*weak_self) self = weak_self; \
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
        __VA_ARGS__ \
        dispatch_semaphore_signal(_lock); \
        return self; \
    };

/// 最大任务默认值，默认无限制
static NSInteger const kRunLoopTaskDefaultMaxCount = NSIntegerMax;
/// 主线程OSRunLoop的标识符
static NSString * const kRunLoopMainIdentifier = @"com.ossey.runloop.main";

@interface OSRunLoopOperation ()

/// 执行的任务
@property (nonatomic, strong) dispatch_block_t task;
/// 当前任务是否是缓存任务
@property (nonatomic, assign, getter=isAllowCache) BOOL allowCache;
/// 当前任务所在的OSRunLoop
@property (nonatomic, weak) OSRunLoop *currentRunLoop;

@end

@interface OSRunLoop ()

@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, assign) NSInteger maxCount;
/// 存放OSRunLoop对象的数组
@property (nonatomic, strong, class) NSMutableDictionary<NSString *, OSRunLoop *> *runLoopDictionary;
/// 执行任务的队列
@property (nonatomic, strong) NSMutableArray<OSRunLoopOperation *> *taskQueue;
/// 缓存任务的队列
@property (nonatomic, strong) NSMutableArray<OSRunLoopOperation *> *cacheQueue;
/// OSRunLoop对象的标识符
@property (nonatomic, copy) NSString *identifier;
/// 需要销毁的任务
@property (nonatomic, strong) OSRunLoopOperation *destroyTask;

@end

@implementation OSRunLoop

@dynamic runLoopDictionary;

+ (instancetype)sharedInstance {
    static OSRunLoop *_runLoop;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _runLoop = self.new;
    });
    return _runLoop;
}

- (instancetype)initWithIdentifer:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        _lock = dispatch_semaphore_create(1);
        _maxCount = kRunLoopTaskDefaultMaxCount;
    }
    return self;
}

+ (OSRunLoop *)main {
    return self.current(kRunLoopMainIdentifier);
}

#pragma mark *** RunLoop ***

- (void)addObserverForRunLoop:(CFRunLoopRef)runLoop {
    __weak typeof(&*self) weakSelf = self;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        __strong typeof(&*weakSelf) self = weakSelf;
        
        if (!self.taskQueue.count) {
            return;
        }
        
        // 执行任务
        OSRunLoopOperation *operation = self.taskQueue.firstObject;
        operation.task();
        [self.taskQueue removeObjectAtIndex:0];
        
        // 缓存中存在时，就取出缓存中的放在tasks中，等待下次执行
        if (self.cacheQueue.count) {
            // 将缓存中的第一个任务添加到tasks中
            OSRunLoopOperation *operation = [self.cacheQueue objectAtIndex:0];
            [self.cacheQueue removeObject:operation];
            [self.taskQueue addObject:operation];
        }
        
        // 销毁观察者
        [self destoryObserver:observer];
        
    });
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}


/// 销毁观察者
- (void)destoryObserver:(CFRunLoopObserverRef)observer {
    if (!self.taskQueue.count) {
        if ([OSRunLoop.runLoopDictionary objectForKey:self.identifier]) {
            // 当前是当前OSRunLoop
            __weak typeof(&*self) weakSelf = self;
            self.destroyTask.task = ^{
                __strong typeof(&*weakSelf) self = weakSelf;
                CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
                [OSRunLoop.runLoopDictionary removeObjectForKey:self.identifier];
            };
            
            // 执行销毁的任务
            OSRunLoop.main.add(self.destroyTask.task);
        }
    }
    else {
        if (self.destroyTask) {
            OSRunLoop.main.cancel(self.destroyTask.task);
            self.destroyTask = nil;
        }
    }
}

- (OSRunLoop *(^)(NSInteger))max {
    OSRunLoopChainImplement(NSInteger maxCount, {
        self.maxCount = maxCount;
    });
}

- (OSRunLoopOperation *(^)(dispatch_block_t))add {
    __weak typeof(&*self) weakSelf = self;
    return ^id(dispatch_block_t task) {
        __strong typeof(&*weakSelf) self = weakSelf;
        OSRunLoopOperation *operation = nil;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        if (task) {
            operation = OSRunLoopOperation.new;
            operation.task = task;
            operation.currentRunLoop = self;
            [self.taskQueue addObject:operation];
            NSParameterAssert(operation.currentRunLoop);
        }
        dispatch_semaphore_signal(_lock);
        return operation;
    };
}

- (OSRunLoop *(^)(dispatch_block_t))cancel {
    OSRunLoopChainImplement(dispatch_block_t task, {
        OSRunLoopOperation *operationInTasks = [self getOperationByTask:task fromArray:self.taskQueue];
        [self.taskQueue removeObject:operationInTasks];
        OSRunLoopOperation *operationInCaches = [self getOperationByTask:task fromArray:self.cacheQueue];
        [self.cacheQueue removeObject:operationInCaches];
    });
}

+ (OSRunLoop *(^)(NSString *))current {
    return ^OSRunLoop *(NSString *identifier) {
        
        NSAssert(identifier != nil, @"runLoop 的 name 不能为nil");
        OSRunLoop *runloop = [OSRunLoop.runLoopDictionary  objectForKey:identifier];
        if (!runloop) {
            runloop = [[OSRunLoop alloc] initWithIdentifer:identifier];
            CFRunLoopRef runLoop = CFRunLoopGetCurrent();
            if ([identifier isEqualToString:kRunLoopMainIdentifier]) {
                runLoop = CFRunLoopGetMain();
            }
            [runloop addObserverForRunLoop:runLoop];
            [OSRunLoop.runLoopDictionary setObject:runloop forKey:identifier];
        }
        return runloop;
    };
}

/// 根据一个dispatch_block_t 查找它所在的OSRunLoopOperation对象
- (OSRunLoopOperation *)getOperationByTask:(dispatch_block_t)task fromArray:(NSArray *)array {
    if (!task || array.count) {
        return nil;
    }
    NSUInteger foundTaskIdx = [self.taskQueue indexOfObjectPassingTest:^BOOL(OSRunLoopOperation * _Nonnull operation, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL res = [operation.task isEqual:task];
        if (res) {
            *stop = YES;
        }
        return res;
    }];
    OSRunLoopOperation *operation = nil;
    if (foundTaskIdx != NSNotFound) {
        operation = [self.taskQueue objectAtIndex:foundTaskIdx];
    }
    return operation;
}


#pragma mark *** Lazy ***
- (NSMutableArray *)taskQueue {
    if (!_taskQueue) {
        _taskQueue = @[].mutableCopy;
    }
    return _taskQueue;
}

- (NSMutableArray *)cacheQueue {
    if (!_cacheQueue) {
        _cacheQueue = @[].mutableCopy;
    }
    return _cacheQueue;
}

+ (NSMutableDictionary *)runLoopDictionary {
    static NSMutableDictionary *_runLoopDictionary;
    if (!_runLoopDictionary) {
        _runLoopDictionary = @{}.mutableCopy;
    }
    return _runLoopDictionary;
}


@end

@implementation OSRunLoopOperation

- (OSRunLoopOperation *(^)(BOOL))cache {
    return ^ OSRunLoopOperation *(BOOL allowCache) {
        self.allowCache = allowCache;
        // 当允许缓存时，将超出maxCount的task放到缓存中，并移除最早添加的task
        while (self.currentRunLoop.taskQueue.count > self.currentRunLoop.maxCount) {
            // 若允许缓存，则将超出的任务放到缓存中
            if (self.isAllowCache) {
                [self.currentRunLoop.cacheQueue addObject:self];
            }
            [self.currentRunLoop.taskQueue removeObjectAtIndex:0];
        }
        return self;
    };
}
@end

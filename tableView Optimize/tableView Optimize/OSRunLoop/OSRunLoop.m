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

static NSInteger const kRunLoopTasksLimit = INT_MAX;
static NSInteger const kRunLoopTaskSkip = 100;


@interface OSRunLoop ()

@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, assign) NSInteger limitCount;
/// 需要跳过的数量
@property (nonatomic, assign) NSInteger skipCount;
@property (nonatomic, assign, getter=isAllowCache) BOOL allowCache;

/// 存放OSRunLoop对象的数组
@property (nonatomic, strong) NSMutableDictionary *runLoopDictionary;
/// 执行任务的队列
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *tasks;
/// 缓存任务的队列
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *caches;
/// OSRunLoop对象的名称
@property (nonatomic, copy) NSString *name;
/// 需要销毁的任务
@property (nonatomic, copy) dispatch_block_t destroyTask;
@property (nonatomic, strong) OSRunLoop *main;

@end

@implementation OSRunLoop

+ (instancetype)sharedInstance {
    static OSRunLoop *_runLoop;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _runLoop = self.new;
    });
    return _runLoop;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.name = name;
        _lock = dispatch_semaphore_create(1);
        _limitCount = kRunLoopTasksLimit;
    }
    return self;
}

+ (OSRunLoop *)main {
    OSRunLoop *runloop = OSRunLoop.sharedInstance.main;
    if (!runloop) {
        runloop = [[OSRunLoop alloc] initWithName:@"com.sina.runloop.main"];
        [runloop addObserverForRunLoop:CFRunLoopGetMain()];
        OSRunLoop.sharedInstance.main = runloop;
    }
    return runloop;
}

#pragma mark *** RunLoop ***

- (void)addObserverForRunLoop:(CFRunLoopRef)runLoop {
    __weak typeof(&*self) weakSelf = self;
   CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
       __strong typeof(&*weakSelf) self = weakSelf;
       
       if (!self.tasks.count) {
           return;
       }
       
       // 存在跳过时，就return
       if (self.skipCount > 0) {
           self.skipCount--;
           return;
       }
       
       // 执行任务
      dispatch_block_t task = self.tasks.firstObject;
       task();
       [self.tasks removeObjectAtIndex:0];
       
       // 缓存中存在时，就取出缓存中的放在tasks中，等待下次执行
       if (self.isAllowCache && self.caches.count) {
           dispatch_block_t block = self.caches.firstObject;
           [self.caches removeObject:block];
           [self.tasks addObject:task];
       }
       
       // 销毁观察者
       [self destoryObserver:observer];
       
    });
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}


/// 销毁观察者
- (void)destoryObserver:(CFRunLoopObserverRef)observer {
    if (!self.tasks.count) {
        if ([[OSRunLoop sharedInstance].runLoopDictionary objectForKey:self.name]) {
            // 当前是当前OSRunLoop
            __weak typeof(&*self) weakSelf = self;
            self.destroyTask = ^{
                __strong typeof(&*weakSelf) self = weakSelf;
                CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
                [[OSRunLoop sharedInstance].runLoopDictionary removeObjectForKey:self.name];
            };
            
            // 延迟销毁，
            OSRunLoop.main.skip(kRunLoopTaskSkip).limit(1).add(self.destroyTask);
        }
    }
    else {
        if (self.destroyTask) {
            OSRunLoop.main.cancel(self.destroyTask);
            self.destroyTask = nil;
        }
    }
}

- (OSRunLoop *(^)(NSInteger))skip {
    OSRunLoopChainImplement(NSInteger skipCount, {
        self.skipCount = skipCount;
    });
}

- (OSRunLoop *(^)(NSInteger))limit {
    OSRunLoopChainImplement(NSInteger limitCount, {
        self.limitCount = limitCount;
    });
}

- (OSRunLoop *(^)(dispatch_block_t))add {
    OSRunLoopChainImplement(dispatch_block_t task, {
        if (task) {
            [self.tasks addObject:task];
            
            // 当任务数量tasks大于limitCount时，并且开启缓存时，就将其添加到缓存中
            while (self.tasks.count > self.limitCount) {
                if (self.isAllowCache) {
                    [self.caches addObject:task];
                }
                [self.tasks removeObjectAtIndex:0];
            }
        }
    });
}

- (OSRunLoop *(^)(dispatch_block_t))cancel {
    OSRunLoopChainImplement(dispatch_block_t task, {
        [self.tasks removeObject:task];
        [self.caches removeObject:task];
    });
}

+ (OSRunLoop *(^)(NSString *))queue {
    return ^OSRunLoop *(NSString *name) {
        
        NSAssert(name != nil, @"runLoop 的 name 不能为nil");
        OSRunLoop *runloop = [[OSRunLoop sharedInstance].runLoopDictionary  objectForKey:name];
        if (!runloop) {
            runloop = [[OSRunLoop alloc] initWithName:name];
            [runloop addObserverForRunLoop:CFRunLoopGetCurrent()];
            [[OSRunLoop sharedInstance].runLoopDictionary setObject:runloop forKey:name];
        }
        return runloop;
    };
}

- (OSRunLoop *)cache {
    _allowCache = YES;
    return self;
}

#pragma mark *** Lazy ***
- (NSMutableArray *)tasks {
    if (!_tasks) {
        _tasks = @[].mutableCopy;
    }
    return _tasks;
}

- (NSMutableArray *)caches {
    if (!_caches) {
        _caches = @[].mutableCopy;
    }
    return _caches;
}

- (NSMutableDictionary *)runLoopDictionary {
    if (!_runLoopDictionary) {
        _runLoopDictionary = @{}.mutableCopy;
    }
    return _runLoopDictionary;
}



@end

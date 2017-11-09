//
//  UITableView+CellHeightCache.m
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/9.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//
#import "UITableView+CellHeightCache.h"
#import <objc/runtime.h>
#import "MomentViewCell.h"
#import "OSRunLoop.h"

@interface BeanViewFrameAdaptive ()

/// 存放BeanViewFrame的集合, 此集合会将modle包装为BeanViewFrame类型存储 一对一 key为model的内存地址
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, BeanViewFrame *> *beanMap;

@property (nonatomic, strong) Class beanViewFrameClass;

@end

@implementation BeanViewFrameAdaptive

- (void)registerBeanViewFrameClass:(Class)clas {
    if (clas == NSClassFromString(@"BeanViewFrame") &&
        ![clas isSubclassOfClass:NSClassFromString(@"BeanViewFrame")]) {
        @throw [NSException exceptionWithName:NSExpansionAttributeName
                                       reason:@"Error: register class must is BeanViewFrame or BeanViewFrame's subclass"
                                     userInfo:nil];
    }
    self.beanViewFrameClass = clas;
    
}

- (NSMutableDictionary<id<NSCopying>, BeanViewFrame *> *)beanMap {
    if (_beanMap == nil) {
        _beanMap = [NSMutableDictionary dictionary];
    }
    return _beanMap;
}

- (BOOL)existsBeanViewFrameForModel:(id<BeanViewFrameAdaptiveModelProtocol>)model {
    BeanViewFrame *b = [self beanViewFrameForModle:model];
    return b != nil;
}

- (BeanViewFrame *)beanViewFrameForModle:(id<BeanViewFrameAdaptiveModelProtocol>)model {
    //    NSString *p = [NSString stringWithFormat:@"%p", model];
    NSString *key = [model adaptiveKey];
    return [self.beanMap objectForKey:key];
}

- (BeanViewFrame *)warpModelToBeanViewFrameByModel:(id<BeanViewFrameAdaptiveModelProtocol>)model {
    //    NSString *p = [NSString stringWithFormat:@"%p", model];
    BeanViewFrame *b = [self beanViewFrameForModle:model];
    if (!b) {
        NSString *key = [model adaptiveKey];
        b = [self initializeViewFrameWithModel:model];
        [self.beanMap setObject:b forKey:key];
    }
    
    return b;
}

- (BeanViewFrame *)warpModelToBeanViewFrameFromDataSource:(NSMutableArray *)dataSource
                                                  atIndex:(NSInteger)index {
    
    id model = dataSource[index];
    
    BeanViewFrame *b;
    if ([model isKindOfClass:[BeanViewFrame class]]) {
        return model;
    } else {
        b = [self initializeViewFrameWithModel:model];
        [dataSource replaceObjectAtIndex:index withObject:b];
    }
    return b;
}

- (BeanViewFrame *)initializeViewFrameWithModel:(id)model {
    if (!_beanViewFrameClass) {
        _beanViewFrameClass = [BeanViewFrame class];
    }
    return [_beanViewFrameClass viewFrameWithModel:model];
}

- (void)removeAllBeanViewFrames {
    if (self.beanMap) {
        [self.beanMap removeAllObjects];
    }
}

- (void)removeBeanViewFrameByModel:(id)model {
    if (self.beanMap && [self existsBeanViewFrameForModel:model]) {
        NSString *p = [NSString stringWithFormat:@"%p", model];
        [self.beanMap removeObjectForKey:p];
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self removeAllBeanViewFrames];
    self.beanMap = nil;
}


@end

@interface CellHeightCache () <NSCacheDelegate>

/// 缓存cell高度, 为解决屏幕旋转问题, 通过一个key会将横屏和竖屏会各自缓存一份
@property (nonatomic, strong) NSCache<id, NSMutableDictionary <NSNumber *, NSNumber *>*> *cellHeightCache;

/// 屏幕方向
@property (nonatomic, assign) StatusBarOrientation currentStatusBarOrientation;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation CellHeightCache

- (instancetype)initWithTableView:(UITableView *)v {
    self = [super init];
    if (self) {
        _tableView = v;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeStatusBarOrientationNotification:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)changeStatusBarOrientationNotification:(NSNotification *)note {
    if ([note.name isEqualToString:UIApplicationWillChangeStatusBarOrientationNotification]) {
        if (_tableView) {
            [self removeAllCellHeghtCache];
            [_tableView reloadData];
        }
    }
}

- (NSCache<id,NSMutableDictionary<NSNumber *,NSNumber *> *> *)cellHeightCache {
    if (_cellHeightCache == nil) {
        _cellHeightCache = [NSCache new];
        _cellHeightCache.delegate = self;
    }
    return _cellHeightCache;
}

- (StatusBarOrientation)currentStatusBarOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        return StatusBarOrientationV;
    } else {
        return StatusBarOrientationH;
    }
}


- (BOOL)existsHeightForKey:(id)key {
    if (!key) {
        return NO;
    }
    NSMutableDictionary *heightCache = [self.cellHeightCache objectForKey:key];
    NSNumber *height = [heightCache objectForKey:@(self.currentStatusBarOrientation)];
    return height && ![height isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height key:(id)key {
    
    NSMutableDictionary *heightCache = [self.cellHeightCache objectForKey:key];
    if (heightCache == nil) {
        heightCache = [@{} mutableCopy];
        [self.cellHeightCache setObject:heightCache forKey:key];
    }
    
    [heightCache setObject:@(height) forKey:@(self.currentStatusBarOrientation)];
}

- (CGFloat)heightForKey:(id)key {
    
    if (!key) {
        return 0;
    }
    
    NSMutableDictionary *heightCache = [self.cellHeightCache objectForKey:key];
    
    if (!heightCache) {
        return 0;
    }
    CGFloat height = [[heightCache objectForKey:@(self.currentStatusBarOrientation)]  doubleValue];
    return height;
}

- (void)removeAllCellHeghtCache {
    if (self.cellHeightCache) {
        [self.cellHeightCache removeAllObjects];
    }
}

- (void)removeCellHeightCacheForKey:(id)key {
    
    if (!key) return;
    
    if (self.cellHeightCache) {
        NSMutableDictionary *d = [self.cellHeightCache objectForKey:key];
        if (d) {
            [d removeObjectForKey:@(self.currentStatusBarOrientation)];
        }
    }
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    
}


- (void)dealloc {
    NSLog(@"%s", __func__);
    [self removeAllCellHeghtCache];
    self.cellHeightCache = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation UITableView (CellHeightCache)

- (void)registerBeanViewFrameClass:(Class)clas {
    [self.beanAdaptive registerBeanViewFrameClass:clas];
}

- (CellHeightCache *)cellHeightCache {
    CellHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[CellHeightCache alloc] initWithTableView:self];;
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (void)setCellHeightCache:(CellHeightCache *)cellHeightCache {
    objc_setAssociatedObject(self, @selector(cellHeightCache), cellHeightCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BeanViewFrameAdaptive *)beanAdaptive {
    BeanViewFrameAdaptive *b = objc_getAssociatedObject(self, _cmd);
    if (!b) {
        b = [BeanViewFrameAdaptive new];
        objc_setAssociatedObject(self, _cmd, b, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return b;
}

- (void)setBeanAdaptive:(BeanViewFrameAdaptive *)beanAdaptive {
    objc_setAssociatedObject(self, @selector(beanAdaptive), beanAdaptive, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)getCellHeightCacheWithCacheKey:(NSString *)cacheKey {
    if (!cacheKey) {
        return 0;
    }
    return [self.cellHeightCache existsHeightForKey:cacheKey] ? [self.cellHeightCache heightForKey:cacheKey] : 0;
}

- (void)cacheWithCellHeight:(CGFloat)cellHeight cacheKey:(NSString *)cacheKey {
    [self.cellHeightCache cacheHeight:cellHeight key:cacheKey];
}

- (CGFloat)getCellHeightCacheByModel:(id<BeanViewFrameAdaptiveModelProtocol>)model  {
    
    BeanViewFrame *bean = [self warpModelToBeanViewFrameByModel:model];
    CGFloat cellHeight = [self getCellHeightCacheWithCacheKey:bean.cellHeightKey];;
    if (cellHeight) {
        return cellHeight;
    }
    cellHeight = bean.cellHeight;
    [self cacheWithCellHeight:cellHeight cacheKey:bean.cellHeightKey];
    return cellHeight;
}

- (CGFloat)getCellHeightCacheFromDataSource:(NSMutableArray<id<BeanViewFrameAdaptiveModelProtocol>> *)dataSource
                                      index:(NSInteger)index {
    
    BeanViewFrame *bean = nil;
    if (dataSource == nil) {
        return 0;
        
    } else {
        bean = [self.beanAdaptive warpModelToBeanViewFrameFromDataSource:dataSource atIndex:index];
    }
    CGFloat cellHeight = [self getCellHeightCacheWithCacheKey:bean.cellHeightKey];
    if (cellHeight) {
        return cellHeight;
    }
    
    cellHeight = bean.cellHeight;
    [self cacheWithCellHeight:cellHeight cacheKey:bean.cellHeightKey];
    return cellHeight;
    
}
- (BeanViewFrame *)warpModelToBeanViewFrameFromDataSource:(NSMutableArray<id<BeanViewFrameAdaptiveModelProtocol>> *)dataSource
                                                  atIndex:(NSInteger)index {
    
    if (!dataSource || ![dataSource isKindOfClass:[NSMutableArray class]]) {
        @throw [NSException exceptionWithName:@"Error: weap model error"
                                       reason:@"dataSource is nil or not exist"
                                     userInfo:nil];
    }
    
    return [self.beanAdaptive warpModelToBeanViewFrameFromDataSource:dataSource atIndex:index];
}

- (BeanViewFrame *)warpModelToBeanViewFrameByModel:(id<BeanViewFrameAdaptiveModelProtocol>)model {
    if (!model) {
        return nil;
    }
    return [self.beanAdaptive warpModelToBeanViewFrameByModel:model];
}

- (BeanViewFrame *)getBeanViewFrameForModle:(id<BeanViewFrameAdaptiveModelProtocol>)model {
    if (!model) {
        return nil;
    }
    return [self.beanAdaptive beanViewFrameForModle:model];
}


@end

@implementation UITableView (Preload)

- (NSMutableArray<NSIndexPath *> *)needLoadIndexPaths {
    NSMutableArray *needArr = objc_getAssociatedObject(self, _cmd);
    if (needArr == nil) {
        needArr = [NSMutableArray arrayWithCapacity:0];
        objc_setAssociatedObject(self, _cmd, needArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return needArr;
}

- (void)setNeedLoadIndexPaths:(NSMutableArray<NSIndexPath *> *)needLoadIndexPaths {
    objc_setAssociatedObject(self, @selector(needLoadIndexPaths), needLoadIndexPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)scrollToToping {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScrollToToping:(BOOL)scrollToToping {
    objc_setAssociatedObject(self, @selector(scrollToToping), @(scrollToToping), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// 加载cell的数据
- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
            loadDataFromDataSource:(NSArray *)dataSource
                        atIndexath:(NSIndexPath *)indexPath; {
    
    if (dataSource && [dataSource count]) {
        
        MomentViewCell *mCell = (MomentViewCell *)cell;
        id model = dataSource[indexPath.row];
        
        [mCell cancelDraw];
        if (![mCell isKindOfClass:[MomentViewCell class]]) {
            return mCell;
        }
        mCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        BeanViewFrame *bean = [self warpModelToBeanViewFrameByModel:model];
        mCell.bean = bean;
        
        if (self.needLoadIndexPaths.count>0 && [self.needLoadIndexPaths indexOfObject:indexPath] == NSNotFound) {
            [mCell cancelDraw];
            return mCell;
        }
        if (self.scrollToToping) {
            return mCell;
        }
        OSRunLoop.main.limit(50).add(^{
            [mCell startDraw];
        });
        
    }
    return cell;
}

/// 刷新cell
- (void)refreshData {
    if (self.scrollToToping) {
        return;
    }
    if (self.indexPathsForVisibleRows.count <= 0 ) {
        return;
    }
    if (self.visibleCells && self.visibleCells.count>0) {
        for (id temp in [self.visibleCells copy]) {
            MomentViewCell *cell = (MomentViewCell *)temp;
            if ([cell isKindOfClass:[MomentViewCell class]]) {
                [cell startDraw];
            }
        }
    }
}


/// 获取tableView上将要显示cell的indexPaths
- (NSArray *)getWillVisbleIndexPathsInRect:(CGRect)rect withVelocity:(CGPoint)velocity dataSource:(NSArray *)dataSource {
    NSArray *temp = [self indexPathsForRowsInRect:rect];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
    if (velocity.y<0) {      // 向上滑
        NSIndexPath *indexPath = [temp lastObject];
        if (indexPath.row+3< dataSource.count) {
            [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:indexPath.section]];
            [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section]];
            [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
        }
    } else {                 // 向下滑
        NSIndexPath *indexPath = [temp firstObject];
        if (indexPath.row>3) {
            [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:indexPath.section]];
            [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:indexPath.section]];
            [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]];
        }
    }
    return arr;
}


- (void)tableViewWillEndDraggingWithVelocity:(CGPoint)velocity
                         targetContentOffset:(inout CGPoint *)targetContentOffset
                                  dataSource:(NSArray *)dataSource {
    
    
    NSIndexPath *targetIndexPath = [self indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath *firstVisbleIndexPath = [[self indexPathsForVisibleRows] firstObject];
    NSInteger skipCount = 8;
    NSInteger tCount = labs(firstVisbleIndexPath.row-targetIndexPath.row);
    if (tCount > skipCount) {
        
        CGRect willVisbleRect = CGRectMake(0, targetContentOffset->y, self.frame.size.width, self.frame.size.height);
        [self.needLoadIndexPaths addObjectsFromArray:[self getWillVisbleIndexPathsInRect:willVisbleRect withVelocity:velocity dataSource:dataSource]];
    }
}

#pragma mark -

- (void)removeNeedLoadData {
    if (self.needLoadIndexPaths) {
        [self.needLoadIndexPaths removeAllObjects];
    }
}

- (void)releaseData {
    [self removeNeedLoadData];
    self.needLoadIndexPaths = nil;
    self.beanAdaptive = nil;
    self.cellHeightCache = nil;
}


@end

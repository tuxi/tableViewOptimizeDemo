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

@interface BeanViewFrameAdaptive ()

/// 存放BeanViewFrame的集合, 此集合会将modle包装为BeanViewFrame类型存储 一对一 key为model的内存地址
@property (nonatomic, strong) NSMutableDictionary<id<NSCoding>, BeanViewFrame *> *beanMap;

@end

@implementation BeanViewFrameAdaptive

- (NSMutableDictionary<id<NSCoding>,BeanViewFrame *> *)beanMap {
    if (_beanMap == nil) {
        _beanMap = [NSMutableDictionary dictionary];
    }
    return _beanMap;
}

- (BOOL)existsBeanViewFrameForModel:(id)model {
    BeanViewFrame *b = [self beanViewFrameForModle:model];
    return b != nil;
}

- (BeanViewFrame *)beanViewFrameForModle:(id)model {
    NSString *p = [NSString stringWithFormat:@"%p", model];
    return [self.beanMap objectForKey:p];
}

- (BeanViewFrame *)warpModelToBeanViewFrameByModel:(id)model {
    NSString *p = [NSString stringWithFormat:@"%p", model];
    BeanViewFrame *b = [self beanViewFrameForModle:model];
    if (!b) {
        b = [BeanViewFrame viewFrameWithModel:model];
        [self.beanMap setObject:b forKey:p];
    }
    
    if (self.beanMap.count > 500) {
        [self removeAllBeanViewFrames];
    }
    
    return b;
}

- (BeanViewFrame *)warpModelToBeanViewFrameFromtDataSource:(NSMutableArray *)dataSource
                                                   atIndex:(NSInteger)index {
    
    id model = dataSource[index];
    
    BeanViewFrame *b;
    if ([model isKindOfClass:[BeanViewFrame class]]) {
        return model;
    } else {
        b = [BeanViewFrame viewFrameWithModel:model];
        [dataSource removeObjectAtIndex:index];
        [dataSource insertObject:b atIndex:index];
    }
    return b;
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
    [self removeAllBeanViewFrames];
    self.beanMap = nil;
}

@end

@interface CellHeightCache ()

/// 缓存cell高度, 为解决屏幕旋转问题, 横屏和竖屏会各自缓存一份
@property (nonatomic, strong) NSCache<NSNumber *, NSCache <id, NSNumber *>*> *cellHeightCache;
/// 屏幕方向
@property (nonatomic, assign) StatusBarOrientation statusBarOrientation;

@end

@implementation CellHeightCache

- (instancetype)initWithTableView:(UITableView *)v {
    self = [super init];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [v reloadData];
        }];
    }
    return self;
}

- (NSCache<NSNumber *,NSCache<id,NSNumber *> *> *)cellHeightCache {
    if (_cellHeightCache == nil) {
        _cellHeightCache = [NSCache new];
    }
    return _cellHeightCache;
}

- (StatusBarOrientation)statusBarOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIDeviceOrientationPortrait) {
        return StatusBarOrientationV;
    } else {
        return StatusBarOrientationH;
    }
}

- (BOOL)existsHeightForKey:(id)key {
    // 取出当前屏幕方向缓存的高度
    NSCache *orientationCache = [self.cellHeightCache objectForKey:@(self.statusBarOrientation)];
    NSNumber *n = [orientationCache objectForKey:key];
    return n && ![n isEqualToNumber:@-1];
    
}

- (void)cacheHeight:(CGFloat)height byKey:(id)key {
    
    NSCache *orientationCache = [self.cellHeightCache objectForKey:@(self.statusBarOrientation)];
    if (orientationCache == nil) {
        orientationCache = [NSCache new];
        [self.cellHeightCache setObject:orientationCache forKey:@(self.statusBarOrientation)];
    }
    [orientationCache setObject:@(height) forKey:key];
}

- (CGFloat)heightForKey:(id)key {
#if CGFLOAT_IS_DOUBLE
    return [[[self.cellHeightCache objectForKey:@(self.statusBarOrientation)] objectForKey:key]  doubleValue];
#else
    return [[[self.cellHeightCache objectForKey:@(self.statusBarOrientation)] objectForKey:key]  floatValue];
#endif
}

- (void)removeAllCellHeghtCache {
    if (self.cellHeightCache) {
        [self.cellHeightCache removeAllObjects];
    }
}

- (void)removeCellHeightCacheForKey:(id)key {
    if (self.cellHeightCache) {
        NSCache *d = [self.cellHeightCache objectForKey:@(self.statusBarOrientation)];
        if (d) {
            [d removeObjectForKey:key];
        }
    }
}

- (void)dealloc {
    [self removeAllCellHeghtCache];
    self.cellHeightCache = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation UITableView (CellHeightCache)

/// 如果缓存存在则返回，不则在则设置缓存
- (CellHeightCache *)cellHeightCache {
    CellHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[CellHeightCache alloc] initWithTableView:self];;
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (BeanViewFrameAdaptive *)beanAdaptive {
    BeanViewFrameAdaptive *b = objc_getAssociatedObject(self, _cmd);
    if (!b) {
        b = [BeanViewFrameAdaptive new];
        objc_setAssociatedObject(self, _cmd, b, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return b;
}


- (CGFloat)getCellHeightCacheWithCacheKey:(NSString *)cacheKey {
    if (!cacheKey) {
        return 0;
    }
    
    // 如果已经存在cell height 则返回
    if ([self.cellHeightCache existsHeightForKey:cacheKey]) {
        CGFloat cachedHeight = [self.cellHeightCache heightForKey:cacheKey];
        return cachedHeight;
    } else {
        return 0;
    }
}

/// 缓存cell的高度
- (void)cacheWithCellHeight:(CGFloat)cellHeight cacheKey:(NSString *)cacheKey {
    [self.cellHeightCache cacheHeight:cellHeight byKey:cacheKey];
}

- (CGFloat)getCellHeightCacheByModel:(id)model  {
    BeanViewFrame *bean = [self warpModelToBeanViewFrameByModel:model];
    CGFloat cellHeight = [self getCellHeightCacheWithCacheKey:bean.cellHeightKey];
    if (cellHeight) {
//        NSLog(@"从缓存取出来的cell高度-----%f",cellHeight);
    }
    
    if(!cellHeight){
        cellHeight = bean.cellHeight;
        [self cacheWithCellHeight:cellHeight cacheKey:bean.cellHeightKey];
//        NSLog(@"通过计算获取的cell高度-----%f",cellHeight);
    }
    return cellHeight;
}

- (CGFloat)getCellHeightCacheFromDataSource:(NSMutableArray *)dataSource index:(NSInteger)index {
    
    BeanViewFrame *bean = nil;
    if (dataSource == nil) {
        return 0;
        
    } else {
        bean = [self.beanAdaptive warpModelToBeanViewFrameFromtDataSource:dataSource atIndex:index];
    }
    CGFloat cellHeight = [self getCellHeightCacheWithCacheKey:bean.cellHeightKey];
    if (cellHeight) {
//        NSLog(@"从缓存取出cell高度-----%f",cellHeight);
    }
    
    if(!cellHeight){
        cellHeight = bean.cellHeight;
        [self cacheWithCellHeight:cellHeight cacheKey:bean.cellHeightKey];
//        NSLog(@"通过计算获取cell高度-----%f",cellHeight);
    }
    return cellHeight;
    
}
- (BeanViewFrame *)warpModelToBeanViewFrameFromDataSource:(NSMutableArray *)dataSource atIndex:(NSInteger)index {
    
    if (!dataSource || ![dataSource isKindOfClass:[NSMutableArray class]]) {
        @throw [NSException exceptionWithName:@"包装model错误" reason:@"原数据源不是可变类型或不存在" userInfo:nil];
    }
    
    return [self.beanAdaptive warpModelToBeanViewFrameFromtDataSource:dataSource atIndex:index];
}

- (BeanViewFrame *)warpModelToBeanViewFrameByModel:(id)model {
    if (!model) {
        return nil;
    }
    return [self.beanAdaptive warpModelToBeanViewFrameByModel:model];
}

- (BeanViewFrame *)getBeanViewFrameForModle:(id)model {
    if (!model) {
        return nil;
    }
    return [self.beanAdaptive beanViewFrameForModle:model];
}

@end

@implementation UITableView (Preload)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.scrollToToping) {
        [self removeNeedLoadData];
        [self refreshData];
    }
    return [super hitTest:point withEvent:event];
}

- (NSMutableArray<NSIndexPath *> *)needLoadIndexPaths {
    NSMutableArray *needArr = objc_getAssociatedObject(self, _cmd);
    if (needArr == nil) {
        needArr = [NSMutableArray arrayWithCapacity:0];
        objc_setAssociatedObject(self, _cmd, needArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return needArr;
}

- (void)setNeedLoadIndexPaths:(NSMutableArray<NSIndexPath *> *)needLoadIndexPaths {
    objc_setAssociatedObject(self, _cmd, needLoadIndexPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)scrollToToping {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScrollToToping:(BOOL)scrollToToping {
    objc_setAssociatedObject(self, _cmd, @(scrollToToping), OBJC_ASSOCIATION_ASSIGN);
}

/// 加载cell的数据
- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell loadDataFromDataSource:(NSArray *)dataSource atIndexath:(NSIndexPath *)indexPath; {
    
    if (dataSource && [dataSource count]) {
        
        MomentViewCell *mCell = (MomentViewCell *)cell;
        Moment *moment = dataSource[indexPath.row];
        [mCell cancelDraw];
        if (![mCell isKindOfClass:[MomentViewCell class]]) {
            return mCell;
        }
        mCell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 包装Moment为BeanViewFrame不会影响整个数据源, 而会创建一个新的数据源,用于存储BeanViewFrame
        BeanViewFrame *bean = [self warpModelToBeanViewFrameByModel:moment];
        mCell.bean = bean;
        [mCell setTopLineHidde:(indexPath.row != 0)];
        
        if (self.needLoadIndexPaths.count>0 && [self.needLoadIndexPaths indexOfObject:indexPath] == NSNotFound) {
            [mCell cancelDraw];
            return mCell;
        }
        if (self.scrollToToping) {
            return mCell;
        }
        
        [mCell startDraw];
    }
    return cell;
}

/// 刷新cell
- (void)refreshData {
    if (self.scrollToToping) {
        return;
    }
    if (self.indexPathsForVisibleRows.count <=0 ) {
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

/// 按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
- (void)tableViewWillEndDraggingWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset dataSource:(NSArray *)dataSource {
    
    
    NSIndexPath *targetIndexPath = [self indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath *firstVisbleIndexPath = [[self indexPathsForVisibleRows] firstObject];
    NSInteger skipCount = 8;
    NSInteger tCount = labs(firstVisbleIndexPath.row-targetIndexPath.row);
    if (tCount > skipCount) {
        
        CGRect willVisbleRect = CGRectMake(0, targetContentOffset->y, self.frame.size.width, self.frame.size.height);
        [self.needLoadIndexPaths addObjectsFromArray:[self getWillVisbleIndexPathsInRect:willVisbleRect withVelocity:velocity dataSource:dataSource]];
    }
}

- (void)removeNeedLoadData {
    if (self.needLoadIndexPaths) {
        [self.needLoadIndexPaths removeAllObjects];
    }
}

@end

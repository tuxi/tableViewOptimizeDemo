//
//  UITableView+CellHeightCache.h
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/9.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StatusBarOrientation) {
    StatusBarOrientationH = 1,  // 横屏
    StatusBarOrientationV,      // 竖屏
};

@class BeanViewFrame;

@interface BeanViewFrameAdaptive : NSObject

- (BOOL)existsBeanViewFrameForModel:(id<NSCopying>)model;
/// 包装model为BeanViewFrame类型,不会影响model所在的数据源, 但存储到新的字典中 返回包装后的BeanViewFrame对象
- (BeanViewFrame *)warpModelToBeanViewFrameByModel:(id)model;
/// 包装model为BeanViewFrame类型,会影响model所在的数据源, 会将原model替换为包装后的类型 返回包装后的对象
- (BeanViewFrame *)warpModelToBeanViewFrameFromtDataSource:(NSMutableArray *)dataSource atIndex:(NSInteger)index;
- (BeanViewFrame *)beanViewFrameForModle:(id)model;
- (void)removeAllBeanViewFrames;
- (void)removeBeanViewFrameByModel:(id)model;

@end

@interface CellHeightCache : NSObject

- (BOOL)existsHeightForKey:(id)key;
- (void)cacheHeight:(CGFloat)height byKey:(id)key;
- (CGFloat)heightForKey:(id)key;
- (void)removeAllCellHeghtCache;
- (void)removeCellHeightCacheForKey:(id)key;
- (instancetype)initWithTableView:(UITableView *)v;

@end

@interface UITableView (CellHeightCache)

@property (nonatomic, strong) CellHeightCache *cellHeightCache;
@property (nonatomic, strong) BeanViewFrameAdaptive *beanAdaptive;

- (CGFloat)getCellHeightCacheWithCacheKey:(NSString *)cacheKey;
- (void)cacheWithCellHeight:(CGFloat)cellHeight cacheKey:(NSString *)cacheKey;
- (BeanViewFrame *)getBeanViewFrameForModle:(id)model;

/// 包装model为BeanViewFrame类型,不会影响model所在的数据源, 但存储到新的字典 返回包装后的BeanViewFrame对象
- (BeanViewFrame *)warpModelToBeanViewFrameByModel:(id)model;
/// 获取cell的高度 并进行缓存
- (CGFloat)getCellHeightCacheByModel:(id)model;


/// 包装model为BeanViewFrame类型,会影响model所在的数据源, 会将原model替换为包装后的类型 返回BeanViewFrame 包装后的对象
- (BeanViewFrame *)warpModelToBeanViewFrameFromDataSource:(NSMutableArray *)dataSource atIndex:(NSInteger)index;
/// 获取cell的高度 并进行缓存 会替换原数据源中model为包装后的BeanViewFrame类型对象
- (CGFloat)getCellHeightCacheFromDataSource:(NSMutableArray *)dataSource index:(NSInteger)index;

@end

@interface UITableView (Preload)

/// 本分类为了优化tableView的性能添加的，预加载
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *needLoadIndexPaths;
@property (nonatomic, assign) BOOL scrollToToping;

/// 加载cell的数据
- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell loadDataFromDataSource:(NSArray *)dataSource atIndexath:(NSIndexPath *)indexPath;
/// 按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
- (void)tableViewWillEndDraggingWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset dataSource:(NSArray *)dataSource;
- (void)removeNeedLoadData;
/// 刷新cell
- (void)refreshData;
- (void)releaseAll;
@end

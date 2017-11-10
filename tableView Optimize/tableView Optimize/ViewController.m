//
//  ViewController.m
//  tableView Optimize
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "ViewController.h"
#import "MomentViewCell.h"
#import "UITableView+CellHeightCache.h"
#import "OSRunLoop.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataList = [NSMutableArray arrayWithCapacity:0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"moment" ofType:@"json"];
    NSData *jsonD = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:jsonD options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        @throw [NSException exceptionWithName:@"解析json出错" reason:error.debugDescription userInfo:nil];
    }
    
    NSArray *dataList = obj[@"momentObjs"];
    for (id obj in dataList) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Moment *m = [Moment momentWithDic:obj];
            m.nickName = @"旅图";
            m.imageUrl = @"http://files.toodaylab.com/2013/09/sean_williams_1.jpg";
            [self.dataList addObject:m];
        }
    }
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"MomentViewCell";
    MomentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MomentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.xy_selectionStyle = XYSelectionStyleGray;
    
    return [tableView tableViewCell:cell loadDataFromDataSource:_dataList atIndexath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Moment *m = _dataList[indexPath.row];
    
    return [tableView getCellHeightCacheByModel:m];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    UITableView *tableView = (UITableView *)scrollView;
    [tableView removeNeedLoadData];
    
    //  取到当前界面上能显示的indexPaths，判断是否有隐藏
    NSArray <NSIndexPath *>*indexpaths = [tableView indexPathsForVisibleRows];
    UITableViewCell *firstCell  =   [tableView cellForRowAtIndexPath:indexpaths.firstObject];
    UITableViewCell *lastCell   =   [tableView cellForRowAtIndexPath:indexpaths.lastObject];
    
    //  在当前可见的区域中，第一个cell或者最后一个celly已标记为重新加载，那么重新加载可见区域内的cell
    if ([firstCell isKindOfClass:[MomentViewCell class]] && [lastCell isKindOfClass:[MomentViewCell class]]) {
        MomentViewCell *firstC = (MomentViewCell *)firstCell;
        MomentViewCell *lastC = (MomentViewCell *)lastCell;
        NSLog(@"%d -- %d", firstC.isDrawed, lastC.isDrawed);
        if (firstC.isDrawed == NO || lastC.isDrawed == NO) {
//            [tableView reloadRowsAtIndexPaths:indexpaths withRowAnimation:UITableViewRowAnimationNone];
            for (NSIndexPath *indexPath in indexpaths) {
                MomentViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
               
                OSRunLoop.main.max(20).add(^{
                     [cell startDraw];
                });
            }
            
        }
    }
    

}



- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    UITableView *tableView = (UITableView *)scrollView;
    
    [tableView tableViewWillEndDraggingWithVelocity:velocity targetContentOffset:targetContentOffset dataSource:_dataList];
    
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    UITableView *tableView = (UITableView *)scrollView;
    tableView.scrollToToping = YES;
    return YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    UITableView *tableView = (UITableView *)scrollView;
    tableView.scrollToToping = NO;
    [tableView refreshData];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    UITableView *tableView = (UITableView *)scrollView;
    tableView.scrollToToping = NO;
    [tableView refreshData];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        UITableView *tableView = (UITableView *)scrollView;
        tableView.scrollToToping = NO;
        [tableView refreshData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    UITableView *tableView = (UITableView *)scrollView;
    tableView.scrollToToping = NO;
    [tableView refreshData];
}

- (void)dealloc {

}




@end

//
//  CornersImageView.m
//  tableView Optimize
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "CornersImageView.h"
#import "Masonry.h"

@interface CornersImageView ()

@property (nonatomic, weak) UIImageView *cornerView;

@end

@implementation CornersImageView

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    self.cornerView.opaque = YES;
}

- (UIImageView *)cornerView {
    if (_cornerView == nil) {
        UIImageView *cornerView = [UIImageView new];
        _cornerView = cornerView;
        [self addSubview:_cornerView];
        [_cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(-5, -5, -5, -5));
        }];
        _cornerView.image = [UIImage imageNamed:@"corner_circle"];
    }
    return _cornerView;
}

@end

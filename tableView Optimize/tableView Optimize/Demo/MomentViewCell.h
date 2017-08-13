//
//  MomentViewCell.h
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/9.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeanViewFrame.h"

/// cell底部视图按钮类型
typedef NS_ENUM(NSInteger, MommentToolType) {
    MommentToolTypeDistance = 0,
    MommentToolTypeLook,
    MommentToolTypePriase
};


typedef NS_ENUM(NSInteger, XYSelectionStyle) {
    XYSelectionStyleNone,
    XYSelectionStyleBlue,
    XYSelectionStyleGray
};

@class MomentViewCell;

@protocol MomentViewCellDelegate <NSObject>

- (void)momentViewCellDidClickImageFromCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath photos:(NSArray *)photos;
- (void)momentViewCell:(MomentViewCell *)cell didClickPriaseButton:(UIButton *)btn;
- (void)momentViewCell:(MomentViewCell *)cell didClickHeadIcon:(UIImageView *)imageView;
- (void)momentViewCell:(MomentViewCell *)cell seletedLinkWith:(NSURL *)url;
- (void)momentViewCell:(MomentViewCell *)cell seletedPhoneNumber:(NSString *)phoneNumber;

@end


@interface MomentViewCell : UITableViewCell

@property (nonatomic, strong) BeanViewFrame *bean;
@property (nonatomic, weak) id<MomentViewCellDelegate> delegate;
@property (nonatomic, copy) void (^headIconViewClick)();
@property (nonatomic, assign) XYSelectionStyle xy_selectionStyle;
@property (nonatomic, assign, readonly) BOOL isDrawed;


- (void)startDraw;
- (void)cancelDraw;
- (void)releaseAll;

@end


@interface PicContentView : UICollectionView

@property (nonatomic, strong) NSArray<AttachmentPhoto *> *picList;
@property (nonatomic, copy) void (^clickItemCallBack)(NSIndexPath *indexPath, NSArray *photos);
@property (nonatomic, assign) CGSize itemSize;

@end
@class VideoPlayImageView;
@interface PicContentViewCell : UICollectionViewCell

@property (nonatomic, strong) AttachmentPhoto *photo;
@property (nonatomic, weak) VideoPlayImageView *imageView;
- (void)cancelCurrentImageLoad;

@end

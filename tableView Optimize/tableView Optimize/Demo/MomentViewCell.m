//
//  MomentViewCell.m
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/9.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "MomentViewCell.h"
#import "Moment.h"
#import "CornersImageView.h"
#import <Photos/Photos.h>
#import "VideoPlayImageView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "NSString+DrawAdditions.h"

@interface MomentViewCell ()

@property (nonatomic, strong) CornersImageView *headIconView;
@property (nonatomic, strong) UIView *rankView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) PicContentView *picContentView;
@property (nonatomic, strong) MommentToolView *toolView;

//@property (nonatomic, strong) UILabel *userTypeLabel;
//@property (nonatomic, strong) UIImageView *userTypeView;
//@property (nonatomic, strong) UILabel *nickNameLabel;
//@property (nonatomic, strong) UILabel *commentLabel;
//@property (nonatomic, strong) UILabel *dateLabel;
//@property (nonatomic, strong) UILabel *locationLabel; 
/// 标记当前cell是否需要再次刷新
/// 目的：当tableView滑动过快时,不加载cell的数据,以保持滑动流畅，当再次滚动到此cell时，被标记的重新刷新cell，以保住数据显示正确
//@property (nonatomic, assign, getter=isNeedRepeatLoad) BOOL needRepeatLoad;

@property (nonatomic, assign) BOOL isDrawed;
@property (nonatomic, assign, getter=isDrawColorFlag) BOOL drawColorFlag;
@property (nonatomic, strong) UIImageView *cellBackgroundView;
@property (nonatomic, strong) NSOperationQueue *drawQueue;

@end

@implementation MomentViewCell

@synthesize topLineHidde = _topLineHidde;
//@synthesize needRepeatLoad = _isNeedRepeatLoad;

#pragma mark - 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        [self setupEvents];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
        [self setupEvents];
    }
    return self;
}


- (void)setupUI {
    self.cellBackgroundView.opaque = YES;
    self.picContentView.opaque = YES;
    [self clipsToBounds];
    [self nightMode];
    self.layer.shouldRasterize      = YES;
    self.layer.rasterizationScale   = [UIScreen mainScreen].scale;
    self.layer.drawsAsynchronously  = YES;
}

#pragma mark - 加载子控件
/// 开始绘制主要控件，绘制完成后更新数据
- (void)startDraw {
    if (self.isDrawed) {
        return;
    }
    
    [self drawWithBackgroundColor:self.bean.cellBackgroundImageColor completion:^{
        [self updateFrame];
        [self updateDataByBean:self.bean];
    }];
    
   
}

- (void)drawSelectedBackgroundColor:(UIColor *)backgroundColor {
    [self cancelDraw];
    if (self.isDrawed) {
        return;
    }
    
    [self drawWithBackgroundColor:backgroundColor completion:^{
        [self updateFrame];
        [self updateDataByBean:self.bean];
    }];

}

/// 子线程将主要控件绘制到图片上
- (void)drawWithBackgroundColor:(UIColor *)backgroundColor completion: (void (^ __nullable)(void))completion {
//    if (self.drawQueue) {
//        [self.drawQueue setSuspended:NO];
//    }
    BOOL flag = self.isDrawColorFlag;
    self.isDrawed = YES;
    [self.drawQueue addOperationWithBlock:^{
        CGRect rect = CGRectMake(0, 0, SIZE_SCREEN_W, self.bean.cellHeight);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [backgroundColor set];
        CGContextFillRect(context, rect);
        
        [self.bean.nickNameText drawInContext:context withPosition:self.bean.nickNameFrame.origin andFont:kFontWithSize(kSIZE_FONT_NICKNAME) andTextColor:self.bean.nickNameTextColor andHeight:self.bean.nickNameFrame.size.height];
        if (self.bean.commentNumText && self.bean.commentNumText.length) {
            [self.bean.commentNumText drawInContext:context withPosition:self.bean.commentFrame.origin andFont:kFontWithSize(kSIZE_FONT_DEFAULT) andTextColor:self.bean.labelTextColor andHeight:self.bean.commentFrame.size.height];
        }
        if (self.bean.dateText && self.bean.dateText.length) {
            [self.bean.dateText drawInContext:context withPosition:self.bean.dateFrame.origin andFont:kFontWithSize(kSIZE_FONT_DEFAULT) andTextColor:self.bean.labelTextColor andHeight:self.bean.dateFrame.size.height];
        }
        
        if (self.bean.userTypeText && self.bean.userTypeText.length) {
            [self.bean.userTypeText drawInContext:context withPosition:self.bean.userTypeLabelFrame.origin andFont:kFontWithSize(kSIZE_FONT_USERTYPE) andTextColor:self.bean.labelTextColor andHeight:self.bean.userTypeLabelFrame.size.height];
            [[UIImage imageNamed:self.bean.userTypeImageText] drawInRect:self.bean.userTypeViewFrame blendMode:kCGBlendModeNormal alpha:1];
        }
        
        if (self.bean.locationtext && self.bean.locationtext.length) {
            [self.bean.locationtext drawInContext:context withPosition:self.bean.locationFrame.origin andFont:kFontWithSize(kSIZE_FONT_DEFAULT) andTextColor:self.bean.labelTextColor andHeight:self.bean.locationFrame.size.height];
        }
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (flag == self.isDrawColorFlag) {
                self.cellBackgroundView.frame = rect;
                self.cellBackgroundView.image = nil;
                self.cellBackgroundView.image = image;
            }
            
        }];
       
    
    }];
    
    if (completion) {
        completion();
    }

}

- (void)cancelDraw {
    if (!self.isDrawed) {
        return;
    }
    if (self.drawQueue) {
        [self.drawQueue cancelAllOperations];
    }
    self.cellBackgroundView.frame = CGRectZero;
    self.picContentView.itemSize = CGSizeZero;
    self.picContentView.frame = CGRectZero;
    self.picContentView.hidden = YES;
    self.cellBackgroundView.image = nil;
    [self.picContentView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[PicContentViewCell class]]) {
            [cell cancelCurrentImageLoad];
        }
    }];
    self.drawColorFlag = NO;
    self.isDrawed = NO;
}

- (void)releaseAll {
    [self cancelDraw];
    self.drawQueue = nil;
    [super removeFromSuperview];
}

- (void)dealloc {
    [self releaseAll];
}

#pragma mark - Events
- (void)setupEvents {
    __weak typeof(self) weakSelf = self;
    self.picContentView.clickItemCallBack = ^(NSIndexPath *indexPath, NSArray *photos) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentViewCellDidClickImageFromCollectionView:atIndexPath:photos:)]) {
            [weakSelf.delegate momentViewCellDidClickImageFromCollectionView:(UICollectionView *)weakSelf.picContentView atIndexPath:indexPath photos:photos];

        }
    };
    
    self.toolView.btnClickBlock = ^(MommentToolType type){
        switch (type) {
            case MommentToolTypePriase:
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentViewCell:didClickPriaseButton:)]) {
                    [weakSelf.delegate momentViewCell:weakSelf didClickPriaseButton:weakSelf.toolView.btnItems[type]];
                }
                break;
            default:
                break;
        }
    };

    
    [self.headIconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headIconViewClick:)]];
    
}
     
- (void)headIconViewClick:(UITapGestureRecognizer *)tap {
    if (self.headIconViewClick) {
        self.headIconViewClick();
    } else if (self.delegate && [self.delegate respondsToSelector:@selector(momentViewCell:didClickHeadIcon:)]) {
        [self.delegate momentViewCell:self didClickHeadIcon:(UIImageView *)tap.view];
    }
}

///// 设置cell的选中背景颜色
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    switch (self.xy_selectionStyle) {
        case XYSelectionStyleNone:
            break;
        case XYSelectionStyleBlue:
            [self drawSelectedBackgroundColor:self.bean.cellSelectBackgroundColor];
        case XYSelectionStyleGray:
            [self drawSelectedBackgroundColor:[UIColor grayColor]];
        default:
            break;
    }
    
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    switch (self.xy_selectionStyle) {
        case XYSelectionStyleNone:
            break;
        case XYSelectionStyleBlue:
        case XYSelectionStyleGray:
            [self drawSelectedBackgroundColor:self.bean.cellBackgroundImageColor];
        default:
            break;
    }

    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    switch (self.xy_selectionStyle) {
        case XYSelectionStyleNone:
            break;
        case XYSelectionStyleBlue:
        case XYSelectionStyleGray:
            [self drawSelectedBackgroundColor:self.bean.cellBackgroundImageColor];
        default:
            break;
    }
    [[self nextResponder] touchesCancelled:touches withEvent:event];
}

#pragma mark - 设置数据
- (void)updateDataByBean:(BeanViewFrame *)bean {
    
    self.headIconView.hidden = bean.isHiddenHeadIcon;
    if (!bean.isHiddenHeadIcon) {
        [self.headIconView sd_setImageWithURL:[NSURL URLWithString:bean.headIconText]];
    }
    self.contentLabel.text = bean.contentText;
    self.contentLabel.hidden = (bean.contentText.length == 0 | bean.contentText == nil);
    self.toolView.hidden = bean.isHiddenBootomToolView;
    self.toolView.bean = bean;
    self.picContentView.hidden = bean.attachmentList.count == 0;
    self.picContentView.picList = bean.attachmentList;
    
//    self.locationLabel.hidden = bean.isHiddenlocationLabel;
//    self.nickNameLabel.text = bean.nickNameText;
//    self.commentLabel.text = bean.commentNumText;
//    self.dateLabel.hidden = bean.isHiddenDateLabel;
//    self.dateLabel.text = bean.dateText;
//    self.userTypeLabel.text = bean.userTypeText;
//    self.userTypeView.hidden = bean.isHiddenUserType;
//    self.userTypeView.image = [UIImage imageNamed:bean.userTypeImageText];
//    self.userTypeLabel.hidden = bean.isHiddenUserType;
}



- (void)setTopLineHidde:(BOOL)topLineHidde {
    _topLineHidde = topLineHidde;
    self.topLine.hidden = topLineHidde;
}

- (BOOL)isTopLineHidde {
    return self.topLine.hidden;
}

#pragma mark - 布局子控件


- (void)updateFrame {
    self.headIconView.frame = self.bean.headIconFrame;
    self.rankView.frame = self.bean.rankFrame;
    self.contentLabel.frame = self.bean.contentFrame;
    
    self.toolView.frame = self.bean.toolViewFrame;
    self.topLine.frame = self.bean.topLineFrame;
    self.bottomLine.frame = self.bean.bottomLineFrame;
    self.picContentView.frame = self.bean.picContentViewFrame;
    self.picContentView.itemSize = CGSizeMake(self.bean.picContentViewSize.height, self.bean.picContentViewSize.height);
    
//    self.locationLabel.frame = self.bean.locationFrame;
//    self.nickNameLabel.frame = self.bean.nickNameFrame;
//    self.dateLabel.frame = self.bean.dateFrame;
//    self.commentLabel.frame = self.bean.commentFrame;
//    self.userTypeLabel.frame = self.bean.userTypeLabelFrame;
//    self.userTypeView.frame = self.bean.userTypeViewFrame;
}


-(void)nightMode {
    [self.contentLabel setTextColor:IOSRGB(70.0, 70.0, 70.0)];
    [self.bottomLine setBackgroundColor:IOSRGB(225.0, 225.0, 225.0)];
    [self.topLine setBackgroundColor:IOSRGB(225.0, 225.0, 225.0)];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.toolView setBackgroundColor:[UIColor clearColor]];
    [self.picContentView setBackgroundColor:[UIColor whiteColor]];
    
//     [self.locationLabel setTextColor:[UIColor grayColor]];
//    SetGrayTextColorForLabel(self.dateLabel);
//    SetBlueTextColorForLabel(self.nickNameLabel);
//    SetGrayTextColorForLabel(self.commentLabel);
//    SetGrayTextColorForLabel(self.userTypeLabel);
}

#pragma mark - Lazy
- (NSOperationQueue *)drawQueue {
    if (_drawQueue == nil) {
        _drawQueue = [NSOperationQueue new];
        _drawQueue.maxConcurrentOperationCount = 3;
    }
    return _drawQueue;
}

- (UIImageView *)cellBackgroundView {
    if (_cellBackgroundView == nil) {
        _cellBackgroundView = [UIImageView new];
        [self.contentView insertSubview:_cellBackgroundView atIndex:0];
    }
    return _cellBackgroundView;
}

- (MommentToolView *)toolView {
    if (_toolView == nil) {
        _toolView = [MommentToolView new];
        _toolView.backgroundColor = [UIColor clearColor];
        _toolView.opaque = YES;
        [self.contentView addSubview:_toolView];
    }
    return _toolView;
}

- (CornersImageView *)headIconView {
    if (_headIconView == nil) {
        _headIconView = [CornersImageView new];
        _headIconView.opaque = YES;
        _headIconView.userInteractionEnabled = YES;
        [self.contentView addSubview:_headIconView];
    }
    return _headIconView;
}

- (UIView *)rankView {
    if (_rankView == nil) {
        _rankView = [UIView new];
        _rankView.opaque = YES;
        _rankView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_rankView];
    }
    return _rankView;
}


- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [UILabel new];
        [_contentLabel setFont:kFontWithSize(kSIZE_FONT_CONTENT)];
        _contentLabel.numberOfLines = 2;
        _contentLabel.opaque = YES;
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [UIView new];
        _bottomLine.opaque = YES;
        [self.contentView addSubview:_bottomLine];
        [self.contentView bringSubviewToFront:_bottomLine];
    }
    return _bottomLine;
}

- (UIView *)topLine {
    if (_topLine == nil) {
        _topLine = [UIView new];
        _topLine.opaque = YES;
        [self.contentView addSubview:_topLine];
        [self.contentView bringSubviewToFront:_topLine];
    }
    return _topLine;
}


- (PicContentView *)picContentView {
    if (_picContentView == nil) {
        _picContentView = [[PicContentView alloc] init];
        _picContentView.opaque = YES;
        [self.contentView addSubview:_picContentView];
    }
    return _picContentView;
}

//- (UILabel *)locationLabel {
//    if (_locationLabel == nil) {
//        _locationLabel = [UILabel new];
//        _locationLabel.opaque = YES;
//        [_locationLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
//        _locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//        _locationLabel.numberOfLines = 1;
//        [self.contentView addSubview:_locationLabel];
//    }
//    return _locationLabel;
//}

//- (UILabel *)userTypeLabel {
//    if (_userTypeLabel == nil) {
//        _userTypeLabel = [UILabel new];
//        [self.contentView addSubview:_userTypeLabel];
//        [_userTypeLabel setFont:kFontWithSize(kSIZE_FONT_USERTYPE)];
//        _userTypeLabel.opaque = YES;
//    }
//    return _userTypeLabel;
//}
//
//- (UIImageView *)userTypeView {
//    if (_userTypeView == nil) {
//        _userTypeView = [UIImageView new];
//        [self.contentView addSubview:_userTypeView];
//        _userTypeView.opaque = YES;
//        _userTypeView.contentMode = UIViewContentModeScaleAspectFit;
//    }
//    return _userTypeView;
//}
//
//- (UILabel *)nickNameLabel {
//    if (_nickNameLabel == nil) {
//        _nickNameLabel = [UILabel new];
//        _nickNameLabel.opaque = YES;
//        [_nickNameLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
//        [self.contentView addSubview:_nickNameLabel];
//    }
//    return _nickNameLabel;
//}
//
//- (UILabel *)dateLabel {
//    if (_dateLabel == nil) {
//        _dateLabel = [UILabel new];
//        _dateLabel.opaque = YES;
//        [_dateLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
//        [self.contentView addSubview:_dateLabel];
//    }
//    return _dateLabel;
//}
//- (UILabel *)commentLabel {
//    if (_commentLabel == nil) {
//        _commentLabel = [UILabel new];
//        _commentLabel.opaque = YES;
//        [_commentLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
//        [self.contentView addSubview:_commentLabel];
//    }
//    return _commentLabel;
//}


//////////////////////////////////////////////////////////////////////////////////////
/* 注释掉的是使用约束布局子控件的，另外是直接把主要控件添加到contentView上了，滑动还是卡顿，
 * 上面的是使用frame布局子控件的，另外使用图形上下文对主要控件进行绘制，效果好些, 如果使用过程中发现上面的方法有问题就删除上面的，使用下面的
 - (void)setupUI {
 
 self.picContentView.opaque = YES;
 self.contentView.backgroundColor = [UIColor clearColor];
 [self.contentView clipsToBounds];
 
 [self makeConstraints];
 [self nightMode];
 self.layer.shouldRasterize      = YES;
 self.layer.rasterizationScale   = [UIScreen mainScreen].scale;
 self.layer.drawsAsynchronously  = YES;
 }
 
 
 #pragma mark - Events
 - (void)setupEvents {
 __weak typeof(self) weakSelf = self;
 self.picContentView.clickItemCallBack = ^(NSIndexPath *indexPath, NSArray *photos) {
 if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentViewCellDidClickImageFromCollectionView:atIndexPath:photos:)]) {
 [weakSelf.delegate momentViewCellDidClickImageFromCollectionView:(UICollectionView *)weakSelf.picContentView atIndexPath:indexPath photos:photos];
 
 }
 };
 
 self.toolView.btnClickBlock = ^(MommentToolType type){
 switch (type) {
 case MommentToolTypePriase:
 if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(momentViewCell:didClickPriaseButton:)]) {
 [weakSelf.delegate momentViewCell:weakSelf didClickPriaseButton:weakSelf.toolView.btnItems[type]];
 }
 break;
 default:
 break;
 }
 };
 
 
 [self.headIconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headIconViewClick:)]];
 }
 
 - (void)headIconViewClick:(UITapGestureRecognizer *)tap {
 if (self.headIconViewClick) {
 self.headIconViewClick();
 } else if (self.delegate && [self.delegate respondsToSelector:@selector(momentViewCell:didClickHeadIcon:)]) {
 [self.delegate momentViewCell:self didClickHeadIcon:(UIImageView *)tap.view];
 }
 }
 
 
 #pragma mark  - label delegate
 - (void)attributedLabel:(UILabel *)label
 didSelectLinkWithURL:(NSURL *)url{
 if (self.delegate && [self.delegate respondsToSelector:@selector(momentViewCell:seletedLinkWith:)]) {
 [self.delegate momentViewCell:self seletedLinkWith:url];
 }
 }
 
 - (void)attributedLabel:(UILabel *)label
 didSelectLinkWithPhoneNumber:(NSString *)phoneNumber{
 if (self.delegate && [self.delegate respondsToSelector:@selector(momentViewCell:seletedPhoneNumber:)]) {
 [self.delegate momentViewCell:self seletedPhoneNumber:phoneNumber];
 }
 }
 
 #pragma mark - 设置数据
 
 - (void)setBean:(BeanViewFrame *)bean {
 
 _bean = bean;
 
 self.dateLabel.text = bean.dateText;
 self.nickName.text = bean.nickNameStr;
 [self.headIconView loadImageWithURL:[NSURL URLWithString:bean.headIconStr] placeHolderImage:DEFALTUSERIMAGE];
 self.commentLabel.text = bean.commentNumText;
 self.contentLabel.text = bean.contentText;
 self.picContentView.picList = [bean.attachmentList mutableCopy];
 self.contentLabel.hidden = (bean.contentText.length == 0 | bean.contentText == nil);
 __weak typeof(_bean) weakBean = _bean;
 WS(weakSelf)
 //    [NSTimer scheduledTimerWithTimeInterval:0 repeats:0 block:^(NSTimer * _Nonnull timer) {
 [bean getLocationText:^(NSString *resultText, BeanViewFrame *bean2) {
 if (weakBean == bean2) {
 weakSelf.locationLabel.text = resultText;
 }
 }];
 //    }];
 
 self.locationLabel.hidden = bean.isHiddenlocationLabel;
 self.toolView.hidden = bean.isHiddenBootomToolView;
 self.picContentView.hidden = bean.attachmentList.count == 0;
 self.rankView.rank = bean.rankNum;
 self.userTypeLabel.text = bean.userTypeStr;
 self.userTypeView.image = [UIImage imageNamed:bean.userTypeImageStr];
 self.toolView.bean = bean;
 self.userTypeView.hidden = bean.isHiddenUserType;
 self.userTypeLabel.hidden = bean.isHiddenUserType;
 
 if (bean.isHiddenlocationLabel) {
 [self makeConstraints];
 }
 
 [self updatePicContentView:bean];
 
 
 }
 
 - (void)updatePicContentView:(BeanViewFrame *)bean {
 
 if (bean.contentText && bean.contentText.length) {
 // 有content 有图片
 if (bean.attachmentList.count) {
 [self.picContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.nickName);
 make.top.equalTo(self.contentLabel.mas_bottom).mas_offset(SIZE_MARGIN_SMALL_MOMENTVIEW);
 make.height.equalTo(@([bean picContentViewSize].height));
 make.width.equalTo(@([bean picContentViewSize].width));
 }];
 }
 
 } else {
 // 没有content 文本 但是有照片时
 if (bean.attachmentList.count) {
 [self.picContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.nickName);
 make.top.equalTo(self.rankView.mas_bottom).mas_offset(SIZE_MARGIN_SMALL_MOMENTVIEW);
 make.height.equalTo(@([bean picContentViewSize].height));
 make.width.equalTo(@([bean picContentViewSize].width));
 }];
 }
 
 }
 
 self.picContentView.itemSize = CGSizeMake(self.bean.picContentViewSize.height, self.bean.picContentViewSize.height);
 }
 
 
 - (void)setTopLineHidde:(BOOL)topLineHidde {
 _topLineHidde = topLineHidde;
 self.topLine.hidden = topLineHidde;
 }
 
 - (BOOL)isTopLineHidde {
 return self.topLine.hidden;
 }
 
 - (BOOL)isNeedRepeatLoad {
 return _isNeedRepeatLoad ?: NO;
 }
 
 - (void)markNeedRepeatLoad {
 self.needRepeatLoad = YES;
 [[SDWebImageManager sharedManager] cancelAll];
 for (PicContentViewCell *cell in self.picContentView.visibleCells) {
 if ([cell isKindOfClass:[PicContentViewCell class]]) {
 [cell cancelCurrentImageLoad];
 }
 }
 }
 
 - (void)cancelRepeatLoad {
 self.needRepeatLoad = NO;
 }
 
 #pragma mark - 布局子控件
 
 - (void)layoutSubviews {
 [super layoutSubviews];
 
 [self updatePicContentView:self.bean];
 }
 
 
 - (void)makeConstraints {
 
 [self.headIconView mas_makeConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.contentView).mas_offset(SIZE_MARGIN_MOMENTVIEW);
 make.top.equalTo(self.contentView).mas_offset(SIZE_HEADICON_TOPMARGIN_MOMENTVIEW);
 make.width.height.equalTo(@(SIZE_HEADICON_WH_MOMENTVIEW));
 }];
 
 [self.nickName mas_updateConstraints:^(MASConstraintMaker *make) {
 CGFloat nickNameY = !self.bean ? SIZE_MARGIN_SMALL_MOMENTVIEW : self.bean.nickNameY;
 make.top.equalTo(self.contentView).mas_offset(nickNameY);
 make.left.equalTo(self.headIconView.mas_right).mas_offset(SIZE_MARGIN_MOMENTVIEW);
 }];
 
 [self.userTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
 make.top.bottom.equalTo(self.nickName);
 make.left.equalTo(self.nickName.mas_right).mas_offset(SIZE_MARGIN_MOMENTVIEW);
 }];
 
 [self.userTypeView mas_updateConstraints:^(MASConstraintMaker *make) {
 make.centerY.equalTo(self.nickName);
 make.width.height.equalTo(@(16));
 make.left.equalTo(self.userTypeLabel.mas_right).mas_offset(SIZE_MARGIN_SMALL_MOMENTVIEW);
 }];
 
 [self.rankView mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.nickName);
 make.top.equalTo(self.nickName.mas_bottom).mas_offset(SIZE_MARGIN_SMALL_MOMENTVIEW);
 make.width.equalTo(@(SIZE_RANK_W_MOMENTVIEW));
 make.height.equalTo(@(SIZE_RANK_H_MOMENTVIEW));
 }];
 
 [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
 make.top.bottom.equalTo(self.rankView);
 make.left.equalTo(self.rankView.mas_right).equalTo(@(SIZE_MARGIN_SMALL_MOMENTVIEW));
 }];
 
 [self.dateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
 make.top.bottom.equalTo(self.rankView);
 make.right.equalTo(self.contentView).mas_offset(@(-SIZE_MARGIN_MOMENTVIEW));
 }];
 
 [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.nickName);
 make.right.equalTo(self.contentView).mas_offset(-SIZE_MARGIN_MOMENTVIEW);
 make.top.equalTo(self.rankView.mas_bottom).mas_offset(SIZE_MARGIN_SMALL_MOMENTVIEW);
 }];
 
 
 [self.locationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.nickName);
 make.right.equalTo(self.contentView).mas_offset(-SIZE_MARGIN_MOMENTVIEW);
 }];
 
 [self.toolView mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.equalTo(self.nickName);
 make.right.equalTo(self.contentView).mas_offset(-SIZE_MARGIN_MOMENTVIEW);
 make.height.equalTo(@(SIZE_TOOLVIEW_H_MOMENTVIEW));
 make.top.equalTo(self.locationLabel.mas_bottom).mas_offset(0);
 make.bottom.equalTo(self.bottomLine);
 }];
 
 [self.topLine mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.right.top.equalTo(self.contentView);
 make.height.equalTo(@(SIZE_LINE_H_MOMENTVIEW));
 }];
 
 [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
 make.left.bottom.right.equalTo(self.contentView);
 make.height.equalTo(@(SIZE_LINE_H_MOMENTVIEW));
 }];
 
 MASAttachKeys(self.headIconView, self.nickName, self.rankView, self.commentLabel, self.dateLabel, self.contentLabel, self.locationLabel, self.toolView, self.topLine, self.bottomLine, self.picContentView);
 }
 
 
 -(void)nightMode {
 SetDayNightTextColorForLabel(self.contentLabel);
 SetGrayTextColorForLabel(self.locationLabel);
 SetGrayTextColorForLabel(self.dateLabel);
 SetBlueTextColorForLabel(self.nickName);
 SetGrayTextColorForLabel(self.commentLabel);
 SetGrayTextColorForLabel(self.userTypeLabel);
 SetImageViewImage(self.headIconView, @"login_nophoto");
 SetLineBackGroundColorForView(self.bottomLine);
 SetLineBackGroundColorForView(self.topLine);
 SetDayNightBackGroundColorForView(self);
 SetDayNightBackGroundColorForView(self.contentView);
 SetDayNightBackGroundColorForView(self.toolView);
 SetDayNightBackGroundColorForView(self.picContentView);
 
 }
 
 #pragma mark - Lazy
 - (MommentToolView *)toolView {
 if (_toolView == nil) {
 _toolView = [MommentToolView new];
 _toolView.opaque = YES;
 [self.contentView addSubview:_toolView];
 }
 return _toolView;
 }
 
 - (CornersImageView *)headIconView {
 if (_headIconView == nil) {
 _headIconView = [CornersImageView new];
 _headIconView.opaque = YES;
 _headIconView.userInteractionEnabled = YES;
 [self.contentView addSubview:_headIconView];
 }
 return _headIconView;
 }
 
 - (UILabel *)nickName {
 if (_nickName == nil) {
 _nickName = [UILabel new];
 _nickName.opaque = YES;
 [_nickName setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
 [self.contentView addSubview:_nickName];
 }
 return _nickName;
 }
 
 - (UILabel *)dateLabel {
 if (_dateLabel == nil) {
 _dateLabel = [UILabel new];
 _dateLabel.opaque = YES;
 [_dateLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
 [self.contentView addSubview:_dateLabel];
 }
 return _dateLabel;
 }
 
 - (EYRankView *)rankView {
 if (_rankView == nil) {
 _rankView = [EYRankView new];
 _rankView.opaque = YES;
 _rankView.rankColor = [UIColor lightGrayColor];
 [self.contentView addSubview:_rankView];
 }
 return _rankView;
 }
 
 
 - (UILabel *)contentLabel {
 if (_contentLabel == nil) {
 _contentLabel = [UILabel new];
 [_contentLabel setFont:kFontWithSize(kSIZE_FONT_CONTENT)];
 _contentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink  | NSTextCheckingTypePhoneNumber;
 _contentLabel.numberOfLines = 2;
 _contentLabel.opaque = YES;
 NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
 [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
 [linkAttributes setValue:(__bridge id)IOSRGB(0, 100, 255).CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
 _contentLabel.linkAttributes = linkAttributes;
 _contentLabel.delegate = self;
 [self.contentView addSubview:_contentLabel];
 }
 return _contentLabel;
 }
 
 - (UILabel *)commentLabel {
 if (_commentLabel == nil) {
 _commentLabel = [UILabel new];
 _commentLabel.opaque = YES;
 [_commentLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
 [self.contentView addSubview:_commentLabel];
 }
 return _commentLabel;
 }
 
 - (UIView *)bottomLine {
 if (_bottomLine == nil) {
 _bottomLine = [UIView new];
 _bottomLine.opaque = YES;
 [self.contentView addSubview:_bottomLine];
 }
 return _bottomLine;
 }
 
 - (UIView *)topLine {
 if (_topLine == nil) {
 _topLine = [UIView new];
 _topLine.opaque = YES;
 [self.contentView addSubview:_topLine];
 }
 return _topLine;
 }
 
 - (UILabel *)locationLabel {
 if (_locationLabel == nil) {
 _locationLabel = [UILabel new];
 _locationLabel.opaque = YES;
 [_locationLabel setFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
 _locationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
 _locationLabel.numberOfLines = 1;
 [self.contentView addSubview:_locationLabel];
 }
 return _locationLabel;
 }
 
 - (PicContentView *)picContentView {
 if (_picContentView == nil) {
 _picContentView = [[PicContentView alloc] init];
 _picContentView.opaque = YES;
 _picContentView.prefetchingEnabled = NO;
 [self.contentView addSubview:_picContentView];
 }
 return _picContentView;
 }
 
 - (UILabel *)userTypeLabel {
 if (_userTypeLabel == nil) {
 _userTypeLabel = [UILabel new];
 [self.contentView addSubview:_userTypeLabel];
 [_userTypeLabel setFont:kFontWithSize(kSIZE_FONT_USERTYPE)];
 _userTypeLabel.opaque = YES;
 }
 return _userTypeLabel;
 }
 
 - (UIImageView *)userTypeView {
 if (_userTypeView == nil) {
 _userTypeView = [UIImageView new];
 [self.contentView addSubview:_userTypeView];
 _userTypeView.opaque = YES;
 _userTypeView.contentMode = UIViewContentModeScaleAspectFit;
 }
 return _userTypeView;
 }
 
 */
//////////////////////////////////////////////////////////////////////////////////////

@end


@interface MommentToolView ()

@property (nonatomic, strong) NSMutableArray<UILabel *> *labelItems;
@property (nonatomic, strong) NSMutableArray<UIButton *> *btnItems;

@end

@implementation MommentToolView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _btnItems = [NSMutableArray arrayWithCapacity:3];
    _labelItems = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.tag = i;
        b.opaque = YES;
        [self addSubview:b];
        [self.btnItems addObject:b];
        [b addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        b.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [b setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        UILabel *l = [UILabel new];
        [l setFont:kFontWithSize(kSIZE_FONT_TOOLVIEW)];
        l.tag = i;
        l.opaque = YES;
        [self addSubview:l];
        [self.labelItems addObject:l];
    }
    
    [self makeConstraints];
    
    [_labelItems[0] setTextColor:[UIColor grayColor]];
    [_labelItems[1] setTextColor:[UIColor grayColor]];
    [_labelItems[2] setTextColor:[UIColor grayColor]];
    [_btnItems[2] setImage:[UIImage imageNamed:@"icon_correct"] forState:UIControlStateNormal];
    [_btnItems[1] setImage:[UIImage imageNamed:@"icon_read"] forState:UIControlStateNormal];
    
}

- (void)btnClick:(UIButton *)btn {
    if (self.btnClickBlock) {
        self.btnClickBlock(btn.tag);
    }
}


- (void)makeConstraints {
    
    CGFloat bw = 28.0;
    [_btnItems[0] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(@0);
    }];
    
    [_labelItems[0] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_btnItems[0].mas_right);
        make.top.bottom.equalTo(self);
    }];
    
    [_btnItems[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.equalTo(self);
        make.width.equalTo(@(bw));
    }];
    [_labelItems[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_btnItems[1].mas_right);
        make.top.bottom.equalTo(self);
    }];
    
    [_btnItems[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_labelItems[2].mas_left);
        make.top.bottom.equalTo(self);
        make.width.equalTo(@(bw));
    }];
    [_labelItems[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
    }];
    
}

- (void)setBean:(BeanViewFrame *)bean {
    _bean = bean;
    [self.labelItems[MommentToolTypeDistance] setText:bean.dictanceText];
    [self.labelItems[MommentToolTypeLook] setText:bean.viewNumText];
    [self.labelItems[MommentToolTypePriase] setText:bean.likeNumText];
    
    [self setPriaseLiked:bean.alreadyLiked];
}

#pragma mark - 设置数据

- (void)setPriaseLiked:(BOOL)liked {
    if (liked) {
        [self.btnItems[MommentToolTypePriase] setImage:[UIImage imageNamed:@"icon_liked"] forState:UIControlStateNormal];
        [self.btnItems[MommentToolTypePriase] setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }else{
        [self.btnItems[MommentToolTypePriase] setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
        [self.btnItems[MommentToolTypePriase] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}



- (void)dealloc {
    [_btnItems removeAllObjects];
    [_labelItems removeAllObjects];
}

@end

@interface PicContentView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation PicContentView

#pragma mark - 初始化
- (instancetype)init {
    return [self initWithFrame:CGRectZero collectionViewLayout:self.layout];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[PicContentViewCell class] forCellWithReuseIdentifier:NSStringFromClass([PicContentViewCell class])];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void)setPicList:(NSArray<AttachmentPhoto *> *)picList {
    if (!picList && picList == _picList) return;
    _picList = picList;
    [self reloadData];
}

- (UICollectionViewFlowLayout *)layout {
    if (_layout == nil) {
        _layout = [UICollectionViewFlowLayout new];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumLineSpacing = SIZE_MARGIN_SMALL_MOMENTVIEW;
    }
    return _layout;
}


#pragma mark - collectionView 代理和数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.picList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PicContentViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PicContentViewCell class]) forIndexPath:indexPath];
    cell.photo = self.picList[indexPath.row];
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSMutableArray  * photos = [NSMutableArray array];
//    
//    for (int i = 0; i < self.picList.count; i ++) {
//        id obj = self.picList[i];
//        if ([obj isKindOfClass:[AttachmentPhoto class]]) {
//            AttachmentPhoto * attch = obj;
//            if (!attch.videoUrl || attch.videoUrl.length == 0 || ![attch.videoUrl containsString:@"mp4"]) {
//                IDMPhoto    * photo = [IDMPhoto photoWithURL:[NSURL URLWithString:attch.url]];
//                photo.thumbnailURL = [NSURL URLWithString:attch.thumUrl];
//                [photos addObject:photo];
//            }
//            else {
//                IDMPhoto *video = [IDMPhoto photoWithURL:[NSURL URLWithString:attch.url]];
//                video.videoURL = [NSURL URLWithString:attch.videoUrl];
//                if (attch.thumUrl) {
//                    video.thumbnailURL = [NSURL URLWithString:attch.thumUrl];
//                }
//                [photos addObject:video];
//            }
//        }else if ([obj isKindOfClass:[PHAsset class]]){
//            PHAsset * asset = obj;
//            IDMPhoto * photo = [IDMPhoto photoWithAsset:obj targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
//            [photos addObject:photo];
//        }else if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj containsString:@"mp4"]){
//            obj = [[obj componentsSeparatedByString:@"/"] lastObject];
//            ChatMessageModel * model = [ChatMessageModel new];
//            model.contentType = chatContentTypeVideo;
//            NSString * path = [model getFileDocumentPath];
//            path = [path stringByAppendingString:obj];
//            NSURL   * url = [NSURL fileURLWithPath:path];
//            UIImage * thumbNail = [AppUtil thumbnailImageForVideo:url atTime:0];
//            IDMPhoto * video = [IDMPhoto photoWithImage:thumbNail];
//            video.videoURL = url;
//            [photos addObject:video];
//            
//        }
//    }
//    
//    PicContentViewCell *cell = (PicContentViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    IDMPhotoBrowser * browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:cell.imageView];
//    browser.seletedIndex = indexPath.row;
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:browser animated:YES completion:nil];
//    
//    if (self.clickItemCallBack) {
//        self.clickItemCallBack(indexPath, photos);
//    }
// 
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}



@end

@interface PicContentViewCell ()

@end

@implementation PicContentViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView.opaque = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.imageView.opaque = YES;
    }
    return self;
}

- (VideoPlayImageView *)imageView {
    if (_imageView == nil) {
        VideoPlayImageView *i = [VideoPlayImageView new];
        [self.contentView addSubview:i];
        _imageView = i;
        _imageView.userInteractionEnabled = NO;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [i mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _imageView;
}

- (void)setPhoto:(AttachmentPhoto *)photo {
    _photo = photo;
    
    if ([photo isKindOfClass:[AttachmentPhoto class]]) {
        AttachmentPhoto * attch = photo;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:attch.thumUrl]];
        if (attch.videoUrl && ![attch.videoUrl isEqualToString:@""]) {
//            self.imageView.PlayImage.hidden = NO;
        }else{
//            self.imageView.PlayImage.hidden = YES;
        }
    } else if ([photo isKindOfClass:[PHAsset class]]){
        PHAsset *asset = (PHAsset *)photo;
        [self dealImageView:self.imageView withPHAsset:asset];
    }

}

/// 通过PHAsset设置图片
- (void)dealImageView:(UIImageView *)imageView withPHAsset:(PHAsset *)asset {
    CGSize  targetSize;
    if (asset.pixelWidth > asset.pixelHeight) {
        if (asset.pixelWidth > 320) {
            targetSize = CGSizeMake(320, 320/asset.pixelWidth*asset.pixelHeight);
        }else{
            targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        }
    }else{
        if (asset.pixelHeight > 320) {
            targetSize = CGSizeMake(320/asset.pixelHeight*asset.pixelWidth, 320);
        }else{
            targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        }
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.synchronous = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            imageView.image = result;
        }
    }];
}

- (void)cancelCurrentImageLoad {
    [self.imageView sd_cancelCurrentImageLoad];
}


@end

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

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MommentBottomView : UIView

@property (nonatomic, copy) void (^btnClickBlock)(MommentToolType type);
@property (nonatomic, strong) BeanViewFrame *bean;
@property (nonatomic, strong, readonly) NSMutableArray<UILabel *> *labelItems;
@property (nonatomic, strong, readonly) NSMutableArray<UIButton *> *btnItems;

@end

@interface MomentViewCell ()

@property (nonatomic, strong) CornersImageView *headIconView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) PicContentView *picContentView;
@property (nonatomic, strong) MommentBottomView *toolView;

@property (nonatomic, assign) BOOL isDrawed;
@property (nonatomic, assign, getter=isDrawColorFlag) BOOL drawColorFlag;
@property (nonatomic, strong) UIImageView *cellBackgroundView;
@property (nonatomic, strong) NSOperationQueue *drawQueue;

@property (nonatomic, strong) UIView *selectedBackgroundView_;

@end

@implementation MomentViewCell


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
    [self setClipsToBounds:YES];
    [self nightMode];
    self.layer.shouldRasterize      = YES;
    self.layer.rasterizationScale   = [UIScreen mainScreen].scale;
    self.layer.drawsAsynchronously  = YES;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.selectedBackgroundView = [self selectedBackgroundView_];
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
        
        [[UIImage imageWithColor:[UIColor lightGrayColor]] drawInRect:self.bean.rankFrame blendMode:kCGBlendModeNormal alpha:1.0];
        [[UIImage imageWithColor:IOSRGB(225.0, 225.0, 225.0)] drawInRect:self.bean.bottomLineFrame blendMode:kCGBlendModeNormal alpha:1.0];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_block_t completion = ^{
            if (flag == self.isDrawColorFlag) {
                self.cellBackgroundView.frame = rect;
                self.cellBackgroundView.image = nil;
                self.cellBackgroundView.image = image;
            }

        };
        [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
       
    
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self highlightCell:selected];
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self highlightCell:highlighted];
}

- (void)highlightCell:(BOOL)highlight {
    
    [self cancelDraw];
    
    switch (self.xy_selectionStyle) {
        case XYSelectionStyleNone:
            break;
        case XYSelectionStyleBlue:
            if (highlight) {
                [self drawSelectedBackgroundColor:self.bean.cellSelectBackgroundColor];
            }
            else {
                [self drawSelectedBackgroundColor:self.bean.cellBackgroundImageColor];
            }
        case XYSelectionStyleGray:
            if (highlight) {
                [self drawSelectedBackgroundColor:self.bean.cellSelectBackgroundColor];
            }
            else {
                [self drawSelectedBackgroundColor:self.bean.cellBackgroundImageColor];
            }
        default:
            break;
    }

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




#pragma mark - 布局子控件


- (void)updateFrame {
    self.headIconView.frame = self.bean.headIconFrame;
//    self.rankView.frame = self.bean.rankFrame;
    self.contentLabel.frame = self.bean.contentFrame;
    
    self.toolView.frame = self.bean.toolViewFrame;
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

- (UIView *)selectedBackgroundView_ {
    if (!_selectedBackgroundView_) {
        _selectedBackgroundView_ = [UIView new];
        _selectedBackgroundView_.backgroundColor = UIColorFromRGB(0xc8ebff);
    }
    return _selectedBackgroundView_;
}

- (UIImageView *)cellBackgroundView {
    if (_cellBackgroundView == nil) {
        _cellBackgroundView = [UIImageView new];
        [self.contentView insertSubview:_cellBackgroundView atIndex:0];
    }
    return _cellBackgroundView;
}

- (MommentBottomView *)toolView {
    if (_toolView == nil) {
        _toolView = [MommentBottomView new];
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
        _headIconView.userInteractionEnabled = NO;
        [self.contentView addSubview:_headIconView];
    }
    return _headIconView;
}

//- (UIView *)rankView {
//    if (_rankView == nil) {
//        _rankView = [UIView new];
//        _rankView.opaque = YES;
//        _rankView.backgroundColor = [UIColor lightGrayColor];
//        [self.contentView addSubview:_rankView];
//    }
//    return _rankView;
//}


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


- (PicContentView *)picContentView {
    if (_picContentView == nil) {
        _picContentView = [[PicContentView alloc] init];
        _picContentView.opaque = YES;
        [self.contentView addSubview:_picContentView];
    }
    return _picContentView;
}


@end


@interface MommentBottomView ()

@property (nonatomic, strong) NSMutableArray<UILabel *> *labelItems;
@property (nonatomic, strong) NSMutableArray<UIButton *> *btnItems;

@end

@implementation MommentBottomView

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
        make.left.equalTo(self);
        make.top.equalTo(self).mas_offset(3);
        make.bottom.equalTo(self).mas_offset(-3);
        make.width.equalTo(@0);
    }];
    
    [_labelItems[0] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_btnItems[0].mas_right);
        make.top.equalTo(self).mas_offset(3);
        make.bottom.equalTo(self).mas_offset(-3);
    }];
    
    [_btnItems[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).mas_offset(3);
        make.bottom.equalTo(self).mas_offset(-3);
        make.width.equalTo(@(bw));
    }];
    [_labelItems[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_btnItems[1].mas_right);
        make.top.equalTo(self).mas_offset(3);
        make.bottom.equalTo(self).mas_offset(-3);
    }];
    
    [_btnItems[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_labelItems[2].mas_left);
        make.top.equalTo(self).mas_offset(3);
        make.bottom.equalTo(self).mas_offset(-3);
        make.width.equalTo(@(bw));
    }];
    [_labelItems[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self).mas_offset(3);
        make.bottom.equalTo(self).mas_offset(-3);
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
        [self setClipsToBounds:YES];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.imageView.opaque = YES;
        [self setClipsToBounds:YES];
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

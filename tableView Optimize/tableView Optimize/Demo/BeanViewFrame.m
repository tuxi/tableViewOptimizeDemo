//
//  BeanViewFrame.m
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "BeanViewFrame.h"
#import "Boobuz.h"
#import "NSString+DrawAdditions.h"

const CGFloat SIZE_MARGIN_MOMENTVIEW = 8.0;
const CGFloat SIZE_MARGIN_SMALL_MOMENTVIEW = 5.0;
const CGFloat SIZE_HEADICON_WH_MOMENTVIEW = 60.0;
const CGFloat SIZE_RANK_H_MOMENTVIEW = 13.0;
const CGFloat SIZE_RANK_W_MOMENTVIEW = 80.0;
const CGFloat SIZE_TOOLVIEW_H_MOMENTVIEW = 22.0;
const CGFloat SIZE_LINE_H_MOMENTVIEW = 0.5;
const CGFloat SIZE_IMAGEVIEW_MARGIN_MOMENTVIEW = 5.0;
const CGFloat SIZE_HEADICON_TOPMARGIN_MOMENTVIEW = 16.0;
const CGFloat SIZE_USERTYPEVIEW_WH_MOMENT = 16.0;

@interface BeanViewFrame ()

@property (nonatomic, assign) CGFloat   posX;
@property (nonatomic, assign) CGFloat   posY;
@property (nonatomic, copy) NSString    *content;
@property (nonatomic, strong) NSArray<AttachmentPhoto *> *attachments;
@property (nonatomic, strong) NSNumber  * viewNum;
@property (nonatomic, strong) NSNumber  *likeNum;
@property (nonatomic, assign) NSInteger commentNum;
@property (nonatomic, assign) CGFloat   rank;
@property (nonatomic, copy) NSString    *address;
@property (nonatomic, copy) NSString    *city;
@property (nonatomic, copy) NSString    *country;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger updateTime;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *headIcon;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) BOOL isMeDetailPage;

@property (nonatomic, assign) NSInteger poiId;
@property (nonatomic, assign) NSNumber *profile;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, assign) NSInteger mile; // 积分
@property (nonatomic, strong) NSNumber *talkNum;


@end

@implementation BeanViewFrame

#pragma mark - 初始化
+ (instancetype)viewFrameWithModel:(id)model {
    return [[self alloc] initWithModel:model];
}

- (instancetype)initWithModel:(id)model {
    if (self = [super init]) {
        
        self.model = model;
        _cellHeightKey = [self getCellHeightKey];
        [self setPropertiesByModel:model];
    }
    return self;
}

/// 将model的属性统一包装为当前类的属性
- (void)setPropertiesByModel:(id)model {
    if ([model isKindOfClass:[Moment class]]) {
        Moment *m = (Moment *)model;
        self.nickName = m.nickName;
        self.address = m.address;
        self.city = m.city;
        self.country = m.country;
        self.posX = m.posX;
        self.posY = m.posY;
        self.content = m.content;
        self.attachments = m.attachments;
        self.viewNum = m.viewNum;
        self.likeNum = m.likeNum;
        self.commentNum = m.commentNum;
        self.rank = m.rank;
        self.createTime = m.createTime;
        self.updateTime = m.updateTime;
        self.headIcon = m.imageUrl;
        self.userId = m.userId;
        self.isMeDetailPage = m.isMeDetailPage;
    }
    
    if ([model isKindOfClass:[Boobuz class]]) {
        Boobuz *m = (Boobuz *)model;
        self.userId = m.userId;
        self.nickName = m.nickName;
        self.poiId = m.poiId;
        self.city = m.city;
        self.country = m.country;
        self.posX = m.x;
        self.posY = m.y;
        self.profile = m.profile == nil? @3 : m.profile;
        self.headIcon = m.imageUrl;
        self.mile = m.mile;
        self.gender = m.gender;
    }
}

////////////////////////////////////////// 处理属性
#pragma mark - 处理属性
- (NSString *)dateText {
    
    NSInteger time = 0;
    if ([self.model isKindOfClass:[Moment class]]) {
        time = self.createTime;
    } else if ([self.model isKindOfClass:[Boobuz class]]) {
        time = self.updateTime;
    }
//    return [AppUtil getDateStringFromTimeInterval:time/1000];
    return [NSString stringWithFormat:@"%ld", time];
}


- (NSInteger)rankNum {
    return self.rank == 0 ? 5 : self.rank;
}

- (NSString *)viewNumText {
    return _viewNumText ?: [NSString stringWithFormat:@"%@", self.viewNum];
}

- (NSString *)commentNumText {
    return _commentNumText ?: [NSString stringWithFormat:@"%ld",self.commentNum];
}

- (NSString *)likeNumText {
    return _likeNumText ?: [NSString stringWithFormat:@"%@", self.likeNum];
}

- (NSString *)categoryText {
    return _categoryText ?: [NSString stringWithFormat:@"sBoobuzProfile%d",[self.profile intValue]];
}

- (NSString *)nickNameText {
    return self.isMeDetailPage ? self.dateText : self.nickName;
}

- (NSString *)headIconText {
    return self.headIcon;
}

- (NSArray<AttachmentPhoto *> *)attachmentList {
    return [self.attachments mutableCopy];
}
- (NSString *)contentText {
    
    if ([self.model isKindOfClass:[Moment class]]) {
        if ((!self.content || [self.content isEqualToString:@""]) && self.attachments.count == 0) {
            self.viewNumText = @"";
            self.likeNumText = @"";
        }else{
            self.viewNumText = [NSString stringWithFormat:@"%@",self.viewNum];
            self.likeNumText = [NSString stringWithFormat:@"%ld",[self.likeNum integerValue]];
        }
        _contentText = self.content;
    } else if ([self.model isKindOfClass:[Boobuz class]]) {
        if ((self.content || [self.content isEqualToString:@""]) && self.attachments.count == 0) {
            self.viewNumText = @"";
            self.likeNumText = @"";
        }else{
            self.viewNumText = [NSString stringWithFormat:@"%@",self.viewNum];
            self.likeNumText = [NSString stringWithFormat:@"%@",self.likeNum];
        }
        if (self.content == nil) {
            _contentText = @"资料不齐全";
        }else if([self.content isEqualToString:@""]){
            _contentText = @"资料不齐全";
        } else {
            _contentText = self.content;
        }

    }
    
    
 
    return _contentText;
}



- (NSString *)maleText {

    return self.gender == 1 ? @"man" : @"woman";

}

- (NSString *)userTypeImageText {
   return [self.model isKindOfClass:[Boobuz class]] ? [NSString stringWithFormat:@"boobuz_%@_hat_%ld", self.maleText,(long)[self hatNumerWithMiles:self.mile]] : @"";
}

- (NSString *)userTypeText {
    return [self.model isKindOfClass:[Boobuz class]] ? self.categoryText : @"";
}


// 判断积分等级
-(NSInteger)hatNumerWithMiles:(NSInteger)miles
{
    if (miles>10000) {
        return 1;
    }
    else if (miles>5000){
        return 2;
    }
    else if (miles>1000){
        return 3;
    }
    else if (miles>200){
        return 4;
    }
    else {
        return 5;
    }
}

////////////////////////////////////////// CELL FRAME 相关
#pragma mark - CELL FRAME 相关
- (NSString *)getCellHeightKey {
    static NSInteger i = 0;
    return [NSString stringWithFormat:@"moment_cellHeight_cache_id_%@",@(i++)];
}


- (CGFloat)cellHeight {
    
    CGFloat conW = self.isHiddenHeadIcon ? SIZE_SCREEN_W - SIZE_MARGIN_MOMENTVIEW * 2 : SIZE_SCREEN_W - SIZE_MARGIN_MOMENTVIEW*3 - SIZE_HEADICON_WH_MOMENTVIEW;
    
    self.topLineFrame = CGRectMake(0, 0, SIZE_SCREEN_W, SIZE_LINE_H_MOMENTVIEW);
    
    CGFloat cellH = 0;
    cellH += self.nickNameY;
    
    self.headIconFrame = CGRectMake(SIZE_MARGIN_MOMENTVIEW, SIZE_HEADICON_TOPMARGIN_MOMENTVIEW, SIZE_HEADICON_WH_MOMENTVIEW, SIZE_HEADICON_WH_MOMENTVIEW);
    
    CGFloat nickNameX = self.isHiddenHeadIcon ? SIZE_MARGIN_MOMENTVIEW : SIZE_MARGIN_MOMENTVIEW*2 + SIZE_HEADICON_WH_MOMENTVIEW;
    
    if (self.nickNameText && self.nickNameText.length) {
        CGSize maxSize = CGSizeMake(conW, CGFLOAT_MAX);
       CGSize nickNameSize = [self.nickNameText sizeWithMaxSize:maxSize font:kFontWithSize(kSIZE_FONT_NICKNAME)];
        
        self.nickNameFrame = CGRectMake(nickNameX, self.nickNameY, nickNameSize.width, nickNameSize.height);
        cellH += nickNameSize.height + SIZE_MARGIN_SMALL_MOMENTVIEW;
    } else {
        self.nickNameFrame = CGRectZero;
        cellH += SIZE_MARGIN_SMALL_MOMENTVIEW;
    }
    
    if (self.userTypeText && self.userTypeText.length) {
        CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CGSize userTypeLabelSize = [self.userTypeText sizeWithMaxSize:maxSize font:kFontWithSize(kSIZE_FONT_USERTYPE)];
        self.userTypeLabelFrame = CGRectMake(CGRectGetMaxX(self.nickNameFrame)+SIZE_MARGIN_SMALL_MOMENTVIEW, self.nickNameY, userTypeLabelSize.width, userTypeLabelSize.height);
        self.userTypeViewFrame = CGRectMake(CGRectGetMaxX(self.userTypeLabelFrame)+SIZE_MARGIN_SMALL_MOMENTVIEW, self.nickNameY, SIZE_USERTYPEVIEW_WH_MOMENT, SIZE_USERTYPEVIEW_WH_MOMENT);
    }
    
    self.rankFrame = CGRectMake(nickNameX, cellH, SIZE_RANK_W_MOMENTVIEW, SIZE_RANK_H_MOMENTVIEW);
    if (self.dateText && self.dateText.length) {
        CGSize dateSize = [self.dateText sizeWithMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:kFontWithSize(kSIZE_FONT_DEFAULT)];
        self.dateFrame = CGRectMake(SIZE_SCREEN_W-SIZE_MARGIN_MOMENTVIEW-dateSize.width, cellH, dateSize.width, dateSize.height);
    } else {
        self.dateFrame = CGRectZero;
    }
    
    if (self.commentNumText && self.commentNumText.length) {
        CGSize commentSize = [self.commentNumText sizeWithMaxSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) font:kFontWithSize(kSIZE_FONT_DEFAULT)];
        self.commentFrame = CGRectMake(CGRectGetMaxX(self.rankFrame)+SIZE_MARGIN_SMALL_MOMENTVIEW, cellH, commentSize.width, commentSize.height);
    } else {
        self.commentFrame = CGRectZero;
    }
    
    cellH += SIZE_RANK_H_MOMENTVIEW + SIZE_MARGIN_SMALL_MOMENTVIEW;
    
    if (self.contentText && self.contentText.length) {
        
        NSString *contentText = self.contentText;
        
        // 最多显示两行文本
        // 防止文本中出现\r \n 换行符 时 计算高度 错误问题
        if ([contentText isContainsLineBreak]) {
            contentText = [[contentText componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]] componentsJoinedByString:@""];
            contentText = [[contentText componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r"]] componentsJoinedByString:@""];
        }
        CGSize maxSize = CGSizeMake(conW, [NSString getOneLineTextHeightWithFont:kFontWithSize(kSIZE_FONT_CONTENT)]*2);
        CGSize contentSize = [contentText sizeWithMaxSize:maxSize font:kFontWithSize(kSIZE_FONT_CONTENT)];
        // 这一步是为了防止文本中有换行符出现高度不正确的问题
        CGFloat h = [NSString getOneLineTextHeightWithFont:kFontWithSize(kSIZE_FONT_CONTENT)];
        if ([self.contentText isContainsLineBreak]) {
            if ([self.contentText isEndWith:@"\n"] || [self.contentText isEndWith:@"\r"]) {
                h = contentSize.height;
            } else {
                h = h * 2;
            }
        } else {
            h = contentSize.height;
        }
        
        self.contentFrame = CGRectMake(nickNameX, cellH, contentSize.width+2, h);
        
        cellH += h + SIZE_MARGIN_SMALL_MOMENTVIEW;
        
    } else {
        self.contentFrame = CGRectZero;
    }
    
    if (self.attachments.count) {
        
        self.picContentViewFrame = CGRectMake(nickNameX, cellH+SIZE_MARGIN_SMALL_MOMENTVIEW, [self picContentViewSize].width, [self picContentViewSize].height);
        cellH += [self picContentViewSize].height + SIZE_MARGIN_SMALL_MOMENTVIEW;
        
    } else {
        self.picContentViewFrame = CGRectZero;
    }
    
    if (self.posX && self.posY && !self.isHiddenlocationLabel) {
        cellH += SIZE_MARGIN_SMALL_MOMENTVIEW;
        self.locationFrame = CGRectMake(nickNameX, cellH, conW, [NSString getOneLineTextHeightWithFont:kFontWithSize(kSIZE_FONT_DEFAULT)]);
        cellH += [NSString getOneLineTextHeightWithFont:kFontWithSize(kSIZE_FONT_DEFAULT)];
    } else {
        self.locationFrame = CGRectZero;
    }
    
    if (!self.isHiddenBootomToolView) {
        self.toolViewFrame = CGRectMake(nickNameX, cellH-SIZE_LINE_H_MOMENTVIEW, conW-SIZE_MARGIN_MOMENTVIEW, SIZE_TOOLVIEW_H_MOMENTVIEW);
        cellH += SIZE_TOOLVIEW_H_MOMENTVIEW;
    } else {
        self.toolViewFrame = CGRectZero;
    }
    
    self.bottomLineFrame = CGRectMake(0, cellH-SIZE_LINE_H_MOMENTVIEW, SIZE_SCREEN_W, SIZE_LINE_H_MOMENTVIEW);
    
    if (self.isHiddenBootomToolView && self.isHiddenlocationLabel && !self.attachmentList.count) {
        cellH = self.nickNameY*2 + SIZE_HEADICON_WH_MOMENTVIEW;
        self.bottomLineFrame = CGRectMake(0, cellH-SIZE_LINE_H_MOMENTVIEW, SIZE_SCREEN_W, SIZE_LINE_H_MOMENTVIEW);
        return cellH;
    }
    
    return cellH;
}



- (CGSize)picContentViewSize {
    if (self.attachments.count > 0) {
        NSInteger count = 0;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationPortrait) {
            count = 5;
        } else {
            count = 10;
        }
        CGFloat picH = (SIZE_SCREEN_W - SIZE_HEADICON_TOPMARGIN_MOMENTVIEW - SIZE_MARGIN_SMALL_MOMENTVIEW - SIZE_HEADICON_WH_MOMENTVIEW - SIZE_IMAGEVIEW_MARGIN_MOMENTVIEW * (count+1)) / count;
        NSInteger tCount = self.attachments.count > count ? count : self.attachments.count;
        CGFloat picW = tCount * picH + (tCount-1) * SIZE_MARGIN_SMALL_MOMENTVIEW;
        return CGSizeMake(picW, picH);
        
    } else {
        return CGSizeZero;
    }
}



- (CGFloat)nickNameY {
    return self.isHiddenBootomToolView ? SIZE_HEADICON_TOPMARGIN_MOMENTVIEW : SIZE_MARGIN_SMALL_MOMENTVIEW;
}



- (NSString *)locationtext {
    if (self.posX == 0 || self.posY == 0) {
        return @"";
    }else{
        return @"北京市朝阳区国贸三期大厦12层Apple";
        
    }
}

- (NSString *)dictanceText {
    if (self.posX == 0 || self.posY == 0 || [self.model isKindOfClass:[Boobuz class]]) {
        return @"";
    }else{
        return @"10km";
    }
}

#pragma mark - 颜色
- (UIColor *)cellBackgroundImageColor {
    return [UIColor whiteColor];
}

- (UIColor *)nickNameTextColor {
    return IOSRGB(0.0, 105.0, 210.0);
}

- (UIColor *)labelTextColor {
    return IOSRGB(120.0, 120.0, 120.0);
}

- (UIColor *)cellSelectBackgroundColor {
    return UIColorFromRGB(0xc8ebff);
}

#pragma mark - 隐藏控件的属性

- (BOOL)isHiddenBootomToolView {
    if ([self.contentText isEqualToString: @"资料不齐全"]  && [self.model isKindOfClass:[Boobuz class]] && !self.attachmentList.count) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isHiddenlocationLabel {
    return [self.model isKindOfClass:[Boobuz class]] ? YES : NO;
}

- (BOOL)isHiddenUserType {
    if ([self.model isKindOfClass:[Boobuz class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isHiddenHeadIcon {
    return self.isMeDetailPage;
}

@end

//
//  BeanViewFrame.h
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+CellHeightCache.h"
#import "Moment.h"

extern const CGFloat SIZE_MARGIN_MOMENTVIEW;
extern const CGFloat SIZE_MARGIN_SMALL_MOMENTVIEW;
extern const CGFloat SIZE_HEADICON_WH_MOMENTVIEW;
extern const CGFloat SIZE_RANK_H_MOMENTVIEW;
extern const CGFloat SIZE_TOOLVIEW_H_MOMENTVIEW;
extern const CGFloat SIZE_LINE_H_MOMENTVIEW;
extern const CGFloat SIZE_IMAGEVIEW_MARGIN_MOMENTVIEW;
extern const CGFloat SIZE_RANK_W_MOMENTVIEW;
extern const CGFloat SIZE_HEADICON_TOPMARGIN_MOMENTVIEW;
extern const CGFloat SIZE_USERTYPEVIEW_WH_MOMENT;

#define SIZE_SCREEN_H CGRectGetHeight([UIScreen mainScreen].bounds)
#define SIZE_SCREEN_W CGRectGetWidth([UIScreen mainScreen].bounds)
#define kSIZE_FONT_NICKNAME kSIZE_FONT_DEFAULT
#define kSIZE_FONT_CONTENT kSIZE_FONT_DEFAULT
#define kSIZE_FONT_TOOLVIEW 14
#define kSIZE_FONT_USERTYPE 10
#define kSIZE_FONT_DEFAULT 12
#define kFontWithSize(s) [UIFont systemFontOfSize:s]
#define IOSRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface BeanViewFrame : NSObject

@property (nonatomic, strong) id model;

////////////////// 处理后的属性
/// 创建日期 格式: 2017.02.21 12:58
@property (nonatomic, copy) NSString *dateText;
/// 是否已点赞
@property (nonatomic, assign) BOOL alreadyLiked;
@property (nonatomic, assign) NSInteger rankNum;
@property (nonatomic, strong) NSArray<AttachmentPhoto *> *attachmentList;
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, copy) NSString *viewNumText;
@property (nonatomic, copy) NSString *commentNumText;
@property (nonatomic, copy) NSString *likeNumText;
@property (nonatomic, copy) NSString *categoryText;
@property (nonatomic, copy) NSString *maleText;
@property (nonatomic, copy) NSString *userTypeImageText;
@property (nonatomic, copy) NSString *userTypeText;
@property (nonatomic, copy) NSString *nickNameText;
@property (nonatomic, copy) NSString *headIconText;
@property (nonatomic, copy) NSString *locationtext;
@property (nonatomic, copy) NSString *dictanceText;

///////////////// 隐藏某些控件的属性
@property (nonatomic, assign) BOOL isHiddenBootomToolView;
@property (nonatomic, assign) BOOL isHiddenlocationLabel;
@property (nonatomic, assign) BOOL isHiddenUserType;
@property (nonatomic, assign) BOOL isHiddenHeadIcon;
@property (nonatomic, assign) BOOL isHiddenDateLabel;

///////////////// 获取cell frame的属性
@property (nonatomic, assign) CGFloat nickNameY;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, copy) NSString *cellHeightKey;
@property (nonatomic, assign) CGSize picContentViewSize;

////////////////// 已计算好控件的frame
@property (nonatomic, assign) CGRect commentFrame;
@property (nonatomic, assign) CGRect dateFrame;
@property (nonatomic, assign) CGRect contentFrame;
@property (nonatomic, assign) CGRect locationFrame;
@property (nonatomic, assign) CGRect toolViewFrame;
@property (nonatomic, assign) CGRect headIconFrame;
@property (nonatomic, assign) CGRect rankFrame;
@property (nonatomic, assign) CGRect picContentViewFrame;
@property (nonatomic, assign) CGRect userTypeLabelFrame;
@property (nonatomic, assign) CGRect userTypeViewFrame;
@property (nonatomic, assign) CGRect nickNameFrame;
@property (nonatomic, assign) CGRect topLineFrame;
@property (nonatomic, assign) CGRect bottomLineFrame;

////////////////// 白天夜晚颜色
@property (nonatomic, strong) UIColor *labelTextColor;
@property (nonatomic, strong) UIColor *nickNameTextColor;
@property (nonatomic, strong) UIColor *cellBackgroundImageColor;
@property (nonatomic, strong) UIColor *cellSelectBackgroundColor;

+ (instancetype)viewFrameWithModel:(id)model;

@end

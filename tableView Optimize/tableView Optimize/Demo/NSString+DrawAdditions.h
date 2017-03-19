//
//  NSString+DrawAdditions.h
//  MomentViewCellDemo
//
//  Created by mofeini on 17/3/9.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface UIImage (Color)

/// 更改图片的颜色
- (UIImage *)changeImageColorWithColor:(UIColor *)color;
/// 根据颜色创建一个图片
+ (UIImage *)imageWithColor:(UIColor *)color;

@end


@interface NSString (DrawAdditions)

/// 是否包含换行符
- (BOOL)isContainsLineBreak;

/// 获取子串的位置
- (NSUInteger)indexOf:(NSString*)substring;

/// 是否以某个子串结尾
- (BOOL)isEndWith:(NSString*)substring;

/// 是否以某个子串开头
- (BOOL)isStartWith:(NSString*)substring;

/// 以子串分离字符串，返回结果在数组中
- (NSArray *)split:(NSString *)subString;

/// 获取一行文本的高度
+ (CGFloat)getOneLineTextHeightWithFont:(UIFont *)font;

/// 计算文本的size
+ (CGSize)sizeWithText:(NSString*)text maxSize:(CGSize)maxSize font:(UIFont*)font;

/// 计算通过CoreText绘制的文本的尺寸
- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)font1
                           lineSpace:(float)lineSpace;
/// 计算通过CoreText绘制的文本的尺寸
- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)font1
                          lineSpace:(float)lineSpace;
/// 将文本渲染到图形上下文中
- (void)drawInContext:(CGContextRef)context
         withPosition:(CGPoint)p andFont:(UIFont *)font
         andTextColor:(UIColor *)color
            andHeight:(float)height
             andWidth:(float)width;
/// 将文本渲染到图形上下文中
- (void)drawInContext:(CGContextRef)context
         withPosition:(CGPoint)p andFont:(UIFont *)font
         andTextColor:(UIColor *)color
            andHeight:(float)height;

@end

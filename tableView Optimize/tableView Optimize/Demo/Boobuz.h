//
//  Boobuz.h
//  tableView Optimize
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Moment.h"

@interface Boobuz : NSObject <BeanViewFrameAdaptiveModelProtocol>
//Boobuz模型
@property(nonatomic, assign)    NSInteger userId;
@property(nonatomic, assign)    NSInteger poiId;
@property(nonatomic, strong)    NSString *city;
@property(nonatomic, strong)    NSString *country;          //countryId()
@property(nonatomic, strong)    NSString *language;         //语言
@property(nonatomic, strong)    NSNumber *avatar;
@property(nonatomic, strong)    NSNumber *profile;
@property(nonatomic, assign)    double x;
@property(nonatomic, assign)    double y;
@property(nonatomic, assign)    NSInteger mile;             //积分
@property(nonatomic, strong)    NSNumber *visible;          //头像是否在地图上显示－对公共设置
@property(nonatomic, strong)    NSNumber *visibleToFriends; //头像是否在地图上显示－对好友设置
@property(nonatomic, strong)    NSString *imageUrl;         //头像url
@property(nonatomic, assign)    NSInteger gender;
@property(nonatomic, strong)    NSString *nickName;
@property(nonatomic, strong)    NSString *name;             //名字拼音
@property(nonatomic, assign)    BOOL isMyFollower;          //好友
@property(nonatomic, assign)    CGFloat   distance;
@property(nonatomic, assign)    BOOL    isOwner;            //boobuz是否为自己
@property(nonatomic, strong)    NSNumber *updateTime;

@property(nonatomic, strong) NSArray<AttachmentPhoto *> *attachmentPhotos;


+ (instancetype)boobuzWithDic:(NSDictionary *)info;

//获取用户帽子编号
- (NSString *)getHatName;


@end

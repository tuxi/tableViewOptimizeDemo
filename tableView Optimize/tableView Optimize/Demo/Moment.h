//
//  Moment.h
//  tableView Optimize
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MomentType) {
    MomentTypePublic = 2,   // 公开,所有人可见
    MomentTypePrivate = 8,  // 私密
};

typedef NS_ENUM(NSInteger, MomentSendStatus) {
    MomentSendStatusNormal,
    MomentSendStatusSending,
    MomentSendStatusFailed,
    MomentSendStatusDeleted,
    MomentSendStatusWaiting,
    MomentSendStatusFinshed,
    MomentFromPublicList,
    MomentFromFriendList
};


@interface Moment : NSObject

@property (nonatomic, strong) NSNumber  * momentId;
@property (nonatomic, assign) MomentType momentType;
@property (nonatomic, assign) CGFloat   posX;
@property (nonatomic, assign) CGFloat   posY;
@property (nonatomic, copy) NSString    * content;
@property (nonatomic, strong) NSArray* attachments;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSNumber  * viewNum;
@property (nonatomic, strong) NSNumber  *likeNum;
@property (nonatomic, assign) NSInteger commentNum;
@property (nonatomic, assign) CGFloat   rank;
@property (nonatomic, copy) NSString    * address;
@property (nonatomic, copy) NSString    * city;
@property (nonatomic, copy) NSString    * country;
@property (nonatomic, assign) NSInteger createTime;
@property (nonatomic, assign) NSInteger updateTime;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *imageUrl;

// send Moment 添加字段
@property (nonatomic, copy) NSString *friendsList;
@property (nonatomic, copy) NSString *onMap;
@property (nonatomic, assign) NSInteger primaryId;
@property (nonatomic, copy) NSString *attaches;
@property (nonatomic, assign) MomentSendStatus sendState;
@property (nonatomic, assign) NSInteger loginId;
@property (nonatomic, assign) BOOL isMeDetailPage;


+ (instancetype)momentWithDic:(NSDictionary *)info;

/**
 返回如下字典，用于获取 moment detail info 的参数：
 @{
 @"momentId": xx,
 @"momentType":yy
 }
 */
- (NSDictionary *)requestMomentDetailDic;

@end

@interface AttachmentPhoto : NSObject
@property(nonatomic, strong)NSNumber        *photoId;
@property(nonatomic, copy)NSString          *url;
@property(nonatomic, copy)NSString          *thumUrl;
@property(nonatomic, copy)NSString          *videoUrl;
@property(nonatomic, copy)NSString          *localUrl;
@property(nonatomic, copy)NSString          *localIdentifier; // 相片在本地相册的资源符, 发送moment时获取相册资源使用


@end

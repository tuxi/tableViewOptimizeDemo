//
//  Moment.m
//  tableView Optimize
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "Moment.h"

@implementation Moment
- (instancetype)init{
    if (self = [super init]) {
        _momentId = @0;
        _momentType = 0;
        _posX = 0.f;
        _posY = 0.f;
        _content = @"";
        _attachments = @[];
        _userId = 0;
        _viewNum = @0;
        _likeNum = @0;
        _commentNum = 0;
        _rank = 5.f;
        _address = @"";
        _city = @"";
        _country = @"";
        _createTime = 0.f;
        _updateTime = 0.f;
        _friendsList = @"";
        _onMap = @"";
        _primaryId = 0;
        _sendState = MomentSendStatusNormal;
        _attaches = @"";
        _loginId = 0;
        _isMeDetailPage = NO;
    }
    return self;
}

+ (instancetype)momentWithDic:(NSDictionary *)info{
    Moment  * moment = [Moment new];
    [moment setValuesForKeysWithDictionary:info];
    return moment;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"attachments"]) {
        NSMutableArray* mArr = @[].mutableCopy;
        NSArray *arr = value;
        if ([arr isKindOfClass:[NSArray class]]) {
            [arr enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AttachmentPhoto  *model = [[AttachmentPhoto alloc] init];
                model.photoId = obj[@"photoId"];
                model.thumUrl = obj[@"thumUrl"];
                model.url = obj[@"url"];
                model.videoUrl = obj[@"videoUrl"];
                [mArr addObject:model];
            }];
        }
        [super setValue:mArr forKey:@"attachments"];
    }else{
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    NSLog(@" -- key : %@ -- value : %@ -- ",key,value);
}

- (NSDictionary *)requestMomentDetailDic{
    if (_momentId) {
        return  @{
                  @"momentId": _momentId,
                  @"momentType":@(_momentType)
                  };
    }
    return nil;
}



- (NSString *)nickName
{
    if (!_nickName || _nickName.length == 0 || self.userId == -1) {
        return @"sAnonymity";
    }
    return _nickName;
}


- (NSString *)adaptiveKey {
    return [NSString stringWithFormat:@"%p", self];
}
@end

@implementation AttachmentPhoto
- (instancetype)init{
    self = [super init];
    if (self) {
        _photoId = @0;
        _url = @"";
        _thumUrl = @"";
        _videoUrl = @"";
        _localUrl = @"";
    }
    return self;
}

@end


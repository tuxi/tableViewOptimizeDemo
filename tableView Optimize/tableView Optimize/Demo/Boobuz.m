//
//  Boobuz.m
//  tableView Optimize
//
//  Created by mofeini on 17/3/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "Boobuz.h"

@implementation Boobuz

- (instancetype)init{
    self = [super init];
    if (self) {
        _city = @"";
        _country = @"";
        _language = @"";
        _imageUrl = @"";
        _nickName = @"";
        _distance = -1;
        _isOwner = NO;
        _isMyFollower = NO;
        _profile = @3;
        _avatar = @1;
        }
    return self;
}

- (CGFloat)distance{
//    _distance = [Bridge getDistanceFromX:self.x andY:self.y];
    return _distance;
}

//获取用户帽子编号
- (NSString *)getHatName{
    NSInteger   num = _profile.integerValue;
    NSInteger   hatIndex = 5;
    if (num > 10000) {
        hatIndex = 1;
    } else if (num > 5000) {
        hatIndex = 2;
    } else if (num > 1000) {
        hatIndex = 3;
    } else if (num > 200) {
        hatIndex = 4;
    }
    return [NSString stringWithFormat:@"boobuz_%@_hat_%ld.png", _gender == 1?@"man":@"woman",hatIndex];
}



+ (instancetype)boobuzWithDic:(NSDictionary *)info {
    Boobuz *b = [Boobuz new];
    [b setValuesForKeysWithDictionary:info];
    return b;
}



@end

//
//  UASharedApp.m
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import "UASharedApp.h"

@implementation UASharedApp
static id _share;
+ (instancetype)share
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[self alloc] init];
    });
    return _share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _engine = [TTTRtcEngineKit sharedEngineWithAppId:@"test900572e02867fab8131651339518" delegate:nil];
    }
    return self;
}

@end

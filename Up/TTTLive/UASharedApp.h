//
//  UASharedApp.h
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineKit/TTTRtcEngineKit.h>


#define UAShare UASharedApp.share

@interface UASharedApp : NSObject
@property (nonatomic, strong) TTTRtcEngineKit *engine;
@property (nonatomic, assign) int64_t uid;
@property (nonatomic, assign) BOOL mutedSelf;
@property (nonatomic, assign) int64_t roomID;

+ (instancetype)share;
@end


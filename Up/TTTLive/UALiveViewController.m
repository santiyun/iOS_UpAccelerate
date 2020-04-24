//
//  UALiveViewController.m
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import "UALiveViewController.h"

@interface UALiveViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *anchorVideoView;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *anchorIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *audioStatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoStatsLabel;
@end

@implementation UALiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _roomIDLabel.text = [NSString stringWithFormat:@"房号: %lld", UAShare.roomID];
    _anchorIdLabel.text = [NSString stringWithFormat:@"房主ID: %lld", UAShare.uid];
    UAShare.engine.delegate = self;
    TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
    videoCanvas.renderMode = TTTRtc_Render_Adaptive;
    videoCanvas.uid = UAShare.uid;
    videoCanvas.view = _anchorVideoView;
    //设置预览窗口
    [UAShare.engine setupLocalVideo:videoCanvas];
}

- (IBAction)leftBtnsAction:(UIButton *)sender {
    if (sender.tag == 1001) {
        sender.selected = !sender.isSelected;
        UAShare.mutedSelf = sender.isSelected;
        //静音状态不会因退出房间而改变
        [UAShare.engine muteLocalAudioStream:sender.isSelected];
    } else if (sender.tag == 1002) {
        [UAShare.engine switchCamera];
    }
}

- (IBAction)exitChannel:(id)sender {
    __weak UALiveViewController *weakSelf = self;
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出房间吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UAShare.engine leaveChannel:nil];//结束直播
        [UAShare.engine stopPreview];//停止预览
        [weakSelf dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TTTRtcEngineDelegate
//推流状态回调
- (void)rtcEngine:(TTTRtcEngineKit *)engine reportRtmpStatus:(BOOL)status rtmpUrl:(NSString *)rtmpUrl {
    if (!status) {//根据业务需求更新新的推流地址
//        [engine updateRtmpUrl:[@"rtmp://push.3ttest.cn/sdk2/" stringByAppendingFormat:@"%lld", TTManager.roomID]];
    }
}
//网络连接丢失
- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [self.view.window showMessage:@"网络连接丢失，正在重连..."];
}
//重连失败
- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [self.view.window showMessage:@"重连失败!!!"];
    [engine leaveChannel:nil];
    [engine stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}
//重连服务器成功
- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [self showMessage:@"重连服务器成功"];
}
//异常---被踢出房间
- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NewChairEnter:
            errorInfo = @"其他人以主播身份进入";
            break;
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self.view.window showMessage:errorInfo];
}
//其它处理
- (void)rtcEngine:(TTTRtcEngineKit *)engine localAudioStats:(TTTRtcLocalAudioStats *)stats {
    _audioStatsLabel.text = [NSString stringWithFormat:@"A-↑%ldkbps", stats.sentBitrate];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine localVideoStats:(TTTRtcLocalVideoStats *)stats {
    _videoStatsLabel.text = [NSString stringWithFormat:@"V-↑%ldkbps_%ldfps", stats.sentBitrate, stats.sentFrameRate];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    [_voiceBtn setImage:[self getAudioImage:audioLevel] forState:UIControlStateNormal];
}
#pragma mark - helper mehtod
- (UIImage *)getAudioImage:(NSUInteger)level {
    if (UAShare.mutedSelf) {
        return [UIImage imageNamed:@"voice_close"];
    }
    UIImage *image = nil;
    if (level < 4) {
        image = [UIImage imageNamed:@"voice_small"];
    } else if (level < 7) {
        image = [UIImage imageNamed:@"voice_middle"];
    } else {
        image = [UIImage imageNamed:@"voice_big"];
    }
    return image;
}


@end

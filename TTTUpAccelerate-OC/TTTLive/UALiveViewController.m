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
    UAShare.rtcEngine.delegate = self;
    _anchorIdLabel.text = [NSString stringWithFormat:@"房主ID: %lld", UAShare.uid];
    
    //开启预览...注意退出房间必须对应关闭预览
    [UAShare.rtcEngine startPreview];
    TTTRtcVideoCanvas *videoCanvas = [[TTTRtcVideoCanvas alloc] init];
    videoCanvas.renderMode = TTTRtc_Render_Adaptive;
    videoCanvas.uid = UAShare.uid;
    videoCanvas.view = _anchorVideoView;
    [UAShare.rtcEngine setupLocalVideo:videoCanvas];
}

- (IBAction)leftBtnsAction:(UIButton *)sender {
    if (sender.tag == 1001) {
        sender.selected = !sender.isSelected;
        UAShare.mutedSelf = sender.isSelected;
        //启用/关闭静音
        [UAShare.rtcEngine muteLocalAudioStream:sender.isSelected];
    } else {
        //切换摄像头
        [UAShare.rtcEngine switchCamera];
    }
}

- (IBAction)exitChannel:(id)sender {
    __weak UALiveViewController *weakSelf = self;
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出房间吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UAShare.rtcEngine leaveChannel:nil];
        [UAShare.rtcEngine stopPreview];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TTTRtcEngineDelegate
//上报音量
- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    [_voiceBtn setImage:[self getAudioImage:audioLevel] forState:UIControlStateNormal];
}

//上报本地音频码率
- (void)rtcEngine:(TTTRtcEngineKit *)engine localAudioStats:(TTTRtcLocalAudioStats *)stats {
    _audioStatsLabel.text = [NSString stringWithFormat:@"A-↑%ldkbps", stats.sentBitrate];
}

//上报本地视频码率
- (void)rtcEngine:(TTTRtcEngineKit *)engine localVideoStats:(TTTRtcLocalVideoStats *)stats {
    _videoStatsLabel.text = [NSString stringWithFormat:@"V-↑%ldkbps", stats.sentBitrate];
}

//网络连接丢失...会发起自动重连
- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [self.view.window showMessage:@"ConnectionDidLost"];
}

//网络重连失败
- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [self.view.window showMessage:@"网络丢失, 连接服务器失败"];
    [engine leaveChannel:nil];
    [engine stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//网络重连成功
- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [self showMessage:@"重连服务器成功"];
}

//被踢出房间
- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_PushRtmpFailed:
            errorInfo = @"rtmp推流失败";
            break;
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NewChairEnter:
            errorInfo = @"其他人以主播身份进入";
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self.view.window showMessage:errorInfo];
    [engine stopPreview];
    [self dismissViewControllerAnimated:true completion:nil];
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

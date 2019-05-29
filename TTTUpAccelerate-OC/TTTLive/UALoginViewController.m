//
//  UALoginViewController.m
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import "UALoginViewController.h"

@interface UALoginViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UITextField *roomIDTF;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (nonatomic, assign) int64_t uid;
@end

@implementation UALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _websiteLabel.text = TTTRtcEngineKit.getSdkVersion;
    _uid = arc4random() % 100000 + 1;
    int64_t roomID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ENTERROOMID"].integerValue;
    if (roomID == 0) {
        roomID = arc4random() % 1000000 + 1;
    }
    _roomIDTF.text = [NSString stringWithFormat:@"%lld", roomID];
}

- (IBAction)enterChannel:(id)sender {
    if (_roomIDTF.text.integerValue == 0 || _roomIDTF.text.length >= 19) {
        [self showMessage:@"请输入19位以内的房间ID"];
        return;
    }
    int64_t rid = _roomIDTF.text.longLongValue;
    [NSUserDefaults.standardUserDefaults setValue:_roomIDTF.text forKey:@"ENTERROOMID"];
    [NSUserDefaults.standardUserDefaults synchronize];
    [UAHud hudShow:self.view];
    UAShare.uid = _uid;
    UAShare.roomID = rid;
    UAShare.mutedSelf = false;
    
    
    TTTRtcEngineKit *rtcEngine = UAShare.rtcEngine;
    //设置 TTTRtcEngineDelegate 代理
    rtcEngine.delegate = self;
    //设置为直播模式
    [rtcEngine setChannelProfile:TTTRtc_ChannelProfile_LiveBroadcasting];
    //设置用户角色为主播...上行加速不允许连麦
    [rtcEngine setClientRole:TTTRtc_ClientRole_Anchor];
    //启用说话者音量提示...监控自己音量（可选）
    [rtcEngine enableAudioVolumeIndication:1000 smooth:3];
    //启用说话...该方法视全局的，SDK不会重新设置这个状态，退出房间也不改变状态
    [rtcEngine muteLocalAudioStream:NO];
    
    //推流地址设置
    TTTPublisherConfigurationBuilder *builder = [[TTTPublisherConfigurationBuilder alloc] init];
    NSString *pushURL = [@"rtmp://push.3ttech.cn/sdk/" stringByAppendingFormat:@"%@", _roomIDTF.text];
    [builder setPublisherUrl:pushURL];
    [rtcEngine configPublisher:builder.build];
    
    //设置编码尺寸
    [rtcEngine setVideoProfile:TTTRtc_VideoProfile_360P swapWidthAndHeight:YES];
    
    //上行加速必须在加入房间前调用该接口
    [rtcEngine enableUplinkAccelerate:YES];
    [rtcEngine setPreferAudioCodec:TTTRtc_AudioCodec_AAC bitrate:64 channels:1];
    
    //加入房间
    [rtcEngine joinChannelByKey:nil channelName:_roomIDTF.text uid:_uid joinSuccess:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark - TTTRtcEngineDelegate
//加入房间成功...
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [UAHud hudHide:self.view];
    [self performSegueWithIdentifier:@"Live" sender:nil];
}

//加入房间失败
-(void)rtcEngine:(TTTRtcEngineKit *)engine didOccurError:(TTTRtcErrorCode)errorCode {
    NSString *errorInfo = @"";
    switch (errorCode) {
        case TTTRtc_Error_Enter_TimeOut:
            errorInfo = @"超时,10秒未收到服务器返回结果";
            break;
        case TTTRtc_Error_Enter_BadVersion:
            errorInfo = @"版本错误";
            break;
        case TTTRtc_Error_InvalidChannelName:
            errorInfo = @"Invalid channel name";
            break;
        default:
            errorInfo = [NSString stringWithFormat:@"未知错误：%zd",errorCode];
            break;
    }
    [UAHud hudHide:self.view];
    [self showMessage:errorInfo];
}

@end

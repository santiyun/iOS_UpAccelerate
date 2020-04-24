//
//  UALoginViewController.m
//  TTTUpAccelerate
//
//  Created by yanzhen on 2018/11/19.
//  Copyright © 2018 yanzhen. All rights reserved.
//

#import "UALoginViewController.h"

static NSString *const TTTH265 = @"?trans=1";

@interface UALoginViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cdnBtn;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTF;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (nonatomic, assign) int64_t uid;
@end

@implementation UALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *dateStr = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    _websiteLabel.text = [TTTRtcEngineKit.getSdkVersion stringByAppendingFormat:@"__%@", dateStr];
    _uid = arc4random() % 100000 + 1;
    int64_t roomID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ENTERROOMID"].integerValue;
    if (roomID == 0) {
        roomID = arc4random() % 1000000 + 1;
    }
    _roomIDTF.text = [NSString stringWithFormat:@"%lld", roomID];
}

- (IBAction)enterChannel:(id)sender {
    if (_roomIDTF.text.integerValue == 0 || _roomIDTF.text.length >= 19) {
        [self showMessage:@"请输入正确的房间id"];
        return;
    }
    int64_t rid = _roomIDTF.text.longLongValue;
    [NSUserDefaults.standardUserDefaults setValue:_roomIDTF.text forKey:@"ENTERROOMID"];
    [NSUserDefaults.standardUserDefaults synchronize];
    [UAHud hudShow:self.view];
    UAShare.uid = _uid;
    UAShare.roomID = rid;
    TTTRtcEngineKit *engine = UAShare.engine;
    
    engine.delegate = self;
    //设置模式直播
    [engine setChannelProfile:TTTRtc_ChannelProfile_LiveBroadcasting];
    //设置用户角色为主播
    [engine setClientRole:TTTRtc_ClientRole_Anchor];
    //需要音量提示开启---可选接口
    [engine enableAudioVolumeIndication:500 smooth:3];
    
    TTTPublisherConfiguration *config = [[TTTPublisherConfiguration alloc] init];
    NSString *pushURL = [@"rtmp://push.3ttest.cn/sdk2/" stringByAppendingFormat:@"%@", _roomIDTF.text];
    config.publishUrl = pushURL;
    //设置推流参数
    [engine configPublisher:config];
    //设置编码参数--竖屏模式需要交换宽高
    [engine setVideoProfile:CGSizeMake(528, 960) frameRate:15 bitRate:1600];
    //打开房间预览--离开房间需要对应停止预览stopPreview
    [engine startPreview];
    //加入频道
    [engine joinChannelByKey:nil channelName:_roomIDTF.text uid:_uid joinSuccess:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
#pragma mark - TTTRtcEngineDelegate
//加入房间成功
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [UAHud hudHide:self.view];
    [self performSegueWithIdentifier:@"Live" sender:nil];
}
//加入房间失败
-(void)rtcEngine:(TTTRtcEngineKit *)engine didOccurError:(TTTRtcErrorCode)errorCode {
    NSString *errorInfo = @"";
    switch (errorCode) {
        case TTTRtc_Error_Enter_TimeOut:
            errorInfo = @"超时,10秒未收到服务器返回结果";//如果不调用leaveChannel,会继续尝试登录
            break;
        case TTTRtc_Error_Enter_Failed:
            errorInfo = @"该直播间不存在";
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

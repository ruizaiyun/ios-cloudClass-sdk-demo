//
//  PLVNormalLiveMediaViewController.m
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/8/30.
//

#import "PLVNormalLiveMediaViewController.h"
#import "PLVBaseMediaViewController+Live.h"

@interface PLVNormalLiveMediaViewController () <PLVLivePlayerControllerDelegate, PLVPlayerControllerDelegate>

@property (nonatomic, strong) PLVPlayerController<PLVPlayerControllerProtocol> *player;//视频播放器

@end

@implementation PLVNormalLiveMediaViewController

@synthesize playAD;
@synthesize channelId;
@synthesize userId;
@synthesize linkMicVC;
@synthesize danmuLayer;
@synthesize danmuInputView;
@synthesize reOpening;
@synthesize player;

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSkinView:PLVPlayerSkinViewTypeNormalLive];
    
    self.player = [[PLVLivePlayerController alloc] initWithChannelId:self.channelId userId:self.userId playAD:self.playAD displayView:self.mainView delegate:self];
    ((PLVLivePlayerController *)self.player).cameraClosed = NO;
}

#pragma mark - PLVBaseMediaViewController
- (void)deviceOrientationDidChangeSubAnimation {
    UIView *displayView = self.mainView;
    [self.player setFrame:displayView.bounds];
    
    if (self.skinView.fullscreen) {
        self.danmuInputView.frame = self.view.bounds;
        self.linkMicVC.view.alpha = 0;
    }else{
        self.linkMicVC.view.alpha = 1;
    }
}

#pragma mark - PLVLiveMediaProtocol
- (void)linkMicSuccess {
    [((PLVLivePlayerController*)self.player) mute];
    
    [self.moreView showAudioModeBtn:NO];
    [self.skinView linkMicStart:YES];
}

- (void)cancelLinkMic {
    self.skinView.switchCameraBtn.hidden = YES;
    [((PLVLivePlayerController*)self.player) cancelMute];
    [self reOpenPlayer:nil showHud:NO];
    
    BOOL showAudioModeSwitch = ((PLVLivePlayerController*)self.player).supportAudioMode && self.player.playable;
    [self.moreView showAudioModeBtn:showAudioModeSwitch];
    [self.skinView linkMicStart:NO];
}

#pragma mark - PLVPlayerControllerDelegate
- (void)adPreparedToPlay:(PLVPlayerController *)playerController {
    self.skinView.controllView.hidden = YES;
}

- (void)mainPreparedToPlay:(PLVPlayerController *)playerController {
    self.skinView.controllView.hidden = NO;
    [self skinShowAnimaion];
    [self.moreView modifyModeBtnSelected:((PLVLivePlayerController*)self.player).audioMode];
}

- (void)changePlayerScreenBackgroundColor:(PLVPlayerController *)playerController {
    self.mainView.backgroundColor = playerController.backgroundImgView.hidden ? [UIColor blackColor] : GrayBackgroundColor;
    
    BOOL showAudioModeSwitch = ((PLVLivePlayerController*)self.player).supportAudioMode && self.player.playable;
    [self.moreView showAudioModeBtn:showAudioModeSwitch];
    [self.moreView modifyModeBtnSelected:((PLVLivePlayerController*)self.player).audioMode];
}

#pragma mark - PLVLivePlayerControllerDelegate
- (void)livePlayerController:(PLVLivePlayerController *)livePlayer streamState:(PLVLiveStreamState)streamState {
    if (streamState == PLVLiveStreamStateNoStream) {//没直播流
        self.skinView.controllView.hidden = YES;
    }
}

- (void)reconnectPlayer:(PLVLivePlayerController *)livePlayer {
    [self reOpenPlayer:nil showHud:NO];
}

- (void)liveVideoChannelDidUpdate:(PLVLiveVideoChannel *)channel {
    self.enableDanmuModule = !channel.closeDanmuEnable;
    [self setupMarquee:channel customNick:self.nickName];
}

@end

//
//  PLVPlayerSkinView.m
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/8/8.
//

#import "PLVPlayerSkinView.h"
#import <MediaPlayer/MPVolumeView.h>
#import <Masonry/Masonry.h>
#import <PolyvFoundationSDK/PLVDateUtil.h>
#import "PLVBrightnessView.h"
#import "PCCUtils.h"

#define BlueColor [UIColor colorWithRed:33.0 / 255.0 green:150.0 / 255.0 blue:243.0 / 255.0 alpha:1.0]

typedef NS_ENUM(NSInteger, PLVPlayerSkinViewPanType) {
    PLVPlayerSkinViewPanTypeSeekPlay        = 1,//左右滑动，seek调整播放进度
    PLVPlayerSkinViewTypeAdjusVolume        = 2,//在屏幕左边，上下滑动调节声音
    PLVPlayerSkinViewTypeAdjusBrightness    = 3 //在屏幕右边，上下滑动调节亮度
};

@interface PLVPlayerSkinView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *controllView;
@property (nonatomic, strong) UIImageView *topBgImgV;
@property (nonatomic, strong) UIImageView *bottomBgImgV;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *mainBtn;
@property (nonatomic, strong) UIButton *refreshBtn;
@property (nonatomic, strong) UIButton *linkMicBtn;
@property (nonatomic, strong) UIButton *switchScreenBtn;
@property (nonatomic, strong) UIButton *zoomScreenBtn;
@property (nonatomic, strong) UIButton *danmuBtn;
@property (nonatomic, assign) NSInteger openDanmuByUser;
@property (nonatomic, strong) UIButton * showInputBtn;

@property (nonatomic, strong) UILabel *currentPlayTimeLabel;
@property (nonatomic, strong) UILabel *blankLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIView *sliderBackgroundView;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) BOOL sliderDragging;

@property (nonatomic, strong) UIView *popView;
@property (nonatomic, strong) UILabel *seekTimeLable;
@property (nonatomic, strong) UISlider *seekSlider;
@property (nonatomic, assign) BOOL popWithSeeked;

@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) PLVPlayerSkinViewPanType panType;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, assign) BOOL timelabelSizeToFited;

@end

@implementation PLVPlayerSkinView


#pragma mark - IBAction

- (IBAction)danmuBtnAction:(id)sender {
    self.danmuBtn.selected = !self.danmuBtn.selected;
    [self showDanmuInputBtn:(self.danmuBtn.selected && ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight))]; // 竖屏时无弹幕输入框
    self.openDanmuByUser = self.danmuBtn.selected ? 1 : -1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerSkinView:switchDanmu:)]) {
        [self.delegate playerSkinView:self switchDanmu:self.danmuBtn.selected];
    }
}

- (IBAction)sliderTouchDownAction:(UISlider *)sender {
    self.sliderDragging = YES;
}

- (IBAction)sliderTouchEndAction:(UISlider *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(seek:)]) {
        [self.delegate seek:self];
    }
    self.sliderDragging = NO;
}

- (IBAction)sliderValueChangedAction:(UISlider *)sender {
    if (self.duration == 0.0) {
        self.slider.value = 0.0;
    }
}

- (IBAction)backBtnAction:(id)sender {
    if (self.fullscreen) {
        [PCCUtils changeDeviceOrientation:UIDeviceOrientationPortrait];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(quit:)]) {
            [self.delegate quit:self];
        }
    }
}

- (IBAction)moreBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(more:)]) {
        [self.delegate more:self];
    }
}

- (IBAction)mainBtnAction:(id)sender {
    self.mainBtn.selected = !self.mainBtn.selected;
    if (self.mainBtn.selected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(play:)]) {
            [self.delegate play:self];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pause:)]) {
            [self.delegate pause:self];
        }
    }
}

- (IBAction)refreshBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refresh:)]) {
        [self.delegate refresh:self];
    }
}

- (IBAction)linkMicBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(linkMic:)]) {
        [self.delegate linkMic:self];
    }
}

- (IBAction)switchScreenBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchScreenOnManualControl:)]) {
        [self.delegate switchScreenOnManualControl:self];
    }
}

- (IBAction)zoomScreenBtnAction:(id)sender {
    [PCCUtils changeDeviceOrientation:UIDeviceOrientationLandscapeLeft];
}

- (IBAction)switchCameraBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchCamera:)]) {
        [self.delegate switchCamera:self];
    }
}

- (IBAction)showInputBtnAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(showInput:)]) {
        [self.delegate showInput:self];
    }
}

#pragma mark - 共有方法
- (void)loadSubviews {
    self.fullscreen = NO;
    self.duration = 0.0;
    
    //手指移动调节声音，亮度，播放seek
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.superview addGestureRecognizer:pan];
    
    //顶部底部背景
    self.topBgImgV = [[UIImageView alloc]init];
    self.topBgImgV.image = [self playerSkinImage:@"plv_skin_topbg"];
    self.topBgImgV.userInteractionEnabled = NO;
    [self addSubview:self.topBgImgV];
    
    self.controllView = [[UIView alloc] initWithFrame:self.bounds];
    self.controllView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.controllView];
    
    self.bottomBgImgV = [[UIImageView alloc]init];
    self.bottomBgImgV.image = [self playerSkinImage:@"plv_skin_bottombg"];
    self.bottomBgImgV.userInteractionEnabled = NO;
    [self.controllView addSubview:self.bottomBgImgV];
    
    //直播，点播都共有的按钮
    self.mainBtn = [self addButton:@"plv_skin_play" selectedImgName:@"plv_skin_pause" title:nil fontSize:17.0 action:@selector(mainBtnAction:) inView:self.controllView];
    self.backBtn = [self addButton:@"plv_skin_back" selectedImgName:nil title:nil fontSize:17.0 action:@selector(backBtnAction:) inView:self];
    self.moreBtn = [self addButton:@"plv_skin_more" selectedImgName:nil title:nil fontSize:17.0 action:@selector(moreBtnAction:) inView:self.controllView];
    self.switchScreenBtn = [self addButton:@"plv_skin_switchscreen" title:nil action:@selector(switchScreenBtnAction:)];
    if (self.type == PLVPlayerSkinViewTypeNormalLive || self.type == PLVPlayerSkinViewTypeNormalVod) {
        self.switchScreenBtn.hidden = YES;
    }
    self.zoomScreenBtn = [self addButton:@"plv_skin_fullscreen" title:nil action:@selector(zoomScreenBtnAction:)];
    
    if (self.type == PLVPlayerSkinViewTypeNormalLive || self.type == PLVPlayerSkinViewTypeCloudClassLive) {
        self.refreshBtn = [self addButton:@"plv_skin_refresh" title:nil action:@selector(refreshBtnAction:)];
        self.switchCameraBtn = [self addButton:nil title:nil action:@selector(switchCameraBtnAction:)];
        [self.switchCameraBtn setImage:[UIImage imageNamed:@"plv_skin_switchCamera"] forState:UIControlStateNormal];
        self.switchCameraBtn.hidden = YES;
        self.linkMicBtn = [self addButton:@"plv_skin_hangup" selectedImgName:nil title:nil fontSize:17.0 action:@selector(linkMicBtnAction:) inView:self.controllView];
        self.linkMicBtn.hidden = YES;
        
        self.danmuBtn = [self addButton:@"plv_skin_danmu_close" selectedImgName:@"plv_skin_danmu_open" title:nil fontSize:17.0 action:@selector(danmuBtnAction:) inView:self.controllView];
        self.danmuBtn.hidden = YES;
        
        self.showInputBtn = [self addShowInputBtnTitle:@"发个弹幕呗~" fontSize:12 action:@selector(showInputBtnAction:) inView:self.controllView];
        self.showInputBtn.hidden = YES;
        self.showInputBtn.userInteractionEnabled = NO;
    } else {
        self.currentPlayTimeLabel = [self addLabel:@"00:00" textAlignment:NSTextAlignmentRight];
        self.blankLabel = [self addLabel:@"/" textAlignment:NSTextAlignmentCenter];
        self.durationLabel = [self addLabel:@"00:00" textAlignment:NSTextAlignmentLeft];
        
        self.sliderBackgroundView = [[UIView alloc] init];
        self.sliderBackgroundView.backgroundColor = [UIColor blackColor];
        [self.controllView addSubview:self.sliderBackgroundView];
        
        self.progressBar = [[UIView alloc] init];
        self.progressBar.backgroundColor = [UIColor colorWithRed:163.0 / 255.0 green:220.0 / 255.0 blue:1.0 alpha:1.0];
        [self.controllView addSubview:self.progressBar];
        
        self.slider = [[UISlider alloc] init];
        self.slider.minimumTrackTintColor = [UIColor colorWithRed:43.0 / 255.0 green:159.0 / 255.0 blue:252.0 / 255.0 alpha:1.0];
        self.slider.maximumTrackTintColor = [UIColor clearColor];
        [self.slider setThumbImage:[self playerSkinImage:@"plv_skin_playSlider"] forState:UIControlStateNormal];
        [self.slider addTarget:self action:@selector(sliderTouchDownAction:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDownRepeat | UIControlEventTouchDragInside | UIControlEventTouchDragOutside | UIControlEventTouchDragEnter | UIControlEventTouchDragExit];
        [self.slider addTarget:self action:@selector(sliderTouchEndAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [self.slider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
        [self.controllView addSubview:self.slider];
    }
    
    [self layout];
}

- (void)layout {
    float lrPadding = 8.0; // 左右间距
    float btnPadding = 44.0 + lrPadding;

    UIEdgeInsets topBgImgVMargin = UIEdgeInsetsMake(self.fullscreen ? 0.0 : -44.0, 0.0, -1.0, 0.0);
    UIEdgeInsets bottomBgImgVMargin = UIEdgeInsetsMake(-1.0, 0.0, self.fullscreen ? -20.0 : 0.0, 0.0);

    UIEdgeInsets backMargin = UIEdgeInsetsMake(0.0, lrPadding, -1.0, -1.0);
    UIEdgeInsets moreMargin = UIEdgeInsetsMake(0.0, -1.0, -1.0, lrPadding);
    UIEdgeInsets mainMargin = UIEdgeInsetsMake(-1.0, lrPadding, 0.0, -1.0);
    UIEdgeInsets refreshMargin = UIEdgeInsetsMake(-1.0, lrPadding + btnPadding * 1, 0.0, -1.0); // 从左开始数第二

    UIEdgeInsets danmuMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 2); // 从右开始倒数第三
    UIEdgeInsets switchScreenMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 1); // 从右开始倒数第二
    UIEdgeInsets zoomScreenMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding);
    self.zoomScreenBtn.hidden = NO;
    
    UIEdgeInsets showDanmuMargin = UIEdgeInsetsMake(-1.0, lrPadding + btnPadding * 2 + 35.0, 6.0, lrPadding + btnPadding * 2 + 35.0);
    
    if (self.type == PLVPlayerSkinViewTypeNormalLive || self.type == PLVPlayerSkinViewTypeCloudClassLive) {
        UIEdgeInsets switchCameraMargin = UIEdgeInsetsMake(-1.0, -1.0, 128.0, 10.0);
        UIEdgeInsets linkMicMargin = UIEdgeInsetsMake(-1.0, -1.0, 64.0, 10.0);
        if (self.type == PLVPlayerSkinViewTypeCloudClassLive) {
            switchCameraMargin = UIEdgeInsetsMake(-1.0, -1.0, 192.0, 10.0);
            linkMicMargin = UIEdgeInsetsMake(-1.0, -1.0, 128.0, 10.0);
        }
        
        if (self.fullscreen) {
            backMargin = UIEdgeInsetsMake(10.0, 10.0, -1.0, -1.0);
            moreMargin = UIEdgeInsetsMake(10.0, -1.0, -1.0, lrPadding);
            self.zoomScreenBtn.hidden = YES;
            switchScreenMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 0);
            danmuMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 1);
        } else {
            switchScreenMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 1);
            danmuMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 2);
        }
        
        [self remakeConstraints:self.switchCameraBtn margin:switchCameraMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
        [self remakeConstraints:self.linkMicBtn margin:linkMicMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    } else {
        UIEdgeInsets sliderBackgroundMargin = UIEdgeInsetsMake(-1.0, 0.0, 44.0, 0.0);
        UIEdgeInsets progressMargin = UIEdgeInsetsMake(-1.0, 0.0, 44.0, -1.0);
        UIEdgeInsets sliderMargin = UIEdgeInsetsMake(-1.0, 0.0, 31.0, 0.0);
        
        if (self.fullscreen) {
            backMargin = UIEdgeInsetsMake(10.0, 10.0, -1.0, -1.0);
            moreMargin = UIEdgeInsetsMake(10.0, -1.0, -1.0, lrPadding);
            self.zoomScreenBtn.hidden = YES;
            switchScreenMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 0);
        } else {
            switchScreenMargin = UIEdgeInsetsMake(-1.0, -1.0, 0.0, lrPadding + btnPadding * 1);
        }
        
        [self remakeConstraints:self.sliderBackgroundView margin:sliderBackgroundMargin size:CGSizeMake(-1.0, 2.0) baseView:self.controllView];
        [self remakeConstraints:self.progressBar margin:progressMargin size:CGSizeMake(0.0, 2.0) baseView:self.controllView];
        [self remakeConstraints:self.slider margin:sliderMargin size:CGSizeMake(-1.0, 30.0) baseView:self.controllView];
        [self timelabelSizeToFit];
    }
    
    [self remakeConstraints:self.topBgImgV margin:topBgImgVMargin size:CGSizeMake(-1.0, self.fullscreen ? 84.0 : 128.0) baseView:self];
    [self remakeConstraints:self.bottomBgImgV margin:bottomBgImgVMargin size:CGSizeMake(-1.0, self.fullscreen ? 84.0 : 64.0) baseView:self.controllView];
    [self remakeConstraints:self.backBtn margin:backMargin size:CGSizeMake(44.0, 44.0) baseView:self];
    [self remakeConstraints:self.moreBtn margin:moreMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    [self remakeConstraints:self.mainBtn margin:mainMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    [self remakeConstraints:self.refreshBtn margin:refreshMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    [self remakeConstraints:self.danmuBtn margin:danmuMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    [self remakeConstraints:self.switchScreenBtn margin:switchScreenMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    [self remakeConstraints:self.zoomScreenBtn margin:zoomScreenMargin size:CGSizeMake(44.0, 44.0) baseView:self.controllView];
    [self remakeConstraints:self.showInputBtn margin:showDanmuMargin size:CGSizeMake(-1.0, 32.0) baseView:self.controllView];
    
    if (self.popView != nil && !self.popView.hidden) {
        [self remakePopViewConstraints];
    }
}

- (void)modifySwitchScreenBtnState:(BOOL)secondaryViewClosed pptOnSecondaryView:(BOOL)pptOnSecondaryView {
    if (secondaryViewClosed) {
        if (pptOnSecondaryView) {
            [self.switchScreenBtn setImage:[self playerSkinImage:@"plv_skin_ppt"] forState:UIControlStateNormal];
            [self.switchScreenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.switchScreenBtn setTitle:nil forState:UIControlStateNormal];
        } else {
            [self.switchScreenBtn setImage:[self playerSkinImage:@"plv_skin_camera"] forState:UIControlStateNormal];
            [self.switchScreenBtn setTitle:nil forState:UIControlStateNormal];
        }
    } else {
        [self.switchScreenBtn setImage:[self playerSkinImage:@"plv_skin_switchscreen"] forState:UIControlStateNormal];
        [self.switchScreenBtn setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)linkMicStatus:(BOOL)select {
    if (select) {
        [self.linkMicBtn setImage:[self playerSkinImage:@"plv_skin_linkmic"] forState:UIControlStateNormal];
    } else {
        [self.linkMicBtn setImage:[self playerSkinImage:@"plv_skin_hangup"] forState:UIControlStateNormal];
    }
}

- (void)showMessage:(NSString *)message {
    UILabel *messageLabel = [self addLabel:message fontSize:17.0 textAlignment:NSTextAlignmentCenter inView:self.superview];
    messageLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65];
    messageLabel.clipsToBounds = YES;
    messageLabel.layer.cornerRadius = 16.0;
    UIEdgeInsets messageMargin = UIEdgeInsetsMake(-1.0, 10.0, 44.0, -1.0);
    CGSize size = [messageLabel sizeThatFits:CGSizeMake(1000.0, 32.0)];
    [self remakeConstraints:messageLabel margin:messageMargin size:CGSizeMake(size.width + 32.0, 32.0) baseView:self.superview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [messageLabel removeFromSuperview];
    });
}

- (void)showDanmuBtn:(BOOL)show{
    self.danmuBtn.hidden = !show;
    self.danmuBtn.userInteractionEnabled = !self.danmuBtn.hidden;
}

- (void)showDanmuInputBtn:(BOOL)show{
    self.showInputBtn.hidden = !show;
    self.showInputBtn.userInteractionEnabled = !self.showInputBtn.hidden;
}

- (void)linkMicStart:(BOOL)start{
    self.mainBtn.hidden = start;
    self.refreshBtn.hidden = start;
    self.moreBtn.hidden = start;
}

#pragma mark - 点播独有方法
- (void)updateDowloadProgress:(CGFloat)dowloadProgress playedProgress:(CGFloat)playedProgress currentPlaybackTime:(NSString *)currentPlaybackTime duration:(NSString *)duration {
    UIEdgeInsets progressMargin = UIEdgeInsetsMake(-1.0, 0.0, 44.0, -1.0);
    CGFloat w = self.bounds.size.width * dowloadProgress;
    if (@available(iOS 11.0, *)) {
        w = self.safeAreaLayoutGuide.layoutFrame.size.width * dowloadProgress;
    }
    [self remakeConstraints:self.progressBar margin:progressMargin size:CGSizeMake(w, 2.0) baseView:self];
    if (!self.sliderDragging) {
        self.slider.value = playedProgress;
        self.currentPlayTimeLabel.text = currentPlaybackTime;
        self.durationLabel.text = duration;
        if (!self.timelabelSizeToFited) {
            self.timelabelSizeToFited = YES;
            [self timelabelSizeToFit];
        }
    }
}

- (void)modifyMainBtnState:(BOOL)playing {
    self.mainBtn.selected = playing;
}

- (NSTimeInterval)getCurrentTime {
    return self.duration * self.slider.value;
}

#pragma mark - guesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !self.sliderDragging;
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = p;
        CGPoint velocty = [gestureRecognizer velocityInView:self];
        if (fabs(velocty.x) > fabs(velocty.y)) {//左右滑动seek播放
            if ((self.type == PLVPlayerSkinViewTypeNormalVod || self.type == PLVPlayerSkinViewTypeCloudClassVod) && self.duration > 0.0 && !self.sliderDragging) {
                self.panType = PLVPlayerSkinViewPanTypeSeekPlay;
                [self addSeekPopView];
                [self sliderTouchDownAction:self.slider];
            }
        } else {
            if (self.lastPoint.x > self.bounds.size.width * 0.5) {//在屏幕右边，上下滑动调整声音
                self.panType = PLVPlayerSkinViewTypeAdjusVolume;
            } else {//在屏幕左边，上下滑动调整亮度
                self.panType = PLVPlayerSkinViewTypeAdjusBrightness;
                [PLVBrightnessView sharedBrightnessView];
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        switch (self.panType) {
            case PLVPlayerSkinViewPanTypeSeekPlay: {
                CGFloat dx = p.x - self.lastPoint.x;
                self.slider.value = [self valueOfDistance:dx baseValue:self.slider.value];
                self.seekSlider.value = self.slider.value;
                NSString *text = [PLVDateUtil secondsToString:self.slider.value * self.duration];
                self.currentPlayTimeLabel.text = text;
                self.seekTimeLable.text = text;
                if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                    [self sliderTouchEndAction:self.slider];
                    [self hiddenPopView];
                }
                break;
            }
            case PLVPlayerSkinViewTypeAdjusVolume: {
                CGFloat dy = self.lastPoint.y - p.y;
                [self changeVolume:dy];
                break;
            }
            case PLVPlayerSkinViewTypeAdjusBrightness: {
                CGFloat dy = self.lastPoint.y - p.y;
                [UIScreen mainScreen].brightness = [self valueOfDistance:dy baseValue:[UIScreen mainScreen].brightness];
                break;
            }
            default:
                break;
        }
        self.lastPoint = p;
    }
}

#pragma mark - pop view
- (void)addSeekPopView {
    [self addPopView:YES];
    [self remakePopViewConstraints];
    if (self.seekTimeLable == nil) {
        self.seekTimeLable = [self addLabel:@"00:00" fontSize:20.0 textAlignment:NSTextAlignmentCenter inView:self.popView];
        
        self.seekSlider = [[UISlider alloc] init];
        self.seekSlider.minimumTrackTintColor = BlueColor;
        self.seekSlider.maximumTrackTintColor = [UIColor lightGrayColor];
        [self.seekSlider setThumbImage:[self sliderThumbImage:CGSizeMake(0.1, 0.1)] forState:UIControlStateNormal];
        [self.popView addSubview:self.seekSlider];
    }
    [self.popView addSubview:self.seekTimeLable];
    [self.popView addSubview:self.seekSlider];
    
    [self.seekTimeLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.popView.mas_centerX);
        make.centerY.mas_equalTo(self.popView.mas_centerY).offset(-15.0);
        make.width.mas_equalTo(150.0);
        make.height.mas_equalTo(30.0);
    }];
    
    [self.seekSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.popView.mas_centerX);
        make.centerY.mas_equalTo(self.popView.mas_centerY).offset(15.0);
        make.width.mas_equalTo(150.0);
        make.height.mas_equalTo(30.0);
    }];
}

- (void)addPopView:(BOOL)popWithSeeked {
    if (self.popView == nil) {
        self.popView = [[UIView alloc] init];
        self.popView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenPopView)];
        [self.popView addGestureRecognizer:tap];
    }
    [self.superview.superview addSubview:self.popView];
    self.popView.hidden = NO;
    self.popWithSeeked = popWithSeeked;
    [self performSelector:@selector(hiddenPopView) withObject:nil afterDelay:3.0];
}

- (void)hiddenPopView {
    self.popView.hidden = YES;
    for (UIView *view in self.popView.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark - util
- (void)changeVolume:(CGFloat)distance {
    if (self.volumeView == nil) {
        self.volumeView = [[MPVolumeView alloc] init];
        self.volumeView.showsVolumeSlider = YES;
        [self addSubview:self.volumeView];
        [self.volumeView sizeToFit];
        self.volumeView.hidden = YES;
    }
    for (UIView *v in self.volumeView.subviews) {
        if ([v.class.description isEqualToString:@"MPVolumeSlider"]) {
            UISlider *volumeSlider = (UISlider *)v;
            [volumeSlider setValue:[self valueOfDistance:distance baseValue:volumeSlider.value] animated:NO];
            [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (UIImage *)sliderThumbImage:(CGSize)size {
    CGRect bounds = CGRectMake(2.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContext(CGSizeMake(size.width + 4.0, size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, bounds);
    CGContextSetFillColor(context, CGColorGetComponents([UIColor whiteColor].CGColor));
    CGContextFillPath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

- (void)selectItem:(UIButton *)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenPopView) object:nil];
    sender.selected = YES;
    for (UIButton *btn in self.popView.subviews) {
        if (btn != sender) {
            btn.selected = NO;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf hiddenPopView];
    });
}

- (CGFloat)valueOfDistance:(CGFloat)distance baseValue:(CGFloat)baseValue {
    CGFloat value = baseValue + distance / 300.0f;
    if (value < 0.0) {
        value = 0.0;
    } else if (value > 1.0) {
        value = 1.0;
    }
    return value;
}

#pragma mark - UI util - add view / constraint
- (UIImage *)playerSkinImage:(NSString *)name {
    NSString *imageName = [@"PLVPlayerSkin.bundle" stringByAppendingPathComponent:name];
    return [UIImage imageNamed:imageName];
}

- (void)labelShadow:(UILabel *)label {
    label.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
    label.layer.shadowOffset = CGSizeMake(-0.2, -0.2);
    label.layer.shadowRadius = 0.2;
    label.layer.shadowOpacity = 1.0;
}

- (UIButton *)addButton:(NSString *)normalImgName selectedImgName:(NSString *)selectedImgName title:(NSString *)title fontSize:(CGFloat)fontSize action:(SEL)action inView:(UIView *)view {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (normalImgName) {
        [btn setImage:[self playerSkinImage:normalImgName] forState:UIControlStateNormal];
    }
    if (selectedImgName) {
        [btn setImage:[self playerSkinImage:selectedImgName] forState:UIControlStateSelected];
    }
    if (title) {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self labelShadow:btn.titleLabel];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        [btn setTitle:title forState:UIControlStateNormal];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    return btn;
}

- (UIButton *)addButton:(NSString *)normalImgName title:(NSString *)title action:(SEL)action {
    return [self addButton:normalImgName selectedImgName:nil title:title fontSize:17.0 action:action inView:self.controllView];
}

- (UIButton *)addShowInputBtnTitle:(NSString *)title fontSize:(CGFloat)fontSize action:(SEL)action inView:(UIView *)view {
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
    [btn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.3]];

    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 17.0f;
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    return btn;
}

- (UILabel *)addLabel:(NSString *)text fontSize:(CGFloat)fontSize textAlignment:(NSTextAlignment)textAlignment inView:(UIView *)view {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:fontSize];
    label.textColor = [UIColor whiteColor];
    [self labelShadow:label];
    label.textAlignment = textAlignment;
    label.text = text;
    [view addSubview:label];
    return label;
}

- (UILabel *)addLabel:(NSString *)text textAlignment:(NSTextAlignment)textAlignment {
    return [self addLabel:text fontSize:17.0 textAlignment:textAlignment inView:self.controllView];
}

- (void)timelabelSizeToFit {
    if (self.currentPlayTimeLabel.text.length > 0) {
        CGFloat baseWidth = [UIScreen mainScreen].bounds.size.width * 0.5;
        CGSize size = [self.currentPlayTimeLabel.text sizeWithAttributes:@{NSFontAttributeName : self.currentPlayTimeLabel.font}];
        if (54.0 + 2.0 * size.width > baseWidth) {
            UIFont *font_14 = [UIFont boldSystemFontOfSize:14.0];
            CGSize size_14 = [self.currentPlayTimeLabel.text sizeWithAttributes:@{NSFontAttributeName : font_14}];
            if (54.0 + 2.0 * size_14.width > baseWidth) {
                UIFont *font_10 = [UIFont boldSystemFontOfSize:10.0];
                self.currentPlayTimeLabel.font = font_10;
                self.blankLabel.font = font_10;
                self.durationLabel.font = font_10;
            } else {
                self.currentPlayTimeLabel.font = font_14;
                self.blankLabel.font = font_14;
                self.durationLabel.font = font_14;
            }
            size = [self.currentPlayTimeLabel.text sizeWithAttributes:@{NSFontAttributeName : self.currentPlayTimeLabel.font}];
        }
        
        CGFloat w = (int)size.width + 8.0;
        UIEdgeInsets currentPlayTimeMargin = UIEdgeInsetsMake(-1.0, 44.0, 0.0, -1.0);
        UIEdgeInsets blankMargin = UIEdgeInsetsMake(-1.0, 44.0 + w, 0.0, -1.0);
        UIEdgeInsets durationMargin = UIEdgeInsetsMake(-1.0, 54.0 + w, 0.0, -1.0);
        [self remakeConstraints:self.currentPlayTimeLabel margin:currentPlayTimeMargin size:CGSizeMake(w, 44.0) baseView:self.controllView];
        [self remakeConstraints:self.blankLabel margin:blankMargin size:CGSizeMake(10.0, 44.0) baseView:self.controllView];
        [self remakeConstraints:self.durationLabel margin:durationMargin size:CGSizeMake(w, 44.0) baseView:self.controllView];
    }
}

//UIEdgeInsets margin的top, left, bottom, right都为正值，-1.0代表不计算该边距的约束, <-10.0计算该边距的负边距约束
- (void)remakeConstraints:(UIView *)view margin:(UIEdgeInsets)margin size:(CGSize)size baseView:(UIView *)baseView {
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (margin.top >= 0.0 || margin.top < -10.0) {
            make.top.equalTo(baseView.mas_top).offset(margin.top);
        }
        if (margin.left >= 0.0) {
            make.left.equalTo(baseView.mas_left).offset(margin.left);
        }
        if (margin.bottom >= 0.0 || margin.bottom < -10.0) {
            make.bottom.equalTo(baseView.mas_bottom).offset(-margin.bottom);
        }
        if (margin.right >= 0.0) {
            make.right.equalTo(baseView.mas_right).offset(-margin.right);
        }
        if (size.width > 0.0) {
            make.width.mas_equalTo(size.width);
        }
        if (size.height > 0.0) {
            make.height.mas_equalTo(size.height);
        }
    }];
}

- (void)remakePopItemConstraints {
    NSInteger count = self.popView.subviews.count;
    __weak typeof(self) weakSelf = self;
    for (NSUInteger i = 0; i < count; i++) {
        UIButton *btn = [self.popView.subviews objectAtIndex:i];
        [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (weakSelf.fullscreen) {
                CGFloat dy = ([UIScreen mainScreen].bounds.size.height - 30.0 * count) / (count + 1);
                make.top.mas_equalTo(dy + i * (30.0 + dy));
                make.left.mas_offset(50.0);
            } else {
                CGFloat dx = ([UIScreen mainScreen].bounds.size.width - 60.0 * count) / (count + 1);
                make.left.mas_equalTo(dx + i * (60.0 + dx));
                make.centerY.mas_equalTo(weakSelf.popView.mas_centerY);
            }
            make.width.mas_equalTo(60.0);
            make.height.mas_equalTo(30.0);
        }];
    }
}

- (void)remakePopViewConstraints {
    self.popView.transform = self.superview.transform;
    CGRect popRect = self.superview.frame;
    if (!self.popWithSeeked && self.fullscreen) {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            CGFloat x = 0.0;
            if (@available(iOS 11.0, *)) {
                CGRect safeFrame = self.superview.safeAreaLayoutGuide.layoutFrame;
                x = safeFrame.origin.x;
            }
            popRect = CGRectMake(0.0, self.superview.frame.origin.x + x, [UIScreen mainScreen].bounds.size.width, 160.0);
        } else {
            CGRect rect = [UIScreen mainScreen].bounds;
            if (@available(iOS 11.0, *)) {
                CGRect safeFrame = self.superview.safeAreaLayoutGuide.layoutFrame;
                rect.origin.x = safeFrame.origin.x;
                rect.size.width = safeFrame.size.width;
            }
            popRect = CGRectMake(rect.origin.y + rect.size.height - rect.size.width, rect.origin.x + rect.size.width - 160.0, rect.size.width, 160.0);
        }
    }
    self.popView.frame = popRect;
    if (!self.popWithSeeked) {
        [self remakePopItemConstraints];
    }
}

@end

//
//  PLVChatroomCell.m
//  PolyvCloudClassDemo
//
//  Created by ftao on 24/08/2018.
//

#import "PLVChatroomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PLVEmojiManager.h"
#import "PCCUtils.h"

#define DEFAULT_CELL_HEIGHT 44.0
#define CHAT_TEXT_FONT [UIFont systemFontOfSize:14.0]

#pragma mark - Private Classes

@interface PLVCCLabel : UILabel

@property (assign, nonatomic) UIEdgeInsets edgeInsets;

@end

@implementation PLVCCLabel

// 修改绘制文字的区域，edgeInsets增加bounds
-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    // 注意传入的UIEdgeInsetsInsetRect(bounds, self.edgeInsets),bounds是真正的绘图区域
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets) limitedToNumberOfLines:numberOfLines];
    
    // 根据edgeInsets，修改绘制文字的bounds
    rect.origin.x -= self.edgeInsets.left;
    rect.origin.y -= self.edgeInsets.top;
    rect.size.width += self.edgeInsets.left + self.edgeInsets.right;
    rect.size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    // 令绘制区域为原始区域，增加的内边距区域不绘制
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end

#pragma mark - Public Classes

@interface PLVChatroomCell ()

@property (nonatomic, assign) CGFloat height;

- (CGSize)autoCalculateSize:(CGSize)size attributedContent:(NSAttributedString *)attributedContent;
- (void)drawCornerRadiusWithView:(UIView *)view size:(CGSize)size roundingCorners:(UIRectCorner)corners;

@end

@implementation PLVChatroomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (instancetype)initWithReuseIdentifier:(NSString *)indentifier {
    self.height = DEFAULT_CELL_HEIGHT;
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    return self;
}

- (CGFloat)calculateCellHeightWithContent:(NSString *)content {
    return DEFAULT_CELL_HEIGHT;
}

+ (CGFloat)calculateCellHeightWithModelDict:(NSDictionary *)modelDict mine:(BOOL)mine {
    return DEFAULT_CELL_HEIGHT;
}

- (void)drawCornerRadiusWithView:(UIView *)view size:(CGSize)size roundingCorners:(UIRectCorner)corners {
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corners cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

/// 计算属性字符串文本的宽或高
- (CGSize)autoCalculateSize:(CGSize)size attributedContent:(NSAttributedString *)attributedContent {
    CGRect rect = [attributedContent boundingRectWithSize:size
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                  context:nil];
    return rect.size;
}

+ (NSString *)cellIndetifier {
    return NSStringFromClass([self class]);
}

@end

@interface PLVChatroomSpeakOwnCell ()

@property (nonatomic, strong) PLVCCLabel *messageLB;
@end

@implementation PLVChatroomSpeakOwnCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.messageLB = [[PLVCCLabel alloc] init];
        self.messageLB.numberOfLines = 0;
        self.messageLB.textColor = [UIColor whiteColor];
        self.messageLB.font = CHAT_TEXT_FONT;
        self.messageLB.backgroundColor = UIColorFromRGB(0x8CC152);
        self.messageLB.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [self addSubview:self.messageLB];
    }
    return self;
}

- (void)setSpeakContent:(NSString *)speakContent {
    _speakContent = speakContent;
    NSMutableAttributedString *attributedStr = [[PLVEmojiManager sharedManager] convertTextEmotionToAttachment:speakContent font:CHAT_TEXT_FONT];
    self.messageLB.attributedText = attributedStr;
    CGSize newSize = [self.messageLB sizeThatFits:CGSizeMake(270, MAXFLOAT)];
    [self drawCornerRadiusWithView:self.messageLB size:newSize roundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft|UIRectCornerBottomRight];
    [self.messageLB mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(newSize);
        make.top.equalTo(self.mas_top).offset(10.0);
        make.right.equalTo(self.mas_right).offset(-10);
    }];
    
    self.height = newSize.height + 10;
}

- (CGFloat)calculateCellHeightWithContent:(NSString *)content {
    NSMutableAttributedString *attributedStr = [[PLVEmojiManager sharedManager] convertTextEmotionToAttachment:content font:CHAT_TEXT_FONT];
    // 30 = 10(顶部间隔)+10(PLVCRLabel上内边距)+10(PLVCRLabel上内边距)
    return [self autoCalculateSize:CGSizeMake(270, MAXFLOAT) attributedContent:attributedStr].height + 30.0;
}

@end

@interface PLVChatroomSpeakOtherCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *actorLB;
@property (nonatomic, strong) UILabel *nickNameLB;
@property (nonatomic, strong) PLVCCLabel *messageLB;
@end

@implementation PLVChatroomSpeakOtherCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
        self.avatarView.layer.cornerRadius = 35.0/2;
        self.avatarView.layer.masksToBounds = YES;
        [self addSubview:self.avatarView];
        
        self.actorLB = [[UILabel alloc] init];
        self.actorLB.layer.cornerRadius = 9.0;
        self.actorLB.layer.masksToBounds = YES;
        self.actorLB.textColor = [UIColor whiteColor];
        if (@available(iOS 8.2, *)) {
            self.actorLB.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightMedium];
        } else {
            self.actorLB.font = [UIFont systemFontOfSize:10.0];
        }
        self.actorLB.backgroundColor = UIColorFromRGB(0x2196F3);
        self.actorLB.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.actorLB];
        
        self.nickNameLB = [[UILabel alloc] init];
        self.nickNameLB.backgroundColor = [UIColor clearColor];
        self.nickNameLB.textColor = [UIColor colorWithWhite:135/255.0 alpha:1.0];
        self.nickNameLB.font = [UIFont systemFontOfSize:11.0];
        [self addSubview:self.nickNameLB];
        
        self.messageLB = [[PLVCCLabel alloc] init];
        self.messageLB.numberOfLines = 0;
        self.messageLB.font = CHAT_TEXT_FONT;
        self.messageLB.textColor = UIColorFromRGB(0x546E7A);
        self.messageLB.backgroundColor = [UIColor whiteColor];
        self.messageLB.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [self addSubview:self.messageLB];
        
        [self.actorLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_top);
            make.height.mas_equalTo(@(18));
            make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        }];
        [self.nickNameLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_top);
            make.height.mas_equalTo(@(18));
            make.leading.equalTo(self.actorLB.mas_trailing).offset(5);
        }];
    }
    return self;
}

- (void)setAvatar:(NSString *)avatar {
    _avatar = avatar;
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"plv_img_default_avatar"]];
}

- (void)setActor:(NSString *)actor {
    _actor = actor;
    if (actor) {
        _actorLB.text = actor;
        CGSize size = [_actorLB sizeThatFits:CGSizeMake(MAXFLOAT, 18)];
        [_actorLB mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(size.width+20, 18));
            make.top.equalTo(self.avatarView.mas_top);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        }];
    }else {
        [_actorLB mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
            make.top.equalTo(self.avatarView.mas_top);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(5);
        }];
    }
}

- (void)setNickName:(NSString *)nickName {
    _nickName = nickName;
    _nickNameLB.text = nickName;
}

/*! 聊天室内容转义问题（测试）
 NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
 [attributedStr addAttribute:NSFontAttributeName value:contentLB.font range:NSMakeRange(0, attributedStr.length)];
 */
- (void)setSpeakContent:(NSString *)speakContent {
    _speakContent = speakContent;
    NSMutableAttributedString *attributedStr = [[PLVEmojiManager sharedManager] convertTextEmotionToAttachment:speakContent font:CHAT_TEXT_FONT];
    self.messageLB.attributedText = attributedStr;
    CGSize newSize = [self.messageLB sizeThatFits:CGSizeMake(260, MAXFLOAT)];
    [self drawCornerRadiusWithView:self.messageLB size:newSize roundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopRight];
    [self.messageLB mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(newSize);
        make.top.equalTo(self.nickNameLB.mas_bottom).offset(5);
        make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
    }];
    
    self.height = newSize.height + 33; //10+18+5
}

- (void)setSpeakContentColor:(UIColor *)speakContentColor{
    _speakContentColor = speakContentColor;
    if (speakContentColor) {
        _messageLB.textColor = speakContentColor;
    }
}

- (void)setActorTextColor:(UIColor *)actorTextColor {
    _actorTextColor = actorTextColor;
    if (actorTextColor) {
        _actorLB.textColor = actorTextColor;
    }
}

- (void)setActorBackgroundColor:(UIColor *)actorBackgroundColor {
    _actorBackgroundColor = actorBackgroundColor;
    if (actorBackgroundColor) {
        _actorLB.backgroundColor = actorBackgroundColor;
    }
}

- (CGFloat)calculateCellHeightWithContent:(NSString *)content {
    NSMutableAttributedString *attributedStr = [[PLVEmojiManager sharedManager] convertTextEmotionToAttachment:content font:CHAT_TEXT_FONT];
    // +53 = 10+18+5(顶部间隔)+10(PLVCRLabel上内边距)+10(PLVCRLabel上内边距)
    return [self autoCalculateSize:CGSizeMake(260, MAXFLOAT) attributedContent:attributedStr].height + 53.0;
}

@end

@interface PLVChatroomImageSendCell ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *loadingBgView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) PLVPhotoBrowser *phototBrowser;
@end

@implementation PLVChatroomImageSendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc] init];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.layer.cornerRadius = 5.0;
        self.imgView.layer.masksToBounds = YES;
        self.imgView.userInteractionEnabled = YES;
        [self addSubview:self.imgView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(132.0, 132.0));
            make.top.equalTo(self.mas_top).offset(10.0);
            make.trailing.equalTo(self.mas_trailing).offset(-10.0);
        }];
        
        self.loadingBgView = [[UIView alloc] initWithFrame:self.imgView.bounds];
        self.loadingBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.loadingBgView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
        [self.imgView addSubview:self.loadingBgView];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityView.color = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        [self addSubview:self.activityView];
        [self.activityView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.imgView.mas_centerX);
            make.centerY.equalTo(self.imgView.mas_centerY).offset(-12.0);
        }];
        
        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.font = [UIFont systemFontOfSize:12.0];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.progressLabel];
        [self.progressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(self.imgView.frame.size.width, 24.0));
            make.centerX.equalTo(self.imgView.mas_centerX);
            make.centerY.equalTo(self.imgView.mas_centerY).offset(12.0);
        }];
        
        self.refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.refreshBtn.backgroundColor = [UIColor colorWithRed:252.0 / 255.0  green:92.0 / 255.0 blue:95.0 / 255.0 alpha:1.0];
        self.refreshBtn.layer.cornerRadius = 15.0;
        self.refreshBtn.layer.masksToBounds = YES;
        [self.refreshBtn setImage:[UIImage imageNamed:@"plv_resend.png"] forState:UIControlStateNormal];
        [self.refreshBtn addTarget:self action:@selector(refreshUpload:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshBtn.hidden = YES;
        [self addSubview:self.refreshBtn];
        [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30.0, 30.0));
            make.centerY.equalTo(self.imgView.mas_centerY);
            make.right.equalTo(self.imgView.mas_left).offset(-10.0);
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [self.imgView addGestureRecognizer:tapGesture];

        self.height = 142.0;
        self.phototBrowser = [PLVPhotoBrowser new];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imgView.image = image;
    self.imgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.imageViewSize);
        make.top.equalTo(self.mas_top).offset(10.0);
        make.trailing.equalTo(self.mas_trailing).offset(-10.0);
    }];
    [self.activityView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imgView.mas_centerX);
        make.centerY.equalTo(self.imgView.mas_centerY).offset(-12.0);
    }];
    [self.progressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.imageViewSize.width, 24.0));
        make.centerX.equalTo(self.imgView.mas_centerX);
        make.centerY.equalTo(self.imgView.mas_centerY).offset(12.0);
    }];
    [self.refreshBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30.0, 30.0));
        make.centerY.equalTo(self.imgView.mas_centerY);
        make.right.equalTo(self.imgView.mas_left).offset(-10.0);
    }];
}

- (void)setImageViewSize:(CGSize)imageViewSize {
    _imageViewSize = imageViewSize;
    self.height = imageViewSize.height + 10.0;
}

- (CGFloat)calculateCellHeightWithContent:(NSString *)content {
    if (CGSizeEqualToSize(self.imageViewSize, CGSizeZero)) {
        return 142.0;
    } else {
        return self.imageViewSize.height + 10.0;
    }
}

- (void)uploadProgress:(CGFloat)progress {
    if (progress < 0.0) {
        self.loadingBgView.hidden = NO;
        [self.activityView stopAnimating];
        self.progressLabel.hidden = YES;
    } else if (progress == 1.0) {
        self.refreshBtn.hidden = YES;
        self.loadingBgView.hidden = YES;
        [self.activityView stopAnimating];
        self.progressLabel.hidden = YES;
        self.progressLabel.text = [NSString stringWithFormat:@"%0.2f%%", progress * 100.0];
    } else {
        self.loadingBgView.hidden = NO;
        [self.activityView startAnimating];
        self.progressLabel.hidden = NO;
        self.progressLabel.text = [NSString stringWithFormat:@"%0.2f%%", progress * 100.0];
    }
}

- (void)checkFail:(BOOL)fail {
    if (fail) {
        self.imgView.layer.borderWidth = 3.0;
        self.imgView.layer.borderColor = [UIColor redColor].CGColor;
    } else {
        self.imgView.layer.borderWidth = 0.0;
    }
}

#pragma mark Private
- (void)tapImageView:(UIGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    [self.phototBrowser scaleImageViewToFullScreen:imageView];
}

- (IBAction)refreshUpload:(id)sender {
    self.refreshBtn.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshUpload:)]) {
        [self.delegate refreshUpload:self];
    }
}

@end

@interface PLVChatroomImageReceivedCell ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *actorLB;
@property (nonatomic, strong) UILabel *nickNameLB;

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIButton *refreshBtn;

@property (nonatomic, strong) PLVPhotoBrowser *phototBrowser;
@end

@implementation PLVChatroomImageReceivedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 35, 35)];
        self.avatarView.layer.cornerRadius = 35.0/2;
        self.avatarView.layer.masksToBounds = YES;
        [self addSubview:self.avatarView];
        
        self.actorLB = [[UILabel alloc] init];
        self.actorLB.layer.cornerRadius = 9.0;
        self.actorLB.layer.masksToBounds = YES;
        self.actorLB.textColor = [UIColor whiteColor];
        if (@available(iOS 8.2, *)) {
            self.actorLB.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightMedium];
        } else {
            self.actorLB.font = [UIFont systemFontOfSize:10.0];
        }
        self.actorLB.backgroundColor = UIColorFromRGB(0x2196F3);
        self.actorLB.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.actorLB];
        
        self.nickNameLB = [[UILabel alloc] init];
        self.nickNameLB.backgroundColor = [UIColor clearColor];
        self.nickNameLB.textColor = [UIColor colorWithWhite:135/255.0 alpha:1.0];
        self.nickNameLB.font = [UIFont systemFontOfSize:11.0];
        [self addSubview:self.nickNameLB];
        
        self.imgView = [[UIImageView alloc] init];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.backgroundColor = UIColorFromRGB(0xD3D3D3);
        self.imgView.layer.cornerRadius = 5.0;
        self.imgView.layer.masksToBounds = YES;
        self.imgView.userInteractionEnabled = YES;
        [self addSubview:self.imgView];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.imgView addSubview:self.activityView];
        [self.activityView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.imgView.mas_centerX);
            make.centerY.equalTo(self.imgView.mas_centerY).offset(-12.0);
        }];
        
        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.textColor = [UIColor whiteColor];
        self.progressLabel.font = [UIFont systemFontOfSize:12.0];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        [self.imgView addSubview:self.progressLabel];
        
        self.refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.refreshBtn setImage:[UIImage imageNamed:@"plv_resend.png"] forState:UIControlStateNormal];
        [self.refreshBtn addTarget:self action:@selector(refreshDownload:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshBtn.hidden = YES;
        [self.imgView addSubview:self.refreshBtn];
        [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.imgView);
            make.size.mas_equalTo(CGSizeMake(30.0, 30.0));
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [self.imgView addGestureRecognizer:tapGesture];
        
        [self.actorLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_top);
            make.height.mas_equalTo(@(18));
            make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        }];
        [self.nickNameLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarView.mas_top);
            make.height.mas_equalTo(@(18));
            make.leading.equalTo(self.actorLB.mas_trailing).offset(5);
        }];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(132, 132));
            make.top.equalTo(self.nickNameLB.mas_bottom).offset(5);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        }];
        
        self.height = 165; // 10+18+5+132
        self.phototBrowser = [PLVPhotoBrowser new];
    }
    return self;
}

- (void)setAvatar:(NSString *)avatar {
    _avatar = avatar;
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"plv_img_default_avatar"]];
}

- (void)setActor:(NSString *)actor {
    _actor = actor;
    if (actor) {
        _actorLB.text = actor;
        CGSize size = [_actorLB sizeThatFits:CGSizeMake(MAXFLOAT, 18)];
        [_actorLB mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(size.width+20, 18));
            make.top.equalTo(self.avatarView.mas_top);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        }];
    }else {
        [_actorLB mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
            make.top.equalTo(self.avatarView.mas_top);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(5);
        }];
    }
}

- (void)setNickName:(NSString *)nickName {
    _nickName = nickName;
    _nickNameLB.text = nickName;
}

- (void)setImgUrl:(NSString *)imgUrl {
    _imgUrl = imgUrl;
    if (!imgUrl) return;
    
    __weak typeof(self)weakSelf = self;
    if (CGSizeEqualToSize(self.imageViewSize, CGSizeZero)) { // 兼容无 size 数据
        [_imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                [weakSelf uploadProgress:-1.0];
            }else {
                if (image.size.width > 132 || image.size.height > 132) {
                    weakSelf.imgView.contentMode = UIViewContentModeScaleAspectFit;
                }else {
                    weakSelf.imgView.contentMode = UIViewContentModeCenter;
                }
            }
        }];
    }else { // 有 size 数据
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.imageViewSize);
            make.top.equalTo(self.nickNameLB.mas_bottom).offset(5);
            make.leading.equalTo(self.avatarView.mas_trailing).offset(10);
        }];
        [self.progressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(self.imageViewSize.width, 24.0));
            make.centerX.equalTo(self.imgView.mas_centerX);
            make.centerY.equalTo(self.imgView.mas_centerY).offset(12.0);
        }];
        [_imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            CGFloat progress = (CGFloat)receivedSize/expectedSize;
            [weakSelf uploadProgress:progress];
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                [weakSelf uploadProgress:-1.0];
            } else {
                [weakSelf uploadProgress:1.0];
            }
        }];
    }
}

- (void)setImageViewSize:(CGSize)imageViewSize {
    _imageViewSize = imageViewSize;
    self.height = imageViewSize.height + 33;
}

- (void)setActorTextColor:(UIColor *)actorTextColor {
    _actorTextColor = actorTextColor;
    if (actorTextColor) {
        _actorLB.textColor = actorTextColor;
    }
}

- (void)setActorBackgroundColor:(UIColor *)actorBackgroundColor {
    _actorBackgroundColor = actorBackgroundColor;
    if (actorBackgroundColor) {
        _actorLB.backgroundColor = actorBackgroundColor;
    }
}

- (CGFloat)calculateCellHeightWithContent:(NSString *)content {
    //return 165; // equal to self.height, 10+18+5+132
    if (CGSizeEqualToSize(self.imageViewSize, CGSizeZero)) {
        return 165;
    }else {
        return self.imageViewSize.height + 33;
    }
}

#pragma mark Private

- (void)tapImageView:(UIGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    [self.phototBrowser scaleImageViewToFullScreen:imageView];
}

- (void)uploadProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress < 0.0) {
            self.refreshBtn.hidden = NO;
            self.progressLabel.hidden = YES;
            [self.activityView stopAnimating];
        } else if (progress >= 1.0) {
            self.refreshBtn.hidden = YES;
            self.progressLabel.hidden = YES;
            [self.activityView stopAnimating];
        } else {
            self.refreshBtn.hidden = YES;
            self.progressLabel.hidden = NO;
            [self.activityView startAnimating];
            self.progressLabel.text = [NSString stringWithFormat:@"%0.2f%%", progress == -0.0 ? 0.0 : progress*100.0];
        }
    });
}

- (void)refreshDownload:(UIButton *)sender {
    sender.hidden = YES;
    [self setImgUrl:self.imgUrl];
}

@end

@interface PLVChatroomFlowerCell ()

@property (nonatomic, strong) UILabel *contentLB;
@end

@implementation PLVChatroomFlowerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLB = [[UILabel alloc] init];
        self.contentLB.backgroundColor = [UIColor clearColor];
        self.contentLB.textColor = [UIColor colorWithWhite:135/255.0 alpha:1.0];
        self.contentLB.font = [UIFont systemFontOfSize:12.0];
        self.contentLB.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.contentLB];
        
        UIImage *flower = [UIImage imageNamed:@"plv_skin_flower"];
        self.imgView = [[UIImageView alloc] initWithImage:[self imageRotatedByDegrees:flower deg:30]];
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.leading.equalTo(self.contentLB.mas_trailing);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.contentLB.text = content;
    [self.contentLB mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(17);
        make.width.lessThanOrEqualTo(@(250));
        make.centerY.equalTo(self.mas_centerY);
        make.centerX.equalTo(self.mas_centerX).offset(-15);
    }];
}

#pragma mark Private

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

@interface PLVChatroomSystemCell ()

@property (nonatomic, strong) UILabel *contentLB;
@end

@implementation PLVChatroomSystemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLB = [[UILabel alloc] init];
        self.contentLB.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.contentLB.layer.cornerRadius = 4.0;
        self.contentLB.layer.masksToBounds = YES;
        self.contentLB.textColor = [UIColor whiteColor];
        self.contentLB.font = [UIFont systemFontOfSize:12.0];
        self.contentLB.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.contentLB];
        [self.contentLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.mas_equalTo(24);
            make.width.greaterThanOrEqualTo(@(80));
            make.width.lessThanOrEqualTo(self.mas_width);
        }];
    }
    return self;
}

- (void)setContent:(NSString *)content {
    _content = content;
    self.contentLB.text = content;
    CGSize size = [self.contentLB sizeThatFits:CGSizeMake(MAXFLOAT, 24)];
    [self.contentLB mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(size.width+20, 24));
        make.width.greaterThanOrEqualTo(@(80));
        make.width.lessThanOrEqualTo(self.mas_width);
    }];
}

@end

@implementation PLVChatroomTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

@end

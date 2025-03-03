//
//  AppDelegate.m
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/8/1.
//

#import "AppDelegate.h"
#import <PolyvCloudClassSDK/PLVLiveVideoConfig.h>
#import <PolyvBusinessSDK/PLVVodConfig.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /// 以下的直播字符串参数在官网（https://console.ruizaiyun.com/#/develop/appId）上已配置好
    PLVLiveVideoConfig *liveConfig = [PLVLiveVideoConfig sharedInstance];
    liveConfig.channelId = @"358806";
    liveConfig.appId = @"fen6h6y31s";
    liveConfig.userId = @"b27622c27e";
    liveConfig.appSecret = @"9b30e9d334f74d02b08a1a2093ecd982";
    
    /// 直播后，在（https://console.ruizaiyun.com/#/channel/你的频道号/playback）中可把某段视频转存到回放列表，然后在官网（http://console.ruizaiyun.com/#/channel/358806/videoLibrary）上找到回放的 vodId 字符串值
    PLVVodConfig *vodConfig = [PLVVodConfig sharedInstance];
    vodConfig.vodId = @"ferwrq0xfj";
    NSError *error = nil;
    NSString *configString = @"TD1YSmNwb9igqvbRFuaBtZbrGfnKDTXOXi3quGttQ1yQDj2jeqri2K7QdS5QOAIqXdMhYmsVl/iV0J7rH6UcQu2v4s95/sH2DGR79ksc7gP8MbibWxMWUEB7DjYthJVVBw00jFgEkIAWxCr45Kjcxw==";/// SDK加密串
    NSString *key = @"VXtlHmwfS2oYm0CZ";/// 加密密钥
    NSString *iv = @"2u9gDPKdX6GyQJKU";/// 加密向量
    [PLVVodConfig settingsWithConfigString:configString key:key iv:iv error:&error];
    
    // 配置统计后台参数：用户Id、用户昵称及自定义参数
    [PLVLiveVideoConfig setViewLogParam:nil param2:nil param4:nil param5:nil];
    
    return YES;
}

@end

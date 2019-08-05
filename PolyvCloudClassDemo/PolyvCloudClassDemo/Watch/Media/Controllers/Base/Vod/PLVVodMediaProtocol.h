//
//  PLVVodMediaProtocol.h
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/11/21.
//

#import <Foundation/Foundation.h>

/// 回放播放器基类协议
@protocol PLVVodMediaProtocol <NSObject>

/// 必须，不能为空
@property (nonatomic, strong) NSString *vodId;

/// optional, can be nil.
@property (nonatomic, strong) NSString *channelId;
/// optional, can be nil.
@property (nonatomic, strong) NSString *userId;

@end

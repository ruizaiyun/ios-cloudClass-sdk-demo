//
//  PLVChatroomManager.h
//  PolyvCloudClassDemo
//
//  Created by ftao on 2018/11/5.
//

#import <Foundation/Foundation.h>
#import <PolyvBusinessSDK/PLVSocketObject.h>
#import "PLVChatroomCustomModel.h"
#import "PLVChatroomCustomKouModel.h"

/// 聊天室管理类
@interface PLVChatroomManager : NSObject

/// 登录对象，用于聊天室登录，由用户初始化
@property (nonatomic, strong) PLVSocketObject *loginUser;

/// 已登录用户，由socket回调设置（服务器返回信息生成，可能为nil）
@property (nonatomic, strong) PLVSocketObject *socketUser;

/// 默认昵称，初始化的登录对象未设置昵称时为true
@property (nonatomic, getter=isDefaultNick, readonly) BOOL defaultNick;

/**
 单例方法

 @return 获取 PLVChatroomManager 的单例对象
 */
+ (instancetype)sharedManager;

/**
 历史消息处理

 @param messageDict 历史消息对象
 @return 聊天室模型
 */
+ (PLVChatroomModel *)modelWithHistoryMessageDict:(NSDictionary *)messageDict;

#pragma mark - 自定义消息处理

/**
 自定义消息转模型

 @param customMessage 自定义消息
 @param mine 自己消息类型
 @return 自定义消息模型
 */
+ (PLVChatroomCustomModel *)modelWithCustomMessage:(NSDictionary *)customMessage mine:(BOOL)mine;

/**
 重命名用户昵称

 @param newName 新昵称
 */
- (void)renameUserNick:(NSString *)newName;

@end

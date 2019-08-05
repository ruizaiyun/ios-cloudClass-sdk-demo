/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "PLVFacialView.h"

@protocol DXFaceDelegate <FacialViewDelegate>

@required

// 选择表情
- (void)selectedEmoji:(PLVEmojiModel *)emojiModel;

// 删除事件
- (void)deleteEvent;

- (void)sendEvent;

@end


@interface PLVFaceView : UIView <FacialViewDelegate>

@property (nonatomic, weak) id<DXFaceDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

- (void)sendBtnEnable:(BOOL)enable;

@end

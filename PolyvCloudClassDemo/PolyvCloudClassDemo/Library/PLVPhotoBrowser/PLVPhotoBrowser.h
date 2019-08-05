//
//  PLVPhotoBrowser.h
//  PolyvCloudClassDemo
//
//  Created by ftao on 2018/10/24.
//

#import <UIKit/UIKit.h>

extern NSString *const PLVPhotoBrowserDidShowImageOnScreenNotification;

@interface PLVPhotoBrowser : NSObject

- (void)scaleImageViewToFullScreen:(UIImageView *)imageview;

@end

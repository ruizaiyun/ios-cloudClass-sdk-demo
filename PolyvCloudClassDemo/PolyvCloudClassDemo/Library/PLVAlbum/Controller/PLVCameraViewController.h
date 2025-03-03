//
//  PLVCameraViewController.h
//  zPin_Pro
//
//  Created by zykhbl on 2017/12/17.
//

#import <UIKit/UIKit.h>

@protocol PLVCameraViewControllerDelegate;

@interface PLVCameraViewController : UIViewController

@property (nonatomic, weak) id<PLVCameraViewControllerDelegate> delegate;

@end

@protocol PLVCameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(PLVCameraViewController *)cameraVC uploadImage:(UIImage *)uploadImage;

- (void)dismissCameraViewController:(PLVCameraViewController*)cameraVC;

@end

//
//  ZAlbumsViewController.h
//  zPic
//
//  Created by zykhbl on 2017/7/22.
//

#import <UIKit/UIKit.h>
#import "ZPicDefine.h"
#import "ZAlbumInfo.h"

@protocol ZAlbumsViewControllerDelegate;

@interface ZAlbumsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<ZAlbumsViewControllerDelegate> delegate;
@property (nonatomic, assign) PickerModer pcikerModer;
@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) UITableView *tableView;

- (void)loadingAlbumInfos;

@end

@protocol ZAlbumsViewControllerDelegate <NSObject>

- (void)ZAlbumsViewController:(ZAlbumsViewController*)zalbumsVC didSelect:(ZAlbumInfo*)albumInfo;

@end

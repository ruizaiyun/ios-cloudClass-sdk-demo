//
//  ZAlbumTableViewCell.h
//  zPic
//
//  Created by zykhbl on 2017/7/22.
//

#import <UIKit/UIKit.h>

@interface ZAlbumTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;

- (void)setup;

@end

//
//  Album.h
//  Memory
//
//  Created by fanjunpeng on 14-7-11.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;
@interface AlbumCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *faceImageView;  //  相册封面
@property (strong, nonatomic) UILabel *nameLabel;  //  相册名称
@property (strong, nonatomic) UILabel *countLabel;  //  照片个数

@property (strong, nonatomic) Album *album;

@end

//
//  DataHandle.h
//  Memory
//
//  Created by fanjunpeng on 14-7-12.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Album;

@interface DataHandle : NSObject

@property (strong, nonatomic) NSArray *albumsArray;

@property (strong, nonatomic) NSArray *currentImagesArray;  //  获取当前被点击的相册的照片数组

@property (strong, nonatomic) Album *currentAlbum;  // 当前展示的相册

+(DataHandle *)shareInstance;

/**
 *  获取指定indexPath相册
 *
 *  @param indexPath
 *
 *  @return 相册
 */
- (Album *)albumAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  获取指定indexpath的图片名
 *
 *  @param indexPath indexPath
 *
 *  @return 图片名
 */
- (NSString *)imageNameAtIndexPath:(NSIndexPath *) indexPath;

/**
 *  设置展示被点击的相册
 *
 *  @param indexPath          被点击的相册的indexpath
 */
- (void)setCurrentAlbumWithIndexPath:(NSIndexPath *)indexPath;

@end

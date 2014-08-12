//
//  DataHandle.m
//  Memory
//
//  Created by fanjunpeng on 14-7-12.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#import "DataHandle.h"
#import "Album.h"

@implementation DataHandle

+(DataHandle *)shareInstance
{
    static DataHandle *s_dataHandle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_dataHandle = [[DataHandle alloc] init];
    });
    return s_dataHandle;
}


-(NSArray *)albumsArray
{
    if (_albumsArray == nil) {
        NSMutableArray *array = [NSMutableArray array];
        //  获取plist文件路径
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Photosets" ofType:@"plist"];
        NSArray *dataArray = [NSArray arrayWithContentsOfFile:path];
        NSLog(@"%@",dataArray);
        for (int i = 0; i < dataArray.count; i ++) {
            Album * _album = [[Album alloc] init];
            _album.name = [NSString stringWithFormat:@"相册%d",i + 1];
            _album.photoesArray = [dataArray objectAtIndex:i];
            _album.faceImageName = [_album.photoesArray firstObject];
            [array addObject:_album];
        }
        self.albumsArray = array;
    }
    
    return _albumsArray;
}

- (Album *)albumAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.albumsArray objectAtIndex:indexPath.item];
}

- (void)setCurrentAlbumWithIndexPath:(NSIndexPath *)indexPath
{
    self.currentAlbum = [self albumAtIndexPath:indexPath];

    self.currentImagesArray = _currentAlbum.photoesArray;
}


- (NSString *)imageNameAtIndexPath:(NSIndexPath *) indexPath
{
    return [self.currentImagesArray objectAtIndex:indexPath.item];
}

@end

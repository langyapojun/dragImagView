//
//  Album.h
//  Memory
//
//  Created by fanjunpeng on 14-7-12.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject

@property (copy, nonatomic) NSString *faceImageName;  //  相册封面
@property (copy, nonatomic) NSString *name;  //  相册名称
@property (strong, nonatomic) NSArray  *photoesArray;  //  照片数组




@end

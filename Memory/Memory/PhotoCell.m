//
//  PhotoCell.m
//  Memory
//
//  Created by fanjunpeng on 14-7-11.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.photoImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_photoImageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

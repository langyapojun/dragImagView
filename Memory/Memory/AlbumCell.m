//
//  Album.m
//  Memory
//
//  Created by fanjunpeng on 14-7-11.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//



#import "AlbumCell.h"
#import "Album.h"


@implementation AlbumCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubviews];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)createSubviews
{
    self.faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, self.width - 2 * 2, self.height - kNameLabelHeight)];
    [self.contentView addSubview:_faceImageView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _faceImageView.bottom, kNameLabelWidth, kNameLabelHeight)];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [UIFont systemFontOfSize:kLabelFont];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.right, _nameLabel.top, self.width - _nameLabel.width, _nameLabel.height)];
    [self.contentView addSubview:_countLabel];
    _countLabel.font = [UIFont systemFontOfSize:kLabelFont];
    _countLabel.textAlignment = NSTextAlignmentCenter;
}

-(void)setAlbum:(Album *)album
{
    if (_album != album) {
        _album = album;
    }
    self.faceImageView.image = [UIImage imageNamed:[album.faceImageName stringByAppendingString:@".jpg"]];
    self.nameLabel.text = album.name;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",album.photoesArray.count];

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

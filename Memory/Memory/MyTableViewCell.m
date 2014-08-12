//
//  TableViewCell.m
//  Memory
//
//  Created by fanjunpeng on 14-7-11.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//



#import "MyTableViewCell.h"

@implementation MyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, kTableViewWith - 10, kTableViewWith - 10)];
        [self.contentView addSubview:_photoImageView];
    }
    return self;
}

+ (CGFloat)cellHeight
{
    return kTableViewWith;
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

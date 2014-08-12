//
//  TableViewCell.h
//  Memory
//
//  Created by fanjunpeng on 14-7-11.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *photoImageView;


/**
 *  获取cell的高度
 *
 *  @return cell高度
 */
+ (CGFloat)cellHeight;

@end

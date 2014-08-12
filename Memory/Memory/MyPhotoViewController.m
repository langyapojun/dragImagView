//
//  FPMyPhotoViewController.m
//  Memory
//
//  Created by fanjunpeng on 14-7-10.
//  Copyright (c) 2014年 lanou3g. All rights reserved.
//

#define kAlbumcell_identifier @"albumcell"
#define kPhotocell_identifier @"photocell"
#define kHeaderView_height 40

#import "MyPhotoViewController.h"
#import "MyTableViewCell.h"
#import "AlbumCell.h"
#import "PhotoCell.h"
#import "Album.h"
#import "DataHandle.h"

@interface MyPhotoViewController ()
{
    CGFloat lastBotommY;  //  在tableview上底部时上次的点y值
    CGFloat lastTopY;  // 在顶部时的上次y值
}

@property (strong, nonatomic) UITableView *tableView;  //  左侧的tableview
@property (strong, nonatomic) UICollectionView *alblumCollectionView; //  展示相册的collcetionView
@property (strong, nonatomic) UICollectionView *photoCollectionView;  //  展示图片的collectionView

@property (strong, nonatomic) NSMutableArray *tableDataArray;  //  左侧tableview图片数组
@property (strong, nonatomic) UIView *headerView;  //  展示相册时，顶部视图
@property (strong, nonatomic) UIImageView *moveAbleImageView;  //  可移动的图片
@property (assign, nonatomic) CGPoint primitiveCenter;  //  移动图片的初始中心点位置
@property (strong, nonatomic) NSMutableArray *centerYArray;  //  所有cell的中心点Y坐标数组
@property (strong, nonatomic) UIImageView *bigImageView; // 变大的图片
@property (strong, nonatomic) NSIndexPath *selectedIndexPath; //  被选中的indexpath


@end

@implementation MyPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"我的相册";
    [self createTableView];
    //  创建相册collectionview
    [self createAlumCollectionView];
    //  tableview要展示的数据
    self.tableDataArray = [NSMutableArray array];
    for (int i = 0; i < 10; i ++) {
        UIImage *placeHolder = [UIImage imageNamed:@"photoset0-10.jpg"];
        [_tableDataArray addObject:placeHolder];
    }
    
}


//  创建配置tableview
- (void)createTableView
{
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kTableViewWith, kScreenHeight) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        //  设置tableview的背景图
        UIImageView *backView = [[UIImageView alloc] initWithFrame:_tableView.bounds];
        backView.backgroundColor = [UIColor orangeColor];
        [self.tableView setBackgroundView:backView];
        //  隐藏垂直滚动条
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
}

- (void)createAlumCollectionView
{
    //  加if判断，已经创建过了就不用再创建了
    if (_alblumCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.alblumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kTableViewWith, 64, kScreenWidth - kTableViewWith, kScreenHeight - 64) collectionViewLayout:layout];
        [self.view addSubview:_alblumCollectionView];
        _alblumCollectionView.backgroundColor = [UIColor grayColor];
        
        self.alblumCollectionView.delegate = self;
        self.alblumCollectionView.dataSource = self;
        [self.alblumCollectionView registerClass:[AlbumCell class] forCellWithReuseIdentifier:kAlbumcell_identifier];
    }
    
}

- (void)createPhotoCollectionView;
{
    //  已经创建 不用重复创建

        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(kTableViewWith, 64, kScreenWidth - kTableViewWith, kHeaderView_height)];
        [self.view addSubview:_headerView];
        
        UILabel *albumNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 120, kHeaderView_height)];
        albumNameLabel.text = [[DataHandle shareInstance].currentAlbum name];
        [_headerView addSubview:albumNameLabel];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        backBtn.frame = CGRectMake(_headerView.width - 60, 0, 50, kHeaderView_height);
        [_headerView addSubview:backBtn];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToAlbumCollection) forControlEvents:UIControlEventTouchUpInside];
    
    
    //  已经创建不用重复创建
//    if (_photoCollectionView == nil) {
    
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kTableViewWith, _headerView.bottom, kScreenWidth - kTableViewWith, kScreenHeight - 64 - kHeaderView_height) collectionViewLayout:layout];
//    }
        [self.view addSubview:_photoCollectionView];
        _photoCollectionView.backgroundColor = [UIColor grayColor];
        self.photoCollectionView.delegate = self;
        self.photoCollectionView.dataSource = self;
        [_photoCollectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotocell_identifier];
        //  添加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        [_photoCollectionView addGestureRecognizer:longPress];
        
        //  添加平移手势
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [_photoCollectionView addGestureRecognizer:panRecognizer];
        panRecognizer.delegate = self;
    
}

#pragma mark -
#pragma mark -- gesture delegate

//  返回yes，使自定义添加的手势，与原有手势共存，默认情况下 该方法返回NO。NO的情况下，自定义的UIPanGestureRecognizer 与collectionview原有的拖动手势冲突，自定义的将不响应。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}

#pragma mark -
#pragma mark -- action

//  点击返回相册列表
-(void)backToAlbumCollection
{
    [UIView animateWithDuration:0.3 animations:^{
        self.photoCollectionView.alpha = 0.0;
        self.headerView.alpha = 0.0;
        self.alblumCollectionView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
    
}
//  长按手势
- (void)longPressAction:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //  获取当前点
        CGPoint point = [recognizer locationInView:self.view];
        // 获取当前indexpath
        NSIndexPath *indexPath = [self indexPathForCollectionView:_photoCollectionView WithPoint:point];
        [self setMoveAbleImageViewWithCollectionView:_photoCollectionView AtIndexPath:indexPath];
        self.selectedIndexPath = indexPath;
        [recognizer cancelsTouchesInView];
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //  透明度改变
        PhotoCell *cell = (PhotoCell *)[_photoCollectionView cellForItemAtIndexPath:_selectedIndexPath];
        //  获取当前图片的中心点位置
        [UIView animateWithDuration:0.3 animations:^{
            //  回到原始位置
            _moveAbleImageView.size = CGSizeMake(cell.photoImageView.width, cell.photoImageView.height);
        } completion:^(BOOL finished) {
            //  动画结束，从父视图移除
            [_moveAbleImageView removeFromSuperview];
            cell.alpha = 1.0;
        }];
    }
    
}

//  平移手势

- (void)panGestureAction:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //  初始化图片移动到底部或顶部时，lastBotommY或lastTopY的值。
        lastBotommY = kScreenHeight - _moveAbleImageView.height / 2;
        lastTopY = 64 + _moveAbleImageView.height / 2;
        // 获取手指所在点相对于根视图的位置
        _primitiveCenter = [recognizer locationInView:self.view];
        _moveAbleImageView.center = _primitiveCenter;
        
        NSLog(@"-----------%@",NSStringFromCGPoint(_primitiveCenter));
    }
    //  手指偏移量
    CGPoint translation = [recognizer translationInView:_moveAbleImageView];
    //  随手指移动
    _moveAbleImageView.center = CGPointMake(_primitiveCenter.x + translation.x,_primitiveCenter.y + translation.y );
    
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        //  显示tableview上要替换图片的cell
        [self showExchangeCell];
        //  获取当前点
        CGPoint currentPoint = [recognizer locationInView:self.view];
        //  到下边缘时手指点y值
        CGFloat centerYbotomm = kScreenHeight - _moveAbleImageView.height / 2;
        CGFloat centerYtop = 64 + _moveAbleImageView.height / 2;
        
        //  到达tableview下边缘
        if (currentPoint.y > centerYbotomm ) {
            //  固定图片
            _moveAbleImageView.centerY = centerYbotomm;
            //  如果手指比往上移动了，图片位置不变
            if (currentPoint.y >= lastBotommY && currentPoint.x < kTableViewWith + 30) {
                //  tableview偏移量
                CGFloat offsetY = 10 * (currentPoint.y - centerYbotomm);
                CGFloat maxOffset = _tableView.contentSize.height - _tableView.height;
                if (offsetY > maxOffset) {
                    offsetY = maxOffset;
                }
                if (offsetY > _tableView.contentOffset.y) {
                    _tableView.contentOffset = CGPointMake(0, offsetY);
                }
            }
            lastBotommY = currentPoint.y;
        }
        //  到达tableview上边缘
        if (currentPoint.y < centerYtop ) {
            //  固定图片
            _moveAbleImageView.centerY = centerYtop;
            if (currentPoint.y <= lastTopY && currentPoint.x < kTableViewWith + 30) {
                CGFloat offsetY = 2 * (currentPoint.y - centerYtop);
                if (offsetY < _tableView.contentOffset.y ) {
                    _tableView.contentOffset = CGPointMake(0, offsetY + _tableView.contentOffset.y);
                }
                if (_tableView.contentOffset.y < - 64) {
                    _tableView.contentOffset = CGPointMake(0, - 64);
                }
            }
            lastTopY = currentPoint.y;
        }
        //  到达屏幕左边缘
        if (currentPoint.x < _moveAbleImageView.width / 2) {
            currentPoint.x = _moveAbleImageView.width / 2;
        }
        if (currentPoint.x > kScreenWidth - _moveAbleImageView.width / 2) {
            currentPoint.x = kScreenWidth - _moveAbleImageView.width / 2;
        }
        
    }
    
    //  手势结束时的动作
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //  透明度改变
        PhotoCell *cell = (PhotoCell *)[_photoCollectionView cellForItemAtIndexPath:_selectedIndexPath];
        //  获取当前图片的中心点位置
        NSIndexPath *indexPath = [self showExchangeCell];
        if (!indexPath) {
            [UIView animateWithDuration:0.3 animations:^{
                //  回到原始位置
                _moveAbleImageView.center = _primitiveCenter;
                _moveAbleImageView.size = CGSizeMake(cell.photoImageView.width, cell.photoImageView.height);
            } completion:^(BOOL finished) {
                //  动画结束，从父视图移除
                [_moveAbleImageView removeFromSuperview];
                cell.alpha = 1.0;
            }];
        }else{
            [self exchangeImageAtIndexPath:indexPath];
            [UIView animateWithDuration:0.3 animations:^{
                cell.alpha = 1.0;
            }];
        }
        
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"%@",NSStringFromCGPoint(_tableView.contentOffset));
}

#pragma mark -
#pragma mark - table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"tableViewCell";
    MyTableViewCell *tableCell = (MyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tableCell == nil) {
        tableCell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    tableCell.backgroundColor = [UIColor clearColor];
    NSLog(@"%@",NSStringFromCGRect(tableCell.contentView.bounds));
    
    tableCell.photoImageView.backgroundColor = [UIColor cyanColor];
    if (_tableDataArray && _tableDataArray.count > 0) {
        UIImage *image = [_tableDataArray objectAtIndex:indexPath.row];
        tableCell.photoImageView.image = image;
    }
    return tableCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [MyTableViewCell cellHeight];
}

#pragma mark -
#pragma mark --  collection view delegate & datasource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.alblumCollectionView) {
        AlbumCell *_albumCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumcell_identifier forIndexPath:indexPath];
        Album *_album = [[DataHandle shareInstance] albumAtIndexPath:indexPath];
        _albumCell.album = _album;
        return _albumCell;
    }
    PhotoCell *_photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotocell_identifier forIndexPath:indexPath];
    //  获取当前的collectionview的数据
    if ([DataHandle shareInstance].currentImagesArray) {
        NSString *imageName = [[[DataHandle shareInstance] imageNameAtIndexPath:indexPath] stringByAppendingString:@".jpg"];
        _photoCell.photoImageView.image = [UIImage imageNamed:imageName];
    }
    return _photoCell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (collectionView == self.alblumCollectionView) {
        return 6;
    }
    return [DataHandle shareInstance].currentImagesArray.count;
}

//  设置cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  cell的宽度
    CGFloat with = (kScreenWidth - kTableViewWith - 3 * kSpace) / 2;
    if (collectionView == self.alblumCollectionView) {
        return CGSizeMake(with, with + kNameLabelHeight);
    }
    return CGSizeMake(with, with);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(kSpace, kSpace, kSpace, kSpace);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.alblumCollectionView) {
        //  设置当前点击的相册
        [[DataHandle shareInstance] setCurrentAlbumWithIndexPath:indexPath];
        //  动画隐藏当前collectionview
        [UIView animateWithDuration:0.3 animations:^{
            collectionView.alpha = 0;
        } completion:^(BOOL finished) {
            //  创建一个collectionview
            [self createPhotoCollectionView];
        }];
    }
}

#pragma mark -
#pragma other --

//  根据当前点，获取该点在collectionview上的indexpath
- (NSIndexPath *)indexPathForCollectionView:(UICollectionView *)collectionView WithPoint:(CGPoint) point
{
    //  创建可移动的图片
    if (_moveAbleImageView == nil) {
        
    }
    self.moveAbleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    _moveAbleImageView.center = point;
    [UIView animateWithDuration:0.3 animations:^{
        _moveAbleImageView.size = CGSizeMake(80, 80);
        _moveAbleImageView.center = point;
    }];
    if (collectionView.contentOffset.y > 0) {
        point = CGPointMake(point.x, point.y + collectionView.contentOffset.y);
    }
    //  获取collectionview所有可见的indexpath
    NSArray *indexPaths = [collectionView indexPathsForVisibleItems];
    //  遍历获取每个item的布局属性
    for (int i = 0 ; i < indexPaths.count; i ++) {
        NSIndexPath *indexPath = [indexPaths objectAtIndex:i ];
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        // 获取相对于window的frame
        CGRect frame = CGRectMake(attributes.frame.origin.x + kTableViewWith, attributes.frame.origin.y + 64 + kHeaderView_height, attributes.size.width, attributes.size.height);
        CGFloat px = point.x;
        CGFloat py = point.y;
        CGFloat fx = frame.origin.x;
        CGFloat f_right = fx + frame.size.width;
        CGFloat fy = frame.origin.y;
        CGFloat f_bottom = fy + frame.size.height;
        if (px > fx && px < f_right && py > fy && py < f_bottom) {
            return indexPath;
        }
    }
    
    return nil;
}

//  设置可移动图标
- (void)setMoveAbleImageViewWithCollectionView:(UICollectionView *)collectionView AtIndexPath:(NSIndexPath *)indexPath
{
    //  获取到当前的item
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //  获取当前的image
    UIImage *image = cell.photoImageView.image;
    [UIView animateWithDuration:0.3 animations:^{
        cell.alpha = 0.4;
    }];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_moveAbleImageView];
    _moveAbleImageView.image = image;
    _moveAbleImageView.userInteractionEnabled = YES;
    //  添加平移手势
}


//  替换图片
-(void)exchangeImageAtIndexPath:(NSIndexPath *)indexPath
{
    //  获取图片
    UIImage *image = _moveAbleImageView.image;
    [_tableDataArray replaceObjectAtIndex:indexPath.row withObject:image];
    
    [UIView animateWithDuration:0.3 animations:^{
        _bigImageView.alpha = 0.0;
        _moveAbleImageView.center = _bigImageView.center;
    } completion:^(BOOL finished) {
        [_bigImageView removeFromSuperview];
        [_moveAbleImageView removeFromSuperview];
        // 刷新列表
        [_tableView reloadData];
    }];
}


- (NSArray *)centerYArray
{
    self.centerYArray = [NSMutableArray array];
    //  cell高度
    CGFloat cellHight = [MyTableViewCell cellHeight];
    //  第0个cell的centerY
    CGFloat firstY;
    if (_tableView.contentOffset.y > 0) {
        firstY = cellHight / 2 - _tableView.contentOffset.y;
    }else{
        firstY = 64 + cellHight / 2;
    }
    for (int i = 0; i < 10; i ++) {
        NSNumber *centerY = [NSNumber numberWithFloat:(firstY + i * cellHight)];
        [_centerYArray addObject:centerY];
        
    }
    return _centerYArray;
}

//  获取要替换的cell
- (NSIndexPath *)showExchangeCell
{
    //  遍历获取cell
    for (int i = 0; i < 10; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        // 获取当前cell
        MyTableViewCell *cell = (MyTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        CGFloat centerY = [[[self centerYArray] objectAtIndex:i] floatValue];
        if ([self isBigThanHalfAreaAtIndexPath:indexPath]) {
            if (_bigImageView == nil || _bigImageView.superview == nil) {
                self.bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                _bigImageView.centerY = centerY;
                if (_tableView.contentOffset.y > 0) {
                    _bigImageView.centerY = centerY;
                }
                _bigImageView.image = cell.photoImageView.image;
                [self.view addSubview:_bigImageView];
            }
            return indexPath;
        }else{
            if (_bigImageView.superview) {
                [_bigImageView removeFromSuperview];
            }
        }
        
    }
    return nil;
}

//  与指定indexPath的cell 比较面积，返回是否大于该cell的一半，如果大于返回yes 否则no
- (BOOL)isBigThanHalfAreaAtIndexPath:(NSIndexPath *) indexPath
{
    //  获取当前cell的中心点位置
    CGFloat centerY = [[[self centerYArray] objectAtIndex:indexPath.row] floatValue];
    //  获取cell上图片上下左右的值
    CGFloat cellHeight = [MyTableViewCell cellHeight];
    CGFloat a_top = centerY - (cellHeight - 10) / 2;
    CGFloat a_bottom = centerY + (cellHeight - 10) / 2;
    CGFloat a_right = kTableViewWith - 5;
    //  获取可移动图片上下左右的值
    CGFloat b_top = _moveAbleImageView.top;
    CGFloat b_bottom = _moveAbleImageView.bottom;
    CGFloat b_left = _moveAbleImageView.left;
    //  比较这个cell是否重叠
    CGFloat area; // 面积
    //  如果有重叠
    if (b_bottom > a_top && a_right > b_left && b_top < a_bottom) {
        if (b_top < a_top) { //  a在b的下面
            area = (b_bottom - a_top) * (a_right - b_left);
        }else{
            area = (a_bottom - b_top) * (a_right - b_left);
        }
        if (area > 80 * 80 / 2) {
            NSLog(@"area ==  %f",area);
            return YES;
        }
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

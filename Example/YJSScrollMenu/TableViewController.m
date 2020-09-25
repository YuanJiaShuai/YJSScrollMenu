//
//  TableViewController.m
//  YJSScrollMenu
//
//  Created by Yan. on 2017/6/28.
//  Copyright © 2017年 Yan. All rights reserved.
//

#import "TableViewController.h"
#import "DataSource.h"
#import "Masonry.h"

#define IMG(name)           [UIImage imageNamed:name]
//自动处理屏幕适配
#define kScale(P) ((P) * ([UIScreen mainScreen].bounds.size.width / 375.f))

@interface TableViewController ()<YJSScrollMenuDataSource,YJSScrollMenuDelegate>
{
    BOOL _showHeader;
    BOOL _automaticUpdate;
}

/**
 是否自动更新
 */
@property (weak, nonatomic) IBOutlet UILabel *label;
/**
 *  allDataSource
 */
@property (nonatomic, strong) NSMutableArray<DataSource *> *allDataSource;
/**
 * 菜单
 */
@property (nonatomic, strong) YJSScrollMenu *menu;
/**
 *  dataSource
 */
@property (nonatomic, strong) NSMutableArray<DataSource *> *dataSource;
/**
 *  分区数
 */
@property (nonatomic, assign) NSUInteger number;
@end

@implementation TableViewController
- (NSMutableArray<DataSource *> *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (NSMutableArray<DataSource *> *)allDataSource{
    if (_allDataSource == nil) {
        _allDataSource = [NSMutableArray array];
    }
    return _allDataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    
    //GCD
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self createData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.menu reloadData];
            
        });
    });
}

#pragma mark - Prepare UI
- (void)prepareUI{
    
    self.number = 1;
    
    _showHeader = YES;
    _automaticUpdate = YES;
    
    self.label.text = @"YES";
    
    self.menu = [[YJSScrollMenu alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,kScale(330)) delegate:self];
    self.menu.pageControl.pageIndicatorTintColor = [UIColor redColor];
    self.menu.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
//    self.menu.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"pageControlCurrentDot"];
//    self.menu.pageControl.pageIndicatorImage = [UIImage imageNamed:@"pageControlDot"];
    self.menu.popupLayoutType = PopupLayoutTypeCenter;
    self.menu.pagingEnabled = NO;
//    self.menu.backgroundColor = [UIColor grayColor];
    self.tableView.tableHeaderView = self.menu;
    self.tableView.tableFooterView = [UIView new];
    
    [YJSMenuItem appearance].textFont = [UIFont systemFontOfSize:12];
    [YJSMenuItem appearance].textColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1.0];
}
#pragma mark -  Data
- (void)createData{
    NSArray *images = @[IMG(@"icon_cate"),
                        IMG(@"icon_drinks"),
                        IMG(@"icon_movie"),
                        IMG(@"icon_recreation"),
                        IMG(@"icon_stay"),
                        IMG(@"icon_ traffic"),
                        IMG(@"icon_ scenic"),
                        IMG(@"icon_fitness"),
                        IMG(@"icon_fitment"),
                        IMG(@"icon_hairdressing"),
                        IMG(@"icon_mom"),
                        IMG(@"icon_study"),
                        IMG(@"icon_travel"), @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1498711713465&di=d986d7003deaae41342dd9885c117e38&imgtype=0&src=http%3A%2F%2Fs9.rr.itc.cn%2Fr%2FwapChange%2F20168_3_0%2Fa86hlk59412347762310.GIF"];
    NSArray *titles = @[@"美食",
                        @"休闲娱乐",
                        @"电影/演出",
                        @"KTV",
                        @"酒店住宿",
                        @"火车票/机票",
                        @"旅游景点",
                        @"运动健身",
                        @"家装建材",
                        @"美容美发",
                        @"母婴",
                        @"学习培训",
                        @"旅游出行",
                        @"动态图\n从网络获取"];
    
    for (NSUInteger idx = 0; idx< images.count; idx ++) {
        
        DataSource *object = [[DataSource alloc] init];
        object.itemTitle = titles[idx];
        object.itemImage = images[idx];
        object.itemPlaceholder = IMG(@"placeholder");
        
        [self.allDataSource addObject:object];
        
    }
    
    [self.dataSource addObjectsFromArray:self.allDataSource];
    
    
}
#pragma mark - YJSScrollMenuProtocol
- (NSUInteger)numberOfSectionsInScrollMenu:(YJSScrollMenu *)menu{
    
    return self.number;
}
- (NSUInteger)scrollMenu:(YJSScrollMenu *)menu numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}
- (id<YJSDataProtocol>)scrollMenu:(YJSScrollMenu *)scrollMenu objectAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.dataSource[indexPath.item];
}
- (CGSize)itemSizeOfScrollMenu:(YJSScrollMenu *)menu{
    
    return CGSizeMake(kScale(85), kScale(90));
}
/** 如果不要页眉，不用遵守此协议  */
- (UIView *)scrollMenu:(YJSScrollMenu *)menu headerInSection:(NSUInteger)section{
    
    if (_showHeader) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kScale(30))];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:kScale(17)];
        label.text = [NSString stringWithFormat:@"--  SECTION %ld  --",section];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(view);
        }];
        
        switch (section%3) {
            case 0:
                label.textColor = [UIColor greenColor];
                break;
            case 1:
                label.textColor = [UIColor orangeColor];
                break;
            case 2:
                label.textColor = [UIColor blueColor];
                break;
            default:
                break;
        }
        
        return view;
    }
    
    return nil;

}
- (CGFloat)heightOfHeaderInScrollMenu:(YJSScrollMenu *)menu{
    
    return   _showHeader ? kScale(30) : 0;
    
}
- (void)scrollMenu:(YJSScrollMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"IndexPath:%@",indexPath);
    
}
- (BOOL)shouldAutomaticUpdateFrameInScrollMenu:(YJSScrollMenu *)menu{
    
    return _automaticUpdate;
}
#pragma mark - TableView Delegate & DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            
            [self.dataSource addObjectsFromArray:[self.allDataSource subarrayWithRange:NSMakeRange(arc4random()%8 , 5)]];

            break;
        case 1:
            self.dataSource.count > 4 ?  [self.dataSource removeObjectsInRange:NSMakeRange(0, 4)] : nil;
            break;
        case 2:{
            if (self.number <= 5) {
                
                self.number ++;
            }
        }
            break;
        case 3:{
            if (self.number >= 1) {
                
                self.number --;
            }
        }
            break;
        case 4:
            _showHeader = !_showHeader;
            break;
        case 5:{
            _automaticUpdate = !_automaticUpdate;
            self.label.text = _automaticUpdate ? @"YES" : @"NO" ;
        }
            break;
        default:
            break;
    }
    
    self.tableView.tableHeaderView = nil;
    
    [self.menu reloadData];
    
    self.tableView.tableHeaderView = self.menu;
}

@end

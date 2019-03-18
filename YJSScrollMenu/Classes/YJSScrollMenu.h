//
//  YJSScrollMenu.h
//  YJSScrollMenu
//
//  Created by yjs on 2019/3/14.
//  Copyright © 2019 一叶障目. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PopupLayoutType) {
    PopupLayoutTypeTop = 0,
    PopupLayoutTypeLeft,
    PopupLayoutTypeBottom,
    PopupLayoutTypeRight,
    PopupLayoutTypeCenter,
    PopupLayoutTypeNone //default
};

NS_ASSUME_NONNULL_BEGIN

/**数据模型协议*/
@protocol YJSDataProtocol<NSObject>

/**
 显示文本
 */
@property (strong, nonatomic) NSString *itemTitle;

/**
 显示图片, 可以为NSURL， NSString， UIImage
 */
@property (strong, nonatomic) id itemImage;

/**
 占位图片
 */
@property (strong, nonatomic) UIImage *itemPlaceholder;

@end

@interface YJSPageControl : UIControl

@property (nonatomic, assign) NSInteger numberOfPages;          // default is 0
@property (nonatomic, assign) NSInteger currentPage;            // default is 0. value pinned to 0..numberOfPages-1

@property (nonatomic, assign) BOOL hidesForSinglePage;          // hide the the indicator if there is only one page. default is NO

@property (nonatomic, assign) CGFloat pageIndicatorSpaing;
@property (nonatomic, assign) UIEdgeInsets contentInset; // center will ignore this
@property (nonatomic, assign ,readonly) CGSize contentSize; // real content size

// indicatorTint color
@property (nullable, nonatomic,strong) UIColor *pageIndicatorTintColor;
@property (nullable, nonatomic,strong) UIColor *currentPageIndicatorTintColor;

// indicator image
@property (nullable, nonatomic,strong) UIImage *pageIndicatorImage;
@property (nullable, nonatomic,strong) UIImage *currentPageIndicatorImage;

@property (nonatomic, assign) UIViewContentMode indicatorImageContentMode; // default is UIViewContentModeCenter

@property (nonatomic, assign) CGSize pageIndicatorSize; // indicator size
@property (nonatomic, assign) CGSize currentPageIndicatorSize; // default pageIndicatorSize

@property (nonatomic, assign) CGFloat animateDuring; // default 0.3

- (void)setCurrentPage:(NSInteger)currentPage animate:(BOOL)animate;

@end

/**菜单单元格*/
@interface YJSMenuItem : UICollectionViewCell

/**
 图片尺寸 default CGSizeMake(40, 40)
 */
@property (assign, nonatomic) CGSize itemImgSize UI_APPEARANCE_SELECTOR;

/**
 图片与文本的距离，默认是 10
 */
@property (assign, nonatomic) CGFloat titleImgSpace UI_APPEARANCE_SELECTOR;

/**
 图片的圆角半径
 */
@property (assign, nonatomic) CGFloat itemImgCornerRadius UI_APPEARANCE_SELECTOR;

/**
 文本的文字颜色
 */
@property (strong, nonatomic) UIColor *textColor UI_APPEARANCE_SELECTOR;

/**
 文本的字体
 */
@property (strong, nonatomic) UIFont *textFont UI_APPEARANCE_SELECTOR;

@end

@class YJSScrollMenu;

@protocol YJSScrollMenuDelegate <NSObject>
@optional

/**
 单元格尺寸 default(40, 70)

 @param menu YJSScrollMenu
 @return CGSize
 */
- (CGSize)itemSizeOfScrollMenu:(YJSScrollMenu *)menu;

/**
 分区的页眉，默认不显示

 @param menu YJSScrollMenu
 @param section 分区
 @return UIView
 */
- (UIView *)scrollMenu:(YJSScrollMenu *)menu headerInSection:(NSUInteger)section;

/**
 页眉的高度，默认20
 
 @param menu 菜单
 @return CGFloat
 */
- (CGFloat)heightOfHeaderInScrollMenu:(YJSScrollMenu *)menu;

/**
 分页器的高度，默认15
 
 @param menu 菜单
 @return CGFloat
 */
- (CGFloat)heightOfPageControlInScrollMenu:(YJSScrollMenu *)menu;

/**
 当单元格数量改变时，是否自动更新Frame以适应。默认是NO
 
 @return BOOL
 */
- (BOOL)shouldAutomaticUpdateFrameInScrollMenu:(YJSScrollMenu *)menu;

/**
 单元格点击回调
 
 @param menu 菜单
 @param indexPath 索引
 */
- (void)scrollMenu:(YJSScrollMenu *)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol YJSScrollMenuDataSource <NSObject>

/**
 每个分区单元格的数量
 
 @param menu 菜单
 @param section 分区
 @return NSUInteger
 */
- (NSUInteger)scrollMenu:(YJSScrollMenu *)menu numberOfItemsInSection:(NSInteger)section;
/**
 分区的数量
 
 @param menu 菜单
 @return NSUInteger
 */
- (NSUInteger)numberOfSectionsInScrollMenu:(YJSScrollMenu *)menu;
/**
 数据源
 
 @param scrollMenu 菜单
 @param indexPath 索引
 @return id<YANObjectProtocol>
 */
- (id<YJSDataProtocol>)scrollMenu:(YJSScrollMenu *)scrollMenu objectAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface YJSScrollMenu : UIView

/**
 bounces default = YES
 */
@property (assign, nonatomic) BOOL bounces;

/**
 pagingEnabled default = YES
 */
@property (assign, nonatomic) BOOL pagingEnabled;

/**
 *  分页控制器
 */
@property (nonatomic, strong) YJSPageControl *pageControl;

/**
 试图刷新动画
 */
@property (assign, nonatomic) PopupLayoutType popupLayoutType;

/**
 初始化方法
 
 @param frame CGRect
 @param aDelegate id
 @return 实例
 */
- (instancetype)initWithFrame:(CGRect)frame  delegate:(id)aDelegate;

/**
 刷新
 */
- (void)reloadData;

#pragma mark - 禁用的初始化方法
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

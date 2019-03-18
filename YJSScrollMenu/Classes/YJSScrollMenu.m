//
//  YJSScrollMenu.m
//  YJSScrollMenu
//
//  Created by yjs on 2019/3/14.
//  Copyright © 2019 一叶障目. All rights reserved.
//

#import "YJSScrollMenu.h"
#import "YJSFlowLayout.h"
#import "Masonry.h"
#import "YYWebImage.h"

//自动处理屏幕适配
#define kScale(P) ((P) * ([UIScreen mainScreen].bounds.size.width / 375.f))

@interface YJSPageControl()

// UI
@property (nonatomic, strong) NSArray<UIImageView *> *indicatorViews;

// Data
@property (nonatomic, assign) BOOL forceUpdate;

@end

@implementation YJSPageControl

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configurePropertys];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configurePropertys];
    }
    return self;
}

- (void)configurePropertys {
    self.userInteractionEnabled = NO;
    _forceUpdate = NO;
    _animateDuring = 0.3;
    _pageIndicatorSpaing = 10;
    _indicatorImageContentMode = UIViewContentModeCenter;
    _pageIndicatorSize = CGSizeMake(6,6);
    _currentPageIndicatorSize = _pageIndicatorSize;
    _pageIndicatorTintColor = [UIColor colorWithRed:128/255. green:128/255. blue:128/255. alpha:1];
    _currentPageIndicatorTintColor = [UIColor whiteColor];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        _forceUpdate = YES;
        [self updateIndicatorViews];
        _forceUpdate = NO;
    }
}

#pragma mark - getter setter

- (CGSize)contentSize {
    CGFloat width = (_indicatorViews.count - 1) * (_pageIndicatorSize.width + _pageIndicatorSpaing) + _pageIndicatorSize.width + _contentInset.left +_contentInset.right;
    CGFloat height = _currentPageIndicatorSize.height + _contentInset.top + _contentInset.bottom;
    return CGSizeMake(width, height);
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (numberOfPages == _numberOfPages) {
        return;
    }
    _numberOfPages = numberOfPages;
    if (_currentPage >= numberOfPages) {
        _currentPage = 0;
    }
    [self updateIndicatorViews];
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage || _indicatorViews.count <= currentPage) {
        return;
    }
    _currentPage = currentPage;
    if (!CGSizeEqualToSize(_currentPageIndicatorSize, _pageIndicatorSize)) {
        [self setNeedsLayout];
    }
    [self updateIndicatorViewsBehavior];
    if (self.userInteractionEnabled) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage animate:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:_animateDuring animations:^{
            [self setCurrentPage:currentPage];
        }];
    }else {
        [self setCurrentPage:currentPage];
    }
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage {
    _pageIndicatorImage = pageIndicatorImage;
    [self updateIndicatorViewsBehavior];
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    _currentPageIndicatorImage = currentPageIndicatorImage;
    [self updateIndicatorViewsBehavior];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self updateIndicatorViewsBehavior];
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self updateIndicatorViewsBehavior];
}

- (void)setPageIndicatorSize:(CGSize)pageIndicatorSize {
    if (CGSizeEqualToSize(_pageIndicatorSize, pageIndicatorSize)) {
        return;
    }
    _pageIndicatorSize = pageIndicatorSize;
    if (CGSizeEqualToSize(_currentPageIndicatorSize, CGSizeZero) || (_currentPageIndicatorSize.width < pageIndicatorSize.width && _currentPageIndicatorSize.height < pageIndicatorSize.height)) {
        _currentPageIndicatorSize = pageIndicatorSize;
    }
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setPageIndicatorSpaing:(CGFloat)pageIndicatorSpaing {
    _pageIndicatorSpaing = pageIndicatorSpaing;
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setCurrentPageIndicatorSize:(CGSize)currentPageIndicatorSize {
    if (CGSizeEqualToSize(_currentPageIndicatorSize, currentPageIndicatorSize)) {
        return;
    }
    _currentPageIndicatorSize = currentPageIndicatorSize;
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment {
    [super setContentVerticalAlignment:contentVerticalAlignment];
    if (_indicatorViews.count > 0) {
        [self setNeedsLayout];
    }
}

#pragma mark - update indicator

- (void)updateIndicatorViews {
    if (!self.superview && !_forceUpdate) {
        return;
    }
    if (_indicatorViews.count == _numberOfPages) {
        [self updateIndicatorViewsBehavior];
        return;
    }
    NSMutableArray *indicatorViews = _indicatorViews ? [_indicatorViews mutableCopy] :[NSMutableArray array];
    if (indicatorViews.count < _numberOfPages) {
        for (NSInteger idx = indicatorViews.count; idx < _numberOfPages; ++idx) {
            UIImageView *indicatorView = [[UIImageView alloc]init];
            indicatorView.contentMode = _indicatorImageContentMode;
            [self addSubview:indicatorView];
            [indicatorViews addObject:indicatorView];
        }
    }else if (indicatorViews.count > _numberOfPages) {
        for (NSInteger idx = indicatorViews.count - 1; idx >= _numberOfPages; --idx) {
            UIImageView *indicatorView = indicatorViews[idx];
            [indicatorView removeFromSuperview];
            [indicatorViews removeObjectAtIndex:idx];
        }
    }
    _indicatorViews = [indicatorViews copy];
    [self updateIndicatorViewsBehavior];
}

- (void)updateIndicatorViewsBehavior {
    if (_indicatorViews.count == 0 || (!self.superview && !_forceUpdate)) {
        return;
    }
    if (_hidesForSinglePage && _indicatorViews.count == 1) {
        UIImageView *indicatorView = _indicatorViews.lastObject;
        indicatorView.hidden = YES;
        return;
    }
    NSInteger index = 0;
    for (UIImageView *indicatorView in _indicatorViews) {
        if (_pageIndicatorImage) {
            indicatorView.contentMode = _indicatorImageContentMode;
            indicatorView.image = _currentPage == index ? _currentPageIndicatorImage : _pageIndicatorImage;
        }else {
            indicatorView.image = nil;
            indicatorView.backgroundColor = _currentPage == index ? _currentPageIndicatorTintColor : _pageIndicatorTintColor;
        }
        indicatorView.hidden = NO;
        ++index;
    }
}

#pragma mark - layout

- (void)layoutIndicatorViews {
    if (_indicatorViews.count == 0) {
        return;
    }
    CGFloat orignX = 0;
    CGFloat centerY = 0;
    CGFloat pageIndicatorSpaing = _pageIndicatorSpaing;
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentCenter:
            // ignore contentInset
            orignX = (CGRectGetWidth(self.frame) - (_indicatorViews.count - 1) * (_pageIndicatorSize.width + _pageIndicatorSpaing) - _pageIndicatorSize.width)/2;
            break;
        case UIControlContentHorizontalAlignmentLeft:
            orignX = _contentInset.left;
            break;
        case UIControlContentHorizontalAlignmentRight:
            orignX = CGRectGetWidth(self.frame) - ((_indicatorViews.count - 1) * (_pageIndicatorSize.width + _pageIndicatorSpaing) - _pageIndicatorSize.width) - _contentInset.right;
            break;
        case UIControlContentHorizontalAlignmentFill:
            orignX = _contentInset.left;
            if (_indicatorViews.count > 1) {
                pageIndicatorSpaing = (CGRectGetWidth(self.frame) - _contentInset.left - _contentInset.right - _pageIndicatorSize.width - (_indicatorViews.count - 1) * _pageIndicatorSize.width)/(_indicatorViews.count - 1);
            }
            break;
        default:
            break;
    }
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
            centerY = CGRectGetHeight(self.frame)/2;
            break;
        case UIControlContentVerticalAlignmentTop:
            centerY = _contentInset.top + _currentPageIndicatorSize.height/2;
            break;
        case UIControlContentVerticalAlignmentBottom:
            centerY = CGRectGetHeight(self.frame) - _currentPageIndicatorSize.height/2 - _contentInset.bottom;
            break;
        case UIControlContentVerticalAlignmentFill:
            centerY = (CGRectGetHeight(self.frame) - _contentInset.top - _contentInset.bottom)/2 + _contentInset.top;
            break;
        default:
            break;
    }
    NSInteger index = 0;
    for (UIImageView *indicatorView in _indicatorViews) {
        if (_pageIndicatorImage) {
            indicatorView.layer.cornerRadius = 0;
        }else {
            indicatorView.layer.cornerRadius = _currentPage == index ? _currentPageIndicatorSize.height/2 : _pageIndicatorSize.height/2;
        }
        CGSize size = index == _currentPage ? _currentPageIndicatorSize : _pageIndicatorSize;
        indicatorView.frame = CGRectMake(orignX - (size.width - _pageIndicatorSize.width)/2, centerY - size.height/2, size.width, size.height);
        orignX += _pageIndicatorSize.width + pageIndicatorSpaing;
        ++index;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutIndicatorViews];
}

@end

@interface YJSMenuItem()

/**
 单元格图片
 */
@property (strong, nonatomic) YYAnimatedImageView *itemImg;

/**
 单元格文本
 */
@property (strong, nonatomic) UILabel *itemTitle;

@end

@implementation YJSMenuItem

+ (void)initialize{
    YJSMenuItem *item = [self appearance];
    item.itemImgSize = CGSizeMake(kScale(40), kScale(40));
    item.itemImgCornerRadius = kScale(20);
    item.titleImgSpace = kScale(10);
    item.textColor = [UIColor darkTextColor];
    item.textFont = [UIFont systemFontOfSize:kScale(14)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.itemImg = ({
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = self.itemImgCornerRadius;
            imageView;
        });
        [self.contentView addSubview:self.itemImg];
        
        self.itemTitle = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = self.textColor;
            label.font = self.textFont;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label;
        });
        [self.contentView addSubview:self.itemTitle];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.itemImg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(self.itemImgSize));
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).offset(-2*self.titleImgSpace);
    }];
    
    [self.itemTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.top.equalTo(self.itemImg.mas_bottom).offset(self.titleImgSpace);
    }];
}

- (void)setItemImgSize:(CGSize)itemImgSize{
    if(itemImgSize.width > 0 && itemImgSize.height > 0){
        _itemImgSize = itemImgSize;
        [self layoutIfNeeded];
    }
}

- (void)setTitleImgSpace:(CGFloat)titleImgSpace{
    if(titleImgSpace > 0){
        _titleImgSpace = titleImgSpace;
        [self layoutIfNeeded];
    }
}

- (void)setItemImgCornerRadius:(CGFloat)itemImgCornerRadius{
    if(itemImgCornerRadius > 0){
        _itemImgCornerRadius = itemImgCornerRadius;
        [self layoutIfNeeded];
    }
}

- (void)setTextColor:(UIColor *)textColor{
    if(textColor){
        _textColor = textColor;
        self.itemTitle.textColor = textColor;
    }
}

- (void)setTextFont:(UIFont *)textFont{
    if(textFont){
        _textFont = textFont;
        self.itemTitle.font = textFont;
    }
}

#pragma mark - Identifier
+ (NSString *)identifier{
    return NSStringFromClass([self class]);
}

- (void)customizeItemWithObject:(id<YJSDataProtocol>)object{
    if(object == nil){
        return;
    }
    self.itemTitle.text = object.itemTitle;
    if([object.itemImage isKindOfClass:[UIImage class]]){
        self.itemImg.image = object.itemImage;
    }else if([object.itemImage isKindOfClass:[NSURL class]]){
        [self.itemImg yy_setImageWithURL:object.itemImage placeholder:object.itemPlaceholder];
    }else if([object.itemImage isKindOfClass:[NSString class]]){
        [self.itemImg yy_setImageWithURL:[NSURL URLWithString:object.itemImage] placeholder:object.itemPlaceholder];
    }else{
        self.itemImg.image = object.itemPlaceholder;
    }
}

- (void)setHighlighted:(BOOL)highlighted{
    if(highlighted){
        [UIView animateWithDuration:0.25 animations:^{
            self.itemImg.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.itemImg.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }
}

@end

@interface YJSScrollMenu()<UICollectionViewDelegate,UICollectionViewDataSource>

/**
 *  视图
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 *  布局
 */
@property (nonatomic, strong) YJSFlowLayout *flowLayout;

/**
 *  头
 */
@property (nonatomic, strong) UIView *header;

/**
 *  代理
 */
@property (nonatomic, weak) id<YJSScrollMenuDelegate> delegate;

/**
 *  数据源
 */
@property (nonatomic, weak) id<YJSScrollMenuDataSource> dataSource;

/**
 *  记录每个分区的位移量
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *offsetArray;

/**
 *  原始尺寸
 */
@property (nonatomic, assign) CGRect originFrame;

/**
 *  页眉高度
 */
@property (nonatomic, assign) CGFloat headerHeight;

/**
 *  分页控制器高度
 */
@property (nonatomic, assign) CGFloat pageControlHeight;

/**
 *  单元格尺寸
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 *  分页器总页数
 */
@property (nonatomic, assign) NSUInteger totalPages;

/**
 *  是否自动更新Frame
 */
@property (nonatomic, assign) BOOL automaticUpdateFrame;

@end

@implementation YJSScrollMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame delegate:(id)aDelegate{
    self = [super initWithFrame:frame];
    if(self){
        self.delegate = aDelegate;
        self.dataSource = aDelegate;
        self.originFrame = frame;
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI{
    self.backgroundColor = [UIColor whiteColor];
    self.popupLayoutType = PopupLayoutTypeNone;
    self.clipsToBounds = YES;
    self.flowLayout = ({
        YJSFlowLayout *flowLayout = [[YJSFlowLayout alloc] init];
        flowLayout.itemSize = self.itemSize;
        flowLayout;
    });
    
    self.collectionView = ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        [collectionView registerClass:[YJSMenuItem class] forCellWithReuseIdentifier:[YJSMenuItem identifier]];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView;
    });
    
    self.pageControl = ({
        YJSPageControl * pageControl = [[YJSPageControl alloc] initWithFrame:CGRectZero];
        pageControl.currentPageIndicatorTintColor = [UIColor darkTextColor];
        pageControl.pageIndicatorTintColor =  [UIColor groupTableViewBackgroundColor];
        pageControl.numberOfPages = self.totalPages;
        pageControl.currentPage = 0;
        [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
        pageControl;
    });
    
    self.header = ({
        UIView *header = [[UIView alloc] init];
        header.backgroundColor = [UIColor whiteColor];
        header.clipsToBounds = YES;
        header;
    });
    
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self addSubview:self.header];
    
    [self layoutHeaderInSection:0];
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    //页眉
    [self updateHeaderConstraints];
    
    //分页器
    [self.pageControl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self);
        make.height.mas_equalTo(self.pageControlHeight);
    }];
    //视图
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.pageControl.mas_top);
        make.top.mas_equalTo(self.header.mas_bottom);
    }];
}

/** 页眉约束 */
- (void)updateHeaderConstraints{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollMenu:headerInSection:)]) {
        [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(self);
            make.height.mas_equalTo(self.headerHeight);
        }];
    }else{
        //页眉
        [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(self);
            make.height.mas_equalTo(0);
        }];
    }
}

/** 页眉设置 */
- (void)layoutHeaderInSection:(NSUInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollMenu:headerInSection:)]) {
        [self.header.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIView* view =  [self.delegate scrollMenu:self headerInSection:section];
        view ? [self.header addSubview:view] : nil;
    }
}

#pragma mark - Getter&Setter
- (NSMutableArray<NSNumber *> *)offsetArray{
    if (_offsetArray == nil) {
        _offsetArray = [NSMutableArray array];
    }
    return _offsetArray;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    self.collectionView.backgroundColor = backgroundColor;
    self.header.backgroundColor = backgroundColor;
}

- (void)setBounces:(BOOL)bounces{
    _bounces = bounces;
    self.collectionView.bounces = bounces;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled{
    _pagingEnabled = pagingEnabled;
    self.collectionView.pagingEnabled = pagingEnabled;
}

/** 页眉高度 */
- (CGFloat)headerHeight{
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightOfHeaderInScrollMenu:)]) {
        return [self.delegate heightOfHeaderInScrollMenu:self];
    }
    return kScale(20);
}

/** 获取分页器高度 */
- (CGFloat)pageControlHeight{
    if (self.delegate && [self.delegate respondsToSelector:@selector(heightOfPageControlInScrollMenu:)]) {
        return [self.delegate heightOfPageControlInScrollMenu:self];
    }
    return kScale(15);
}

/** 获取单元格尺寸 */
- (CGSize)itemSize{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemSizeOfScrollMenu:)]) {
        return  [self.delegate itemSizeOfScrollMenu:self];
    }
    return CGSizeMake(kScale(40), kScale(70));
}

/** 获取分页器总页数 */
- (NSUInteger)totalPages{
    //视图尺寸
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height - self.pageControlHeight - self.headerHeight;
    //行列最大的单元格数量
    NSInteger xCount = width/self.itemSize.width;
    NSInteger yCount = height/self.itemSize.height;
    //单页的数量
    NSInteger allCount = xCount * yCount;
    //清除上次位移数据
    [self.offsetArray removeAllObjects];
    //总页数
    NSUInteger page = 0;
    for (NSUInteger idx = 0; idx < [self getNumberOfSections]; idx ++) {
        NSUInteger count = [self getNumberOfItemsInSection:idx];
        NSUInteger pageRe = (count%allCount == 0) ?  (count/allCount) :  (count/allCount)+1;
        page += pageRe;
        //记录section的最大位移量
        [self.offsetArray addObject:@(page * width)];
    }
    return page;
}

/** 是否调节Frame以自适应 */
- (BOOL)automaticUpdateFrame{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldAutomaticUpdateFrameInScrollMenu:)]) {
        return [self.delegate shouldAutomaticUpdateFrameInScrollMenu:self];
    }
    return NO;
}

/** 获取分区个数 */
- (NSUInteger)getNumberOfSections{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSectionsInScrollMenu:)]) {
        return [self.dataSource numberOfSectionsInScrollMenu:self];
    }
    return 1;
}

/** 获取单个分区的单元格数 */
- (NSUInteger)getNumberOfItemsInSection:(NSInteger)section{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(scrollMenu:numberOfItemsInSection:)]) {
        return [self.dataSource scrollMenu:self numberOfItemsInSection:section];
    }
    return 0;
}

/** 获取多余的高度 */
- (CGFloat)getRedundantHeight{
    //视图尺寸
    CGFloat width = self.originFrame.size.width;
    CGFloat height = self.originFrame.size.height - self.pageControlHeight - self.headerHeight;
    //行列最大的单元格数量
    NSInteger xCount = width/self.itemSize.width;
    NSInteger yCount = height/self.itemSize.height;
    
    //单页的数量
    NSInteger allCount = xCount * yCount;
    
    //最小高度
    CGFloat lineNumber = 0;
    
    for (NSUInteger idx = 0; idx < [self getNumberOfSections]; idx ++) {
        NSUInteger count = [self getNumberOfItemsInSection:idx];
        if (count/allCount >= 1.f) {
            return 0;
        }else{
            NSInteger number = (count%xCount == 0) ?  (count/xCount) :  (count/xCount)+1;
            if (number > lineNumber) {
                lineNumber = number;
            }
        }
    }
    CGFloat redundantHeight = (yCount - lineNumber)*self.itemSize.height;
    return redundantHeight;
}

- (void)animateCollection{
    NSArray *cells = self.collectionView.visibleCells;
    CGFloat collectionHeight = self.collectionView.bounds.size.height;
    CGFloat collectionWidth = self.collectionView.bounds.size.width;
    
    switch (self.popupLayoutType) {
        case PopupLayoutTypeTop:{
            for (UICollectionViewCell *cell in cells.objectEnumerator) {
                cell.alpha = 1.0f;
                cell.transform = CGAffineTransformMakeTranslation(0, -collectionHeight);
                NSUInteger index = [cells indexOfObject:cell];
                [UIView animateWithDuration:0.7f delay:0.05*index usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
                    cell.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:nil];
            }
            break;
        }
            
        case PopupLayoutTypeLeft:{
            for (UICollectionViewCell *cell in cells.objectEnumerator) {
                cell.alpha = 1.0f;
                cell.transform = CGAffineTransformMakeTranslation(-collectionWidth, 0);
                NSUInteger index = [cells indexOfObject:cell];
                [UIView animateWithDuration:0.7f delay:0.05*index usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
                    cell.transform =  CGAffineTransformMakeTranslation(0, 0);
                } completion:nil];
            }
            break;
        }
            
        case PopupLayoutTypeBottom:{
            for (UICollectionViewCell *cell in cells.objectEnumerator) {
                cell.alpha = 1.0f;
                cell.transform = CGAffineTransformMakeTranslation(0, collectionHeight);
                NSUInteger index = [cells indexOfObject:cell];
                [UIView animateWithDuration:0.7f delay:0.05*index usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
                    cell.transform =  CGAffineTransformMakeTranslation(0, 0);
                } completion:nil];
            }
            break;
        }
            
        case PopupLayoutTypeRight:{
            for (UICollectionViewCell *cell in cells.objectEnumerator) {
                cell.alpha = 1.0f;
                cell.transform = CGAffineTransformMakeTranslation(collectionWidth, 0);
                NSUInteger index = [cells indexOfObject:cell];
                [UIView animateWithDuration:0.7f delay:0.05*index usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
                    cell.transform =  CGAffineTransformMakeTranslation(0, 0);
                } completion:nil];
            }
            break;
        }
            
        case PopupLayoutTypeCenter:{
            for (UICollectionViewCell *cell in cells.objectEnumerator) {
                cell.alpha = 1.0f;
                cell.transform = CGAffineTransformMakeScale(0.9, 0.9);
                [UIView animateWithDuration:0.7f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{
                    cell.transform =  CGAffineTransformMakeScale(1.0, 1.0);
                } completion:nil];
                
            }
            break;
        }
            
        case PopupLayoutTypeNone:{
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - PageCotrolTurn
- (void)pageTurn:(UIPageControl*)sender{
    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
    [self changeHeaderInMenuContentOffset:rect.origin.x];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [self.pageControl setCurrentPage:offset.x / bounds.size.width];
    [self changeHeaderInMenuContentOffset:offset.x];
}

#pragma mark - Section
- (void)changeHeaderInMenuContentOffset:(CGFloat)offset{
    for (int idx = 0; idx < self.offsetArray.count; idx ++) {
        CGFloat currentOffset = offset + self.collectionView.frame.size.width;
        CGFloat theOffset = [self.offsetArray[idx] floatValue];
        if (currentOffset <= theOffset) {
            [self layoutHeaderInSection:idx];
            return;
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self getNumberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self getNumberOfSections];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YJSMenuItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:[YJSMenuItem identifier] forIndexPath:indexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(scrollMenu:objectAtIndexPath:)]) {
        id<YJSDataProtocol> object = [self.dataSource scrollMenu:self objectAtIndexPath:indexPath];
        [item customizeItemWithObject:object];
    }
    return item;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollMenu:didSelectItemAtIndexPath:)]) {
        [self.delegate scrollMenu:self didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark - Public
- (void)updateFrame{
    CGRect frame = self.originFrame;
    frame.size.height -= [self getRedundantHeight];
    self.frame = frame;
}

- (void)reloadData{
    self.flowLayout.itemSize = self.itemSize;
    self.automaticUpdateFrame ? [self updateFrame] : nil;
    self.pageControl.hidden = (self.totalPages == 1);
    self.pageControl.numberOfPages = self.totalPages;
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self animateCollection];
    [self changeHeaderInMenuContentOffset:self.pageControl.currentPage * self.collectionView.frame.size.width];
}

@end

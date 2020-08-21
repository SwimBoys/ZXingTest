//
//  XLSlideSegment.m
//  SlideSwitchTest
//
//  Created by MengXianLiang on 2017/4/28.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import "XLSlideSegmented.h"
#import "XLSlideSegmentedItem.h"


//最大放大倍数
static const CGFloat ItemMaxScale = 1;

@interface XLSlideSegmented ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    //标题底部阴影
    UIView *_shadow;
    //item间隔
    CGFloat _itemMargin;
    NSArray *_nums;
    CGFloat _beyondWidth; //标题过少时多出得width
}
@end

@implementation XLSlideSegmented

+ (CGFloat)itemFontSize {
    return 15.0f;
}
- (instancetype)init {
    if (self = [super init]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        _itemMargin = (UIScreen.mainScreen.bounds.size.width - 90*4)/12;
    } else {
        _itemMargin = (UIScreen.mainScreen.bounds.size.width - 65*4)/12;
    }
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:[UIView new]];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[XLSlideSegmentedItem class] forCellWithReuseIdentifier:@"XLSlideSegmentedItem"];
    _collectionView.showsHorizontalScrollIndicator = false;
    [self addSubview:_collectionView];
    
    _shadow = [[UIView alloc] init];
    _shadow.layer.cornerRadius = 1.0;
    [_collectionView addSubview:_shadow];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_moreButton) {
        CGFloat buttonWidth = self.bounds.size.height;
        CGFloat collectinWidth = self.bounds.size.width - buttonWidth;
        _moreButton.frame = CGRectMake(collectinWidth, 0, buttonWidth, buttonWidth);
        _collectionView.frame = CGRectMake(0, 0, collectinWidth, self.bounds.size.height);
    }else{
        _collectionView.frame = self.bounds;
    }
    //如果标题过少 自动居中
    [_collectionView performBatchUpdates:nil completion:^(BOOL finished) {
        if (self->_collectionView.contentSize.width < self->_collectionView.bounds.size.width) {
            
            if (self.isBounseEaqual) {
                CGFloat insetWidth = (self->_collectionView.bounds.size.width - self->_collectionView.contentSize.width);
                self->_beyondWidth = insetWidth/self.titles.count;
            }else {
                CGFloat insetX = (self->_collectionView.bounds.size.width - self->_collectionView.contentSize.width)/2.0f;
                self->_collectionView.contentInset = UIEdgeInsetsMake(0, insetX, 0, insetX);
            }
        }
        
        self.selectedIndex = self -> _selectedIndex;
        
    }];
    //设置阴影
    _shadow.backgroundColor = _itemSelectedColor;
}

#pragma mark -
#pragma mark Setter
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    _selectedIndex = selectedIndex;
    
    //更新阴影位置（延迟是为了避免cell不在屏幕上显示时，造成的获取frame失败问题）
    CGFloat rectX = [self shadowRectOfIndex:_selectedIndex].origin.x;
    if (rectX <= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            self->_shadow.frame = [self shadowRectOfIndex:self->_selectedIndex];
        });
    }else{
        _shadow.frame = [self shadowRectOfIndex:_selectedIndex];
    }
    
    //居中滚动标题
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    
    //更新字体大小
    [_collectionView reloadData];
    
    //执行代理方法
    if ([_delegate respondsToSelector:@selector(slideSegmentDidSelectedAtIndex:)]) {
        [_delegate slideSegmentDidSelectedAtIndex:_selectedIndex];
    }
}

- (void)setShowTitlesInNavBar:(BOOL)showTitlesInNavBar {
    _showTitlesInNavBar = showTitlesInNavBar;
    self.backgroundColor = [UIColor clearColor];
    _hideBottomLine = true;
    _hideShadow = true;
}

//更新阴影位置
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    //如果手动点击则不执行以下动画
    if (_ignoreAnimation) {return;}
    //更新阴影位置
    [self updateShadowPosition:progress];
    //更新标题颜色、大小
    [self updateItem:progress];
}

- (void)setCustomTitleSpacing:(CGFloat)customTitleSpacing {
    _customTitleSpacing = customTitleSpacing;
    [_collectionView reloadData];

}

- (void)setMoreButton:(UIButton *)moreButton {
    _moreButton = moreButton;
    [self addSubview:moreButton];
}

#pragma mark -
#pragma mark 执行阴影过渡动画
//更新阴影位置
- (void)updateShadowPosition:(CGFloat)progress {
    
    //progress > 1 向左滑动表格反之向右滑动表格
    NSInteger nextIndex = progress > 1 ? _selectedIndex + 1 : _selectedIndex - 1;
    if (nextIndex < 0 || nextIndex == _titles.count) {return;}
    //获取当前阴影位置
    CGRect currentRect = [self shadowRectOfIndex:_selectedIndex];
    CGRect nextRect = [self shadowRectOfIndex:nextIndex];
    //如果在此时cell不在屏幕上 则不显示动画
    if (CGRectGetMinX(currentRect) <= 0 || CGRectGetMinX(nextRect) <= 0) {return;}
    
    progress = progress > 1 ? progress - 1 : 1 - progress;
    
    //更新宽度
    CGFloat width = currentRect.size.width + progress*(nextRect.size.width - currentRect.size.width);
    CGRect bounds = _shadow.bounds;
    bounds.size.width = width;
    _shadow.bounds = bounds;
    
    //更新位置
    CGFloat distance = CGRectGetMidX(nextRect) - CGRectGetMidX(currentRect);
    _shadow.center = CGPointMake(CGRectGetMidX(currentRect) + progress* distance, _shadow.center.y);
}

//更新标题颜色
- (void)updateItem:(CGFloat)progress {
    
    NSInteger nextIndex = progress > 1 ? _selectedIndex + 1 : _selectedIndex - 1;
    if (nextIndex < 0 || nextIndex == _titles.count) {return;}
    
    XLSlideSegmentedItem *currentItem = (XLSlideSegmentedItem *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
    XLSlideSegmentedItem *nextItem = (XLSlideSegmentedItem *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
    progress = progress > 1 ? progress - 1 : 1 - progress;
    
    //更新颜色
    currentItem.textLabel.textColor = [self transformFromColor:_itemSelectedColor toColor:_itemNormalColor progress:progress];
    nextItem.textLabel.textColor = [self transformFromColor:_itemNormalColor toColor:_itemSelectedColor progress:progress];
    
    //更新放大
    CGFloat currentItemScale = ItemMaxScale - (ItemMaxScale - 1) * progress;
    CGFloat nextItemScale = 1 + (ItemMaxScale - 1) * progress;
    currentItem.transform = CGAffineTransformMakeScale(currentItemScale, currentItemScale);
    nextItem.transform = CGAffineTransformMakeScale(nextItemScale, nextItemScale);
}

#pragma mark -
#pragma mark CollectionViewDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (_customTitleSpacing) {
        return _customTitleSpacing;
    }
    return _itemMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (_customTitleSpacing) {
        return _customTitleSpacing;
    }
    return _itemMargin;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self itemWidthOfIndexPath:indexPath] + _itemMargin * 2 + _beyondWidth, _collectionView.bounds.size.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XLSlideSegmentedItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:@"XLSlideSegmentedItem" forIndexPath:indexPath];
    SlideModel *model = _titles[indexPath.row];
    [item setModel:model];
    
    CGFloat scale = indexPath.row == _selectedIndex ? ItemMaxScale : 1;
    item.transform = CGAffineTransformMakeScale(scale, scale);

    item.textLabel.textColor = indexPath.row == _selectedIndex ? _itemSelectedColor : _itemNormalColor;
    return item;
}

//获取文字宽度
- (CGFloat)itemWidthOfIndexPath:(NSIndexPath*)indexPath {
    
    SlideModel *model = _titles[indexPath.row];
    NSString *title = model.title;
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont boldSystemFontOfSize:XLSlideSegmented.itemFontSize], NSParagraphStyleAttributeName : style };
    CGSize textSize = [title boundingRectWithSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)
                                          options:opts
                                       attributes:attributes
                                          context:nil].size;
    return textSize.width;
}


- (CGRect)shadowRectOfIndex:(NSInteger)index {
    return CGRectMake([_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].frame.origin.x + _itemMargin + _beyondWidth/2.0, self.bounds.size.height - 3, [self itemWidthOfIndexPath:[NSIndexPath indexPathForRow:index inSection:0]], 3);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    _ignoreAnimation = true;
}

#pragma mark -
#pragma mark 功能性方法
- (UIColor *)transformFromColor:(UIColor*)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress {
    
    if (!fromColor || !toColor) {
        return [UIColor blackColor];
    }
    
    progress = progress >= 1 ? 1 : progress;
    
    progress = progress <= 0 ? 0 : progress;
    
    const CGFloat * fromeComponents = CGColorGetComponents(fromColor.CGColor);

    const CGFloat * toComponents = CGColorGetComponents(toColor.CGColor);
    
    size_t  fromColorNumber = CGColorGetNumberOfComponents(fromColor.CGColor);
    size_t  toColorNumber = CGColorGetNumberOfComponents(toColor.CGColor);
    
    if (fromColorNumber == 2) {
        CGFloat white = fromeComponents[0];
        fromColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        fromeComponents = CGColorGetComponents(fromColor.CGColor);
    }
    
    if (toColorNumber == 2) {
        CGFloat white = toComponents[0];
        toColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        toComponents = CGColorGetComponents(toColor.CGColor);
    }
    
    CGFloat red = fromeComponents[0]*(1 - progress) + toComponents[0]*progress;
    CGFloat green = fromeComponents[1]*(1 - progress) + toComponents[1]*progress;
    CGFloat blue = fromeComponents[2]*(1 - progress) + toComponents[2]*progress;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}


@end

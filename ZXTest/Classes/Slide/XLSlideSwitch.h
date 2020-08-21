//
//  XLSlideSwitch.h
//  SlideSwitchTest
//
//  Created by MengXianLiang on 2017/4/28.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLSlideSwitchDelegate.h"
#import "SlideModel.h"

@interface XLSlideSwitch : UIView

/**
 * 需要显示的视图
 */
@property (nonatomic, strong) NSArray *viewControllers;
/**
 * 标题
 */
@property (nonatomic, strong) NSArray *titles;

/**
 * 选中位置
 */
@property (nonatomic, assign) NSInteger selectedIndex;
/**
 * 选中控制器
 */
@property (nonatomic, strong, readonly) UIViewController* selectedVc;
/**
 * 按钮正常时的颜色
 */
@property (nonatomic, strong) UIColor *itemNormalColor;
/**
 * 按钮选中时的颜色
 */
@property (nonatomic, strong) UIColor *itemSelectedColor;
/**
 * 隐藏阴影
 */
@property (nonatomic, assign) BOOL hideShadow;
/**
 隐藏底部分割线
 */
@property (nonatomic, assign) BOOL hideBottomLine;
/**
 * 用户自定义标题间距
 */
@property (nonatomic, assign) CGFloat customTitleSpacing;

/**
 * 更多按钮
 */
@property (nonatomic, strong) UIButton *moreButton;

/**
 * segm标题较少时
 * YES——屏幕平分，NO——居中(默认)
 */
@property (nonatomic, assign) BOOL isBounseEaqual;
/**
 * YES——允许滚动(默认)， NO禁止滚动
 */
@property (nonatomic, assign) BOOL scrollEnable;

/**
 * 代理方法
 */
@property (nonatomic, weak) id <XLSlideSwitchDelegate>delegate;
/**
 * 初始化方法
 */
-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray <SlideModel *>*)titles viewControllers:(NSArray <UIViewController *>*)viewControllers;
/**
 * 标题显示在ViewController中
 */
-(void)showInViewController:(UIViewController *)viewController;
/**
 * 标题显示在NavigationBar中
 */
-(void)showInNavigationController:(UINavigationController *)navigationController;
/**
 * 标题红点显示个数
 */
-(void)showUnDoneNum:(NSInteger)num index:(NSInteger )index;

/**
 * 显示标志icon
 * icon: 本地图片名称
  * index: 标题下标
 */
-(void)showIcon:(NSString *)icon index:(NSInteger)index;
/**
 * 显示标志默认icon
 * index: 标题下标
 */
-(void)showIconIndex:(NSInteger)index;
/**
 * 隐藏标志icon
 * index: 标题下标
 */
-(void)hideIconIndex:(NSInteger)index;
    
@end

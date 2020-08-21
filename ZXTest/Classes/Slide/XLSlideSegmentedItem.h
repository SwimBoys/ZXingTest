//
//  XLSlideSegmentItem.h
//  SlideSwitchTest
//
//  Created by MengXianLiang on 2017/4/28.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideModel.h"
@interface XLSlideSegmentedItem : UICollectionViewCell

@property (nonatomic, copy) UILabel *textLabel;

- (void)setModel:(SlideModel *)num;

@end

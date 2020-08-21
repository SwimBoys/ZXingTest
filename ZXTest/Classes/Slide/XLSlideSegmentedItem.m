//
//  XLSlideSegmentItem.m
//  SlideSwitchTest
//
//  Created by MengXianLiang on 2017/4/28.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import "XLSlideSegmentedItem.h"
#import "XLSlideSegmented.h"
@interface XLSlideSegmentedItem ()
{
    UILabel *_numLabel;
    UIImageView *_icon;
}
@end

@implementation XLSlideSegmentedItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    _textLabel = [[UILabel alloc] init];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [UIFont systemFontOfSize:XLSlideSegmented.itemFontSize];
    [self.contentView addSubview:_textLabel];

    _numLabel = [[UILabel alloc] init];
    _numLabel.font = [UIFont systemFontOfSize:10];
    CGFloat r = 243.0/255;
    CGFloat g = 56.0/255;
    CGFloat b = 66.0/255;
    
    _numLabel.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
    _numLabel.textColor = UIColor.whiteColor;
    _numLabel.textAlignment = NSTextAlignmentCenter;
    _numLabel.layer.cornerRadius = 7.5;
    _numLabel.layer.masksToBounds = YES;
    _numLabel.hidden = YES;
    [self.contentView addSubview:_numLabel];
    
    //标题icon
    _icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor clearColor];
    _icon.alpha = 0;
    [self.contentView addSubview:_icon];
}

- (void)setModel:(SlideModel *)model {
    _textLabel.text = model.title;
    if (model.num > 0) {
        _numLabel.text =  [[NSString alloc] initWithFormat:@"%ld",(long)model.num ];
        _numLabel.hidden = NO;
    } else {
        _numLabel.hidden = YES;
    }
    
    if (model.icon && [model.icon length]>0 && [[model.icon stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]>0) {
        UIImage *image = [UIImage imageNamed:model.icon];
        _icon.image = image;
        _icon.alpha = 1.0;
    }else {
        _icon.alpha = 0.0;
    }
    [self updateLabelFrame];
}

- (void) updateLabelFrame {
    _numLabel.frame = CGRectMake(0, 2, [self textWidth: _numLabel.text], 15);
    _numLabel.center = CGPointMake(self.bounds.size.width/2 + 25, 15);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
    _numLabel.frame = CGRectMake(0, 2, [self textWidth: _numLabel.text], 15);
    _numLabel.center = CGPointMake(self.bounds.size.width/2 + 25, 15);
    _icon.frame = CGRectMake(0, 0, 11, 9);
    _icon.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height-4.5-6);
}

- (CGFloat) textWidth: (NSString *)text {
    if (text.length == 0 || text == nil) {
        return 0;
    }
    switch (text.length) {
        case 1:
            return 16;
        case 2:
            return 21;
        case 3:
            return 26;
        default:
            return 31;
    }
}

@end

//
//  CDUnionFilterView.m
//  MedicalCircle
//
//  Created by xzm on 2019/5/17.
//  Copyright © 2019 Dachen Tech. All rights reserved.
//

#import "CDFilterTitleView.h"

@interface CDUnionFilterItem : UIControl
{
    UILabel *_label;
    UIImageView *_imgView;
    UIView *_line;
}

@property (nonatomic,assign) BOOL select;
@property (nonatomic,strong) NSString * title;

- (void)hiddenLine;

@end

@implementation CDUnionFilterItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [UILabel new];
        _label.font = [UIFont systemFontOfSize:14];
        [self addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.centerX.equalTo(self).offset(-7);
            make.width.mas_lessThanOrEqualTo(self.frame.size.width-55);
        }];
        
        _imgView = [UIImageView new];
        [self addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self->_label.mas_right).offset(4);
        }];
        
        _line = [UIView new];
        _line.backgroundColor = RGBA(234, 234, 234, 1);
        [self addSubview:_line];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(1, 12));
        }];
        
        self.select = NO;
    }
    return self;
}

- (void)setSelect:(BOOL)select
{
    _select = select;
    _imgView.image = [UIImage imageNamed:select ? @"cd_union_filter_up" : @"cd_union_filter_down"];
    _label.textColor = select ? RGBA(37, 148, 255, 1) : RGBA(102, 102, 102, 1);
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _label.text = title;
}

- (void)hiddenLine
{
    _line.hidden = YES;
}

@end

@implementation CDFilterTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setTextArray:(NSArray *)textArray
{
    NSInteger count = textArray.count;
    CGFloat w = SCREENWIDTH/count;
   
    while (count > self.subviews.count) {
        CDUnionFilterItem *item = [[CDUnionFilterItem alloc]initWithFrame:CGRectMake(0, 0, w, 44)];
        [item addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
    }
    
    for (int i = 0; i < self.subviews.count; i ++) {
        CDUnionFilterItem *item = self.subviews[i];
        item.tag = 100 + i;
        if (i < count) {
            NSString *text = textArray[i];
            [item setTitle:text];
            CGRect frame = item.frame;
            frame.origin.x = w*i;
            item.frame = frame;
            item.hidden = NO;
            if (i == count - 1) [item hiddenLine];
        } else {
            item.hidden = YES;
        }
    }
}

- (void)itemAction:(CDUnionFilterItem *)item
{
    for (CDUnionFilterItem *subItem in self.subviews) {
        if (subItem == item) {
            subItem.select = !subItem.select;
        } else {
            subItem.select = NO;
        }
    }
    !_itemClick ?: _itemClick(item.tag-100,item.select);
}

- (void)select:(BOOL)select index:(NSInteger)index
{
    for (int i = 0; i < self.subviews.count; i ++) {
        CDUnionFilterItem *item = self.subviews[i];
        if (i == index) {
            item.select = select;
        } else {
            item.select = NO;
        }
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(SCREENWIDTH, 44);
}

@end

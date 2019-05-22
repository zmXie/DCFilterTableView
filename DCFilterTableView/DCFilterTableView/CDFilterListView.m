//
//  CDFilterListView.m
//  MedicalCircle
//
//  Created by xzm on 2019/5/20.
//  Copyright © 2019 Dachen Tech. All rights reserved.
//

#import "CDFilterListView.h"

#define KTag 2000

@interface CDFilterListView () <UITableViewDelegate,UITableViewDataSource>
{
    UIStackView *_stack;
    NSMutableDictionary *_selectDic;
}

@end

#define KHeight self.frame.size.height*0.7

@implementation CDFilterListView

#pragma mark - Publish Method
- (void)setDataInfo:(NSMutableDictionary *)dataInfo
{
    if (![dataInfo respondsToSelector:@selector(setObject:forKey:)]) {
        dataInfo = dataInfo.mutableCopy;
    }
    _dataInfo = dataInfo;
    _selectDic = @{}.mutableCopy;
    [self configData];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.clipsToBounds = YES;
    self.backgroundColor = RGBA(0, 0, 0, 0.3);
    [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    _stack = [[NSClassFromString(@"UIStackView") alloc] initWithFrame:CGRectMake(0, -KHeight, self.frame.size.width, KHeight)];
    _stack.axis = UILayoutConstraintAxisHorizontal;
    _stack.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:_stack];

    CGFloat colorLevel = 7;
    for (int i = 0; i < dataInfo.allKeys.count; i ++) {
        UITableView *tb = [UITableView new];
        tb.delegate = self;
        tb.dataSource = self;
        tb.separatorStyle = 0;
        tb.tableFooterView = [UIView new];
        tb.tag = KTag+i;
        CGFloat value = 255-colorLevel*i;
        tb.backgroundColor = RGBA(value, value, value,1);
        [_stack addArrangedSubview:tb];
    }
}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    [view addSubview:self];
    void (^show)(void) = ^{
        self.backgroundColor = RGBA(0, 0, 0, 0.3);
        CGRect frame = self->_stack.frame;
        frame.origin.y = 0;
        self->_stack.frame = frame;
    };
    if (animated) {
        [UIView animateWithDuration:0.2 animations:show];
    } else {
        show();
    }
    _isShow = YES;
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor clearColor];
        CGRect frame = self->_stack.frame;
        frame.origin.y = -KHeight;
        self->_stack.frame = frame;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
        self->_isShow = NO;
        !self->_selectCompleteBlock?:self->_selectCompleteBlock(self->_selectDic);
    }];
}

#pragma mark - Privite Method
- (void)configData
{
    //设置选中
    void (^setSelectDic)(NSArray *,NSString *) = ^(NSArray *array,NSString *key){
        for (NSDictionary *dic in array) {
            if ([[dic objectForKey:KSelect] boolValue]) {
                [self->_selectDic setObject:dic forKey:key];
                continue;
            }
        }
    };
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self->_dataInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSArray class]]) { //一级
                if (![obj respondsToSelector:@selector(addObject:)]) {
                    [self->_dataInfo setObject:[obj mutableCopy] forKey:key];
                }
                setSelectDic(obj,key);
            } else { //依赖级
                if (![obj respondsToSelector:@selector(setObject:forKey:)]) {
                    [self->_dataInfo setObject:[obj mutableCopy] forKey:key];
                }
                [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull skey, id  _Nonnull sobj, BOOL * _Nonnull stop) {
                    setSelectDic(sobj,key);
                }];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_stack.arrangedSubviews makeObjectsPerformSelector:@selector(reloadData)];
        });
    });
}

- (NSMutableArray *)dataWithTableView:(UITableView *)tableView
{
    int index = (int)tableView.tag - KTag;
    if (index == 0) { //一级
        NSMutableArray *dataArray = [self.dataInfo objectForKey:KListKey(index)];
        return dataArray;
    } else { //依赖级
        NSString *relyKey = KListKey(index-1);
        NSDictionary *replyDic = [_selectDic objectForKey:relyKey];
        NSMutableDictionary *dataDic = [self.dataInfo objectForKey:KListKey(index)];
        NSMutableArray *dataArray = [dataDic objectForKey:replyDic[KRely]];
        return dataArray;
    }
}

- (NSArray<UITableView *>*)nextTableViews:(UITableView *)tableView
{
    NSMutableArray *tArray = @[].mutableCopy;
    int index = (int)tableView.tag - KTag;
    index ++;
    for (int i = index; i < _stack.arrangedSubviews.count; i ++) {
        UITableView *tb = _stack.arrangedSubviews[i];
        [tArray addObject:tb];
    }
    return tArray;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dataArray = [self dataWithTableView:tableView];
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = 0;
        cell.backgroundColor = tableView.backgroundColor;
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cd_union_filter_tick"]];
        cell.accessoryView = imgView;
    }
    NSArray *dataArray = [self dataWithTableView:tableView];
    NSDictionary *dic = dataArray.count > indexPath.row ? dataArray[indexPath.row] : nil;
    cell.textLabel.text = dic[@"name"];
    BOOL select = [dic[KSelect] boolValue];
    cell.accessoryView.hidden = !(select && [self nextTableViews:tableView].count == 0);
    cell.textLabel.textColor = select ? RGBA(37, 148, 255,1) : RGBA(23, 23, 23,1);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *dataArray = [self dataWithTableView:tableView];
    NSMutableDictionary *dic = dataArray[indexPath.row];
    for (NSMutableDictionary *mDic in dataArray) {
        [mDic setObject:@(mDic == dic ? YES : NO) forKey:KSelect];
    }
    //添加选中
    int index = (int)tableView.tag - KTag;
    [_selectDic setValue:dic forKey:KListKey(index)];
    //刷新
    [tableView reloadData];
    NSArray *nextTbArray = [self nextTableViews:tableView];
    if (nextTbArray.count > 0) {
        for (UITableView *tb in nextTbArray) {
            int index = (int)tb.tag - KTag;
            NSMutableDictionary *mDic = [_selectDic objectForKey:KListKey(index)];
            [mDic setObject:@(NO) forKey:KSelect];
            [_selectDic removeObjectForKey:KListKey(index)];
            [tb reloadData];
        }
    } else {
        [self dismiss];
    }
    !_changeSelectBlock ?:_changeSelectBlock(_selectDic,dic[@"name"]);
}

@end

//
//  CDFilterListView.h
//  MedicalCircle
//
//  Created by xzm on 2019/5/20.
//  Copyright © 2019 Dachen Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KListKey(index) [NSString stringWithFormat:@"list%d",index]
#define KSelect @"select"
#define KRely @"rely"

/**
 多级筛选列表视图
 */
@interface CDFilterListView : UIControl

/**
 @{@"list0":@[@{@"name":@"",@"rely":@"",...},@{}],
   @"list1":@{@"上一级的rely字段":@[@{@"name":...}],...}],
   ...
  数据源，key的数量决定层级数，下一级的数据依赖于上一级选中的数据
 }
 */
@property (nonatomic,strong) NSMutableDictionary * dataInfo;
@property (nonatomic,  copy) void (^changeSelectBlock)(NSDictionary *selectDic,NSString *name);
@property (nonatomic,  copy) void (^selectCompleteBlock)(NSDictionary *selectDic);
@property (nonatomic,assign,readonly) BOOL isShow;

- (void)showInView:(UIView *)view animated:(BOOL)animated;

- (void)dismiss;

@end

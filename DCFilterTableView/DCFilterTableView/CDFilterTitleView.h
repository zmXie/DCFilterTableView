//
//  CDUnionFilterView.h
//  MedicalCircle
//
//  Created by xzm on 2019/5/17.
//  Copyright © 2019 Dachen Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 筛选标题视图
 */
@interface CDFilterTitleView : UIView

@property (nonatomic,  copy) void (^itemClick)(NSInteger index,BOOL select);

- (void)setTextArray:(NSArray <NSString *>*)textArray;

- (void)select:(BOOL)select index:(NSInteger)index;

@end

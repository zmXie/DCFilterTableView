//
//  ViewController.m
//  DCFilterTableView
//
//  Created by 谢志敏 on 2019/5/19.
//  Copyright © 2019年 谢志敏. All rights reserved.
//

#import "ViewController.h"
#import "CDFilterListView.h"
#import "CDFilterTitleView.h"
#import "CDFilterModel.h"

@interface ViewController ()
{
    NSMutableArray *_filterTitleArray;
    NSMutableDictionary *_deptFilterDic;
    NSMutableDictionary *_areaFilterDic;
    NSMutableDictionary *_levelFilterDic;
}

@property (nonatomic,strong) CDFilterTitleView * filterTitleView;
@property (nonatomic,strong) CDFilterListView  * filterListView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filterTitleArray = @[@"科室",@"地区",@"医院等级"].mutableCopy;
    _deptFilterDic = [CDFilterModel getDeptDicExample];
    _areaFilterDic = [CDFilterModel getAreaDicExample];
    _levelFilterDic = [CDFilterModel getLevelDicExample];
    
    [self.view addSubview:self.filterTitleView];
    [self.filterTitleView setTextArray:_filterTitleArray];
}

#pragma mark - Action
- (void)filterActionWithIndex:(NSInteger)index select:(BOOL)select
{
    if (!select) {
        [self.filterListView dismiss];
        return;
    }
    CGRect f = self.filterTitleView.frame;
    CGFloat top = f.size.height + f.origin.y;
    self.filterListView.frame = CGRectMake(0, top, SCREENWIDTH, self.view.bounds.size.height - top);
    if (index == 0) {
        self.filterListView.dataInfo = self->_deptFilterDic;
    } else if (index == 1) {
        self.filterListView.dataInfo = self->_areaFilterDic;
    } else if (index == 2) {
        self.filterListView.dataInfo = self->_levelFilterDic;
    }
    __weak typeof (self) weakSelf = self;
    self.filterListView.changeSelectBlock = ^(NSDictionary *selectDic,NSString *name) {
        __strong typeof (self) strongSelf = weakSelf;
        [strongSelf->_filterTitleArray replaceObjectAtIndex:index withObject:name];
        [strongSelf.filterTitleView setTextArray:strongSelf->_filterTitleArray];
        NSLog(@"选中数据:%@",name);
    };
    self.filterListView.selectCompleteBlock = ^(NSDictionary *selectDic) {
        [weakSelf.filterTitleView select:NO index:index];
        NSLog(@"选则完成:%@",selectDic);
    };
    [self.filterListView showInView:self.view animated:!self.filterListView.isShow];
}

#pragma mark - Lazzy
- (CDFilterTitleView *)filterTitleView
{
    if (!_filterTitleView) {
        _filterTitleView = [[CDFilterTitleView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, SCREENWIDTH, 44)];
        __weak typeof (self) weakSelf = self;
        _filterTitleView.itemClick = ^(NSInteger index,BOOL select) {
            [weakSelf filterActionWithIndex:index select:select];
        };
    }
    return _filterTitleView;
}

- (CDFilterListView *)filterListView
{
    if (!_filterListView) {
        _filterListView = [CDFilterListView new];
    }
    return _filterListView;
}


@end

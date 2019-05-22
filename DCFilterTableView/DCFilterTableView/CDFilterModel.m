//
//  CDFilterModel.m
//  MedicalCircle
//
//  Created by xzm on 2019/5/20.
//  Copyright © 2019 Dachen Tech. All rights reserved.
//

#import "CDFilterModel.h"
#import "CDFilterListView.h"

static NSString * const CDFilterDeptKey  = @"CDFilter_DeptKey";
static NSString * const CDFilterAreaKey  = @"CDFilter_AreaKey";
static NSString * const CDFilterLevelKey = @"CDFilter_LevelKey";

@implementation CDFilterModel

+ (void)requestFilter
{
    [self requestDeptFilter];
    [self requestAreaFilter];
    [self requestLevelFilter];
}

//科室筛选数据
+ (void)requestDeptFilter
{
    void (^getData) (id) = ^(id responseObject) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableDictionary *deptFilterDic = @{}.mutableCopy;
            NSMutableArray *fArray = @[].mutableCopy; //一级数组
            NSMutableDictionary *sDic = @{}.mutableCopy; //二级依赖字典
            NSDictionary *allDic = @{@"name":@"全部",@"id":@"-1"}; //全部字段
            
            void (^configData)(NSMutableArray*,NSDictionary*) = ^(NSMutableArray *mArray,NSDictionary *dic){
                NSMutableDictionary *mDic = dic.mutableCopy;
                [mDic setObject:dic[@"id"] forKey:KRely];
                [mDic setObject:@(NO) forKey:KSelect];
                [mArray addObject:mDic];
            };
            //手动添加”全部“字段
            configData(fArray,allDic); //一级数组
            [sDic setObject:@[allDic.mutableCopy].mutableCopy forKey:@"-1"]; //二级字典
            for (NSDictionary *dic in responseObject[@"data"]) {
                //一级
                configData(fArray,dic);
                //二级
                NSMutableArray *tArray = @[].mutableCopy;
                configData(tArray,allDic);
                for (NSDictionary *children in dic[@"children"]) {
                    configData(tArray,children);
                }
                [sDic setObject:tArray forKey:dic[@"id"]];
            }
            [deptFilterDic setObject:fArray forKey:KListKey(0)];
            [deptFilterDic setObject:sDic forKey:KListKey(1)];
            
            [self saveLocalWithObj:deptFilterDic key:CDFilterDeptKey];
        });
    };
    getData(nil);
}

//地区筛选数据
+ (void)requestAreaFilter
{
    void (^getData) (id) = ^(id responseObject) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray *srcArray = [responseObject[@"data"] mutableCopy];
            NSMutableDictionary *areaFilterDic = @{}.mutableCopy;
            NSMutableArray *fArray = @[].mutableCopy;
            NSMutableDictionary *sDic = @{}.mutableCopy;
            NSMutableDictionary *tDic = @{}.mutableCopy;
            NSDictionary *allDic = @{@"name":@"全部",@"code":@"-1"}; //全部字段
            
            void (^configData)(NSMutableArray *,NSDictionary *) = ^(NSMutableArray *arr,NSDictionary *dic){
                //添加元素
                void (^addObject)(NSMutableArray *,NSDictionary *) = ^(NSMutableArray *arr,NSDictionary *subDic){
                    NSMutableDictionary *mDic = subDic.mutableCopy;
                    [mDic setObject:subDic[@"code"] forKey:KRely];
                    [mDic setObject:@(NO) forKey:KSelect];
                    BOOL add = YES;
                    //去重
                    for (NSDictionary *iDic in arr) {
                        if ([iDic[@"code"] isEqualToString:mDic[@"code"]]) {
                            add = NO;
                        }
                    }
                    if (add)[arr addObject:mDic];
                };
                //添加”全部“字段
                if ([dic[@"code"] isEqualToString:@"-1"]) {
                    addObject(arr,dic);
                } else {
                    for (NSDictionary *subDic in srcArray) {
                        if ([subDic[@"pcode"] isEqualToString:dic[@"code"]]) {
                            addObject(arr,subDic);
                        }
                    }
                }
            };
            //省
            configData(fArray,allDic);
            configData(fArray,@{@"code":@"0"});
            [srcArray removeObjectsInArray:fArray];
            //市
            for (NSDictionary *dic in fArray) {
                NSMutableArray *sArray = @[].mutableCopy;
                configData(sArray,allDic);
                configData(sArray,dic);
                [sDic setObject:sArray forKey:dic[@"code"]];
                [srcArray removeObjectsInArray:sArray];
                //县
                for (NSDictionary *dic in sArray) {
                    NSMutableArray *tArray = @[].mutableCopy;
                    configData(tArray,allDic);
                    configData(tArray,dic);
                    [tDic setObject:tArray forKey:dic[@"code"]];
                    [srcArray removeObjectsInArray:tArray];
                }
            }
            [areaFilterDic setObject:fArray forKey:KListKey(0)];
            [areaFilterDic setObject:sDic forKey:KListKey(1)];
            [areaFilterDic setObject:tDic forKey:KListKey(2)];
            
            [self saveLocalWithObj:areaFilterDic key:CDFilterAreaKey];
        });
    };
    getData(nil);
}

//医院等级筛选数据
+ (void)requestLevelFilter
{
    void (^getData) (id) = ^(id responseObject) {
        void (^configData)(NSMutableArray*,NSDictionary*) = ^(NSMutableArray *mArray,NSDictionary *dic){
            NSMutableDictionary *mDic = dic.mutableCopy;
            [mDic setObject:dic[@"level"] forKey:@"name"];
            [mDic setObject:@(NO) forKey:KSelect];
            [mArray addObject:mDic];
        };
        NSMutableArray *mArray = @[].mutableCopy;
        configData(mArray,@{@"name":@"全部等级",@"id":@"-1"});
        for (NSDictionary *dic in responseObject[@"data"]) {
            configData(mArray,dic);
        }
        NSMutableDictionary *levelFilterDic = @{KListKey(0):mArray}.mutableCopy;
        
        [self saveLocalWithObj:levelFilterDic key:CDFilterLevelKey];
    };
    getData(nil);
}

+ (NSDictionary *)configResult:(NSDictionary *)selectDic index:(int)index
{
    NSMutableDictionary *resultDic = @{}.mutableCopy;
    [selectDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (index == 0) {
            if ([key isEqualToString:KListKey(0)]) {
                if ([obj[@"name"] isEqualToString:@"全部"]) {
                    [resultDic setValue:@"" forKey:@"deptId"];
                    [resultDic setValue:@"科室" forKey:@"name"];
                } else {
                    [resultDic setValue:obj[@"id"] forKey:@"deptId"];
                    [resultDic setValue:obj[@"name"] forKey:@"name"];
                }
            } else {
                if (![obj[@"name"] isEqualToString:@"全部"]) {
                    [resultDic setValue:obj[@"id"] forKey:@"deptId"];
                    [resultDic setValue:obj[@"name"] forKey:@"name"];
                }
            }
        } else if (index == 1) {
            if ([key isEqualToString:KListKey(0)]) {
                if ([obj[@"name"] isEqualToString:@"全部"]) {
                    [resultDic setValue:@"" forKey:@"pcode"];
                    [resultDic setValue:@"地区" forKey:@"name"];
                } else {
                    [resultDic setValue:obj[@"code"] forKey:@"pcode"];
                    [resultDic setValue:obj[@"name"] forKey:@"name"];
                }
            } else if ([key isEqualToString:KListKey(1)]){
                if (![obj[@"name"] isEqualToString:@"全部"]) {
                    [resultDic setValue:obj[@"pcode"] forKey:@"pcode"];
                    [resultDic setValue:obj[@"code"] forKey:@"ccode"];
                    [resultDic setValue:obj[@"name"] forKey:@"name"];
                } else {
                    [resultDic setValue:@"" forKey:@"ccode"];
                }
            } else {
                if (![obj[@"name"] isEqualToString:@"全部"]) {
                    [resultDic setValue:obj[@"code"] forKey:@"ccode"];
                    [resultDic setValue:obj[@"name"] forKey:@"name"];
                }
            }
        } else {
            if ([obj[@"name"] isEqualToString:@"全部等级"]) {
                [resultDic setValue:@"" forKey:@"level"];
                [resultDic setValue:@"医院等级" forKey:@"name"];
            } else {
                [resultDic setValue:obj[@"level"] forKey:@"level"];
                [resultDic setValue:obj[@"name"] forKey:@"name"];
            }
        }
    }];
    
    return resultDic;
}

+ (void)saveLocalWithObj:(id)obj key:(NSString *)key
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [ud setObject:data forKey:key];
    [ud synchronize];
}

+ (NSMutableDictionary *)getDeptDic
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CDFilterDeptKey];
    if (!data) {
        [self requestDeptFilter];
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSMutableDictionary *)getAreaDic
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CDFilterAreaKey];
    if (!data) {
        [self requestAreaFilter];
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSMutableDictionary *)getLevelDic
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:CDFilterLevelKey];
    if (!data) {
        [self requestLevelFilter];
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSMutableDictionary *)getDeptDicExample
{
    return @{
             @"list0":@[@{@"name":@"内科",@"id":@"nk",@"rely":@"nk",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"外科",@"id":@"wk",@"rely":@"wk",@"select":@(NO)}.mutableCopy].mutableCopy,
             //依赖于上一级的rely字段,rely存数据节点，比如id
             @"list1":@{@"nk":@[@{@"name":@"内科1号",@"select":@(NO)}.mutableCopy].mutableCopy,
                        @"wk":@[@{@"name":@"外科1号",@"select":@(NO)}.mutableCopy].mutableCopy}.mutableCopy
             
             }.mutableCopy;
}

+ (NSMutableDictionary *)getAreaDicExample
{
    return @{
             @"list0":@[@{@"name":@"广东省",@"rely":@"gd",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"河北省",@"rely":@"hb",@"select":@(NO)}.mutableCopy].mutableCopy,
             //依赖于上一级的rely字段
             @"list1":@{@"gd":@[@{@"name":@"广州市",@"rely":@"gz",@"select":@(NO)}.mutableCopy].mutableCopy,
                        @"hb":@[@{@"name":@"石家庄",@"rely":@"sjz",@"select":@(NO)}.mutableCopy].mutableCopy}.mutableCopy,
             //依赖于上一级的rely字段
             @"list2":@{@"gz":@[@{@"name":@"白云区",@"select":@(NO)}.mutableCopy].mutableCopy,
                       @"sjz":@[@{@"name":@"长安区",@"select":@(NO)}.mutableCopy].mutableCopy}.mutableCopy
             
             }.mutableCopy;
}

+ (NSMutableDictionary *)getLevelDicExample
{
    return @{
             @"list0":@[@{@"name":@"全部等级",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"三级甲等",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"三级乙等",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"二级甲等",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"二级甲等",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"一级甲等",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"一级甲等",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"县级医院",@"select":@(NO)}.mutableCopy,
                        @{@"name":@"乡镇医院",@"select":@(NO)}.mutableCopy,].mutableCopy,
             }.mutableCopy;
}

@end

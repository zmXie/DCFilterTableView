//
//  CDFilterModel.h
//  MedicalCircle
//
//  Created by xzm on 2019/5/20.
//  Copyright © 2019 Dachen Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 数据处理模型
 */
@interface CDFilterModel : NSObject

+ (void)requestFilter;
+ (NSDictionary *)configResult:(NSDictionary *)selectDic index:(int)index;

+ (NSMutableDictionary *)getDeptDic;
+ (NSMutableDictionary *)getAreaDic;
+ (NSMutableDictionary *)getLevelDic;

//示例
+ (NSMutableDictionary *)getDeptDicExample;
+ (NSMutableDictionary *)getAreaDicExample;
+ (NSMutableDictionary *)getLevelDicExample;

@end

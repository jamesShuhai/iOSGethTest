//
//  GethMJExtensionConfig.m
//  GethExplorer
//
//  Created by 书海 on 2017/11/3.
//  Copyright © 2017年 tangshuhai. All rights reserved.
//

#import "GethMJExtensionConfig.h"


@implementation GethMJExtensionConfig
/**
 * 在程序一加载时就执行一次
 */
+(void)load{
    /**
     * id为OC保留关键字，项目模型中的id全部转换为ID
     */
    [NSObject mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"ID" : @"id",
                 };
    }];
    
    
    
}
@end

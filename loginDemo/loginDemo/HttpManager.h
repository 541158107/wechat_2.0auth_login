//
//  HttpManager.h
//  loginDemo
//
//  Created by wujing on 2019/7/1.
//  Copyright © 2019 wujing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 网络请求回调处理
 */
typedef void(^ResponseBlock)(id resultData);


/**
 网络请求封装类
 */
@interface HttpManager : NSObject


/**
 单例模式

 @return <#return value description#>
 */
+ (HttpManager *)defaultManager;


/**
 网络请求封装
 
 @param url 请求域名和接口拼接
 @param params 接口参数
 @param respBlock 结果回调
 */
- (void)postDataWithUrl:(NSString*)url
                 params:(NSDictionary*)params
          responseBlock:(ResponseBlock)respBlock;


/**
 网络请求封装
 
 @param url 请求域名和接口拼接
 @param params 接口参数
 @param respBlock 结果回调
 */
- (void)getDataWithUrl:(NSString*)url
                params:(NSDictionary*)params
         responseBlock:(ResponseBlock)respBlock;

/**
 取消网络请求
 */
- (void)cancelRequest;


@end


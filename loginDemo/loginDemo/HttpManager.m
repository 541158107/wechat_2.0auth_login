//
//  HttpManager.m
//  loginDemo
//
//  Created by wujing on 2019/7/1.
//  Copyright © 2019 wujing. All rights reserved.
//

#import "HttpManager.h"
#import <objc/runtime.h>
#import "AFNetworking/AFNetworking.h"

@interface AFHTTPRequestSerializer (CompleteBlock)

@property (nonatomic, strong) ResponseBlock responseBlock;

@end

const char *blockKey = "BlockKey";

@implementation AFHTTPRequestSerializer (CompleteBlock)

- (void)setResponseBlock:(ResponseBlock)responseBlock
{
    objc_setAssociatedObject(self, blockKey, responseBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ResponseBlock)responseBlock
{
    return objc_getAssociatedObject(self, blockKey);
}

@end

@implementation HttpManager
{
    AFHTTPSessionManager *manager;
}

/**
 单例模式

 @return <#return value description#>
 */
+ (HttpManager *)defaultManager
{
    static dispatch_once_t onceToken;
    static HttpManager *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[HttpManager alloc] initSingleton];
    });
    return instance;
}

/**
 初始化 AFHTTPSessionManager

 @return <#return value description#>
 */
- (instancetype)initSingleton
{
    self = [super init];
    if (self) {
        manager = [AFHTTPSessionManager manager];
        /*
         关于 requestSerializer它就是AFNetworking参数编码的序列化器，它一共有三种编码格式：
         AFHTTPRequestSerializer：第一种是普通的http的编码格式也就是mid=10&method=userInfo&dateInt=20160818，这种格式的。
         AFJSONRequestSerializer：第二种也是json编码格式的，也就是编码成{"mid":"11","method":"userInfo","dateInt":"20160818"}
         AFPropertyListRequestSerializer：第三种没用过，但是看介绍接编码成pislt格式的参数*/
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //[manager.requestSerializer setValue: @"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 10.0;//网络请求超时为10S
#pragma mark - AFHTTPSessionManager 容易犯错的坑
        //若需设置acceptableContentTypes需放在requestSerializer之后设置才会生效
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    }
    return self;
}


/**
 网络请求封装 -- 加密
 
 @param url 请求域名和接口拼接
 @param params 接口参数
 @param respBlock 结果回调
 */
- (void)postDataWithUrl:(NSString*)url
                 params:(NSDictionary*)params
          responseBlock:(ResponseBlock)respBlock
{
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (respBlock != NULL) {
            respBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (respBlock != NULL) {
            respBlock(nil);
        }
    }];
}

/**
 网络请求封装 -- 加密
 
 @param url 请求域名和接口拼接
 @param params 接口参数
 @param respBlock 结果回调
 */
- (void)getDataWithUrl:(NSString*)url
                params:(NSDictionary*)params
         responseBlock:(ResponseBlock)respBlock
{
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (respBlock != NULL) {
            respBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (respBlock != NULL) {
            respBlock(nil);
        }
    }];
}

/**
 取消网络请求
 */
- (void)cancelRequest
{
    if ([manager.tasks count] > 0) {
        NSLog(@"返回时取消网络请求");
        [manager.tasks makeObjectsPerformSelector:@selector(cancel)];
        NSLog(@"tasks = %@",manager.tasks);
    }
}

@end

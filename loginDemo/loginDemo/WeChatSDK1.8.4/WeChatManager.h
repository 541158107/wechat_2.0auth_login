//
//  WeChatManager.h
//  loginDemo
//
//  Created by wujing on 2019/7/1.
//  Copyright © 2019 wujing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WeChatManagerDelegate <NSObject>

@optional

/**
 微信登录授权回调
 */
- (void)managerDidReceiveAuthResponse:(SendAuthResp *)response;

@end

@interface WeChatManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WeChatManagerDelegate> delegate;

/**
 * 向微信终端程序注册第三方应用
 * isEnableMTA 是否支持MTA数据上报
 */
+ (void)registerAppWithEnableMTA:(BOOL)isEnableMTA;

/**
 初始化实例
 */
+ (WeChatManager *)sharedManager;


/**
 微信登录授权
 */
- (BOOL)sendAuthRequestInViewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END

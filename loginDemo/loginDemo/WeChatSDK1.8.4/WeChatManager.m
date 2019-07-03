//
//  WeChatManager.m
//  loginDemo
//
//  Created by wujing on 2019/7/1.
//  Copyright © 2019 wujing. All rights reserved.
//

#import "WeChatManager.h"

static NSString *AuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *APPID = @"wx54fdc2099a3603c4";

@implementation WeChatManager

#pragma mark - 注册应用
+ (void)registerAppWithEnableMTA:(BOOL)isEnableMTA {
    [WXApi registerApp:APPID enableMTA:NO];
}

#pragma mark - LifeCycle
+ (WeChatManager *)sharedManager {
    static dispatch_once_t onceToken;
    static WeChatManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WeChatManager alloc] init];
    });
    return instance;
}

#pragma mark - 微信登录授权
- (BOOL)sendAuthRequestInViewController:(UIViewController *)viewController {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"wx_oauth_authorization_state";
    req.openID = APPID;
    /*
    if ([WXApi isWXAppInstalled])
    {
        return [WXApi sendReq:req];
    }else
    {
        return [WXApi sendAuthReq:req viewController:viewController delegate:self];
    }*/
    
    //return [WXApi sendReq:req];
    return [WXApi sendAuthReq:req viewController:viewController delegate:self];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate && [_delegate respondsToSelector:@selector(managerDidReceiveAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidReceiveAuthResponse:authResp];
        }
    }
}

@end

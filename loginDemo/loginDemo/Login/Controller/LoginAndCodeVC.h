//
//  LoginAndCodeVC.h
//  loginDemo
//
//  Created by wujing on 2019/7/4.
//  Copyright © 2019 wujing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginAndCodeVC : UIViewController

+ (LoginAndCodeVC *)initLoginAndCodeVC;

/**
 * 显示 登录view 时调用
 * 默认显示 登录view
 */
- (void)showLoginView;

/**
 * 显示 验证码view 时调用
 * 默认显示 登录view
 @param phone 验证码view 需显示手机号
 */
- (void)showCodeViewWithPhone:(NSString *)phone;

@end

NS_ASSUME_NONNULL_END

//
//  WJ_CodeInputView.h
//  loginDemo
//
//  Created by wujing on 2019/7/5.
//  Copyright © 2019 wujing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 数字输入框自定义宏
 */
#define WJ_CodeSize CGSizeMake (20, 20) /*密码的大小*/
#define WJ_CodeCount           6        /*密码个数*/
#define WJ_CodeInputSpace      10.0     /*密码框之间的间距*/

typedef enum : NSUInteger {
    WJ_CodeInputViewStyleNone,   // 口 每个密码框之间没有间距,类似一个长方形平分成多个长方形
    WJ_CodeInputViewStyleSpace,  // 口口口口口口 每个密码框之间存在一定间距,类似由一个个长方形拼接而成
    WJ_CodeInputViewStyleBottom, // _ _ _ _ _ _ 下划线样式密码框,每个下划线之间存在一定间距
} WJ_CodeInputViewStyle;

typedef enum : NSUInteger {
    WJ_CodeInputTextStyleNone,   // 数字
    WJ_CodeInputTextStyleSecure, // ‘*’
    WJ_CodeInputTextStyleDot,    // ‘●’
} WJ_CodeInputTextStyle;

@protocol WJ_CodeInputViewDelegate <NSObject>

@optional

/**
 密码输入完成 回调
 */
- (void)wj_CodeInputViewInputComplete:(NSString*)code;

@end

@interface WJ_CodeInputView : UIView

/**
 密码输入框

 @param frame 位置大小
 @param inputViewStyle 密码框样式
 @param textStyle 密码文本样式
 @return WJ_CodeInputView
 */
- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(WJ_CodeInputViewStyle)inputViewStyle textStyle:(WJ_CodeInputTextStyle)textStyle;

/**
 设置代理
 */
@property (nonatomic, weak) id<WJ_CodeInputViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

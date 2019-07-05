//
//  WJ_CodeInputView.m
//  loginDemo
//
//  Created by wujing on 2019/7/5.
//  Copyright © 2019 wujing. All rights reserved.
//

#import "WJ_CodeInputView.h"

@interface WJ_CodeInputView ()<UITextFieldDelegate>

@property (nonatomic, assign) WJ_CodeInputViewStyle inputViewStyle; // 密码框样式
@property (nonatomic, assign) WJ_CodeInputTextStyle textStyle;      // 密码文本样式

@property (nonatomic, strong) NSMutableArray *codeArray; // 用于存放单个密码

@property (nonatomic, assign) CGSize codeSize;           // 密码显示大小
@property (nonatomic, assign) NSInteger codeCount;       // 密码个数
@property (nonatomic, assign) CGFloat codeInputSpace;    // 密码框之间的间距

@end

@implementation WJ_CodeInputView

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(WJ_CodeInputViewStyle)inputViewStyle textStyle:(WJ_CodeInputTextStyle)textStyle
{
    frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.inputViewStyle = inputViewStyle;
    self.textStyle = textStyle;
    self = [super initWithFrame:frame];
    if (self) {
        // 存放密码Arr
        self.codeArray = [[NSMutableArray alloc] init];
        // 每个密码输入框的宽度、高度
        CGFloat codeInputWidth = 0.0,codeInputheight = 0.0;
        
        // 密码框
        if (inputViewStyle == WJ_CodeInputViewStyleNone) {
            self.codeSize = WJ_CodeSize;
            self.codeCount = WJ_CodeCount;
            self.codeInputSpace = 0.0;
            codeInputWidth = (CGRectGetWidth(frame) - self.codeInputSpace*(self.codeCount-1))/self.codeCount;
            codeInputheight = CGRectGetHeight(frame);
            for (int i = 0; i < self.codeCount-1; i++) {
                /*设置父视图边框*/
                self.layer.borderWidth = 1;
                self.layer.borderColor = [UIColor grayColor].CGColor;
                /*设置分隔线 结合父视图边框 呈现出密码输入框*/
                CGFloat x = CGRectGetMinX(frame) + (i+1)*codeInputWidth;
                CGFloat y = CGRectGetMinY(frame);
                CGFloat width = 1;
                CGFloat height = codeInputheight;
                UIView *styleNoneView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                styleNoneView.backgroundColor = [UIColor grayColor];
                [self addSubview:styleNoneView];
            }
        }else if(inputViewStyle == WJ_CodeInputViewStyleSpace) {
            self.codeSize = WJ_CodeSize;
            self.codeCount = WJ_CodeCount;
            self.codeInputSpace = WJ_CodeInputSpace;
            codeInputWidth = (CGRectGetWidth(frame) - self.codeInputSpace*(self.codeCount-1))/self.codeCount;
            codeInputheight = CGRectGetHeight(frame);
            for (int i = 0; i < self.codeCount; i++) {
                /*设置单个输入框*/
                CGFloat x = CGRectGetMinX(frame) + i*(codeInputWidth+self.codeInputSpace);
                CGFloat y = CGRectGetMinY(frame);
                CGFloat width= codeInputWidth;
                CGFloat height = codeInputheight;
                UIView *styleSpaceView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                styleSpaceView.layer.borderWidth = 1.0;
                styleSpaceView.layer.borderColor = [UIColor grayColor].CGColor;
                styleSpaceView.clipsToBounds = YES;
                [self addSubview:styleSpaceView];
            }
        }else if(inputViewStyle == WJ_CodeInputViewStyleBottom) {
            self.codeSize = WJ_CodeSize;
            self.codeCount = WJ_CodeCount;
            self.codeInputSpace = WJ_CodeInputSpace;
            codeInputWidth = (CGRectGetWidth(frame) - self.codeInputSpace*(self.codeCount-1))/self.codeCount;
            codeInputheight = CGRectGetHeight(frame);
            for (int i = 0; i < self.codeCount; i++) {
                /*设置单个下划线 呈现出密码输入框样式*/
                CGFloat x = CGRectGetMinX(frame) + i*(codeInputWidth+self.codeInputSpace);
                CGFloat y = CGRectGetMaxY(frame);
                CGFloat width= codeInputWidth;
                CGFloat height = 1;
                UIView *styleBottomView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                styleBottomView.backgroundColor = [UIColor grayColor];
                [self addSubview:styleBottomView];
            }
        }
        
        // 密码占位
        for (int i = 0; i < self.codeCount; i++) {
            CGFloat x = CGRectGetMinX(frame) + (codeInputWidth-self.codeSize.width)/2 + i*(codeInputWidth+self.codeInputSpace);
            CGFloat y = CGRectGetMinY(frame) + (codeInputheight-self.codeSize.height)/2;
            CGFloat width= self.codeSize.width;
            CGFloat height = self.codeSize.height;
            UILabel *codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
            codeLabel.textColor = [UIColor blackColor];
            codeLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
            codeLabel.textAlignment = NSTextAlignmentCenter;
            codeLabel.hidden = YES;
            [self addSubview:codeLabel];
            /*把创建的数字位置加入到数组中*/
            [self.codeArray addObject:codeLabel];
        }

        // textField
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = [UIColor clearColor];
        textField.tintColor = [UIColor clearColor];
        textField.delegate = self;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.borderStyle = UITextBorderStyleNone;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:textField];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"NSLog by wujing --->>> 变化%@", string);
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }
    else if(textField.text.length >= self.codeCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        NSLog(@"NSLog by wujing --->>> 输入的字符个数大于6，忽略输入");
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Action textFieldDidChange
- (void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"NSLog by wujing --->>> textField的值:%@", textField.text);
    for (UILabel *codeLabel in self.codeArray) {
        codeLabel.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UILabel *)[self.codeArray objectAtIndex:i]).hidden = NO;
        if (self.textStyle == WJ_CodeInputTextStyleNone) {
            ((UILabel *)[self.codeArray objectAtIndex:i]).text = [textField.text substringWithRange:NSMakeRange(i,1)];
        }else if(self.textStyle == WJ_CodeInputTextStyleSecure){
            ((UILabel *)[self.codeArray objectAtIndex:i]).text = @"﹡"; // http://www.fhdq.net 特殊字符展示
        }else if(self.textStyle == WJ_CodeInputTextStyleDot){
            ((UILabel *)[self.codeArray objectAtIndex:i]).text = @"●"; // http://www.fhdq.net 特殊字符展示
        }
    }
    if (textField.text.length == self.codeCount) {
        NSLog(@"NSLog by wujing --->>> 密码输入完毕");
        if ([self.delegate respondsToSelector:@selector(wj_CodeInputViewInputComplete:)]) {
            [self.delegate wj_CodeInputViewInputComplete:textField.text];
        }
    }
}

@end

//
//  LoginAndCodeVC.m
//  loginDemo
//
//  Created by wujing on 2019/7/4.
//  Copyright © 2019 wujing. All rights reserved.
//

/**
 数字输入框自定义宏
 */
#define FiguresSize CGSizeMake (20, 20) /*数字的大小*/
#define FiguresCount 6                  /*数字个数*/
#define FiguresSpace 0                 /*数字框之间的间距*/

#import "LoginAndCodeVC.h"
#import "WJ_CodeInputView.h"

@interface LoginAndCodeVC ()<WJ_CodeInputViewDelegate, UITextFieldDelegate>

/*登录*/
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *ruleLabel;
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;
/*验证码*/
@property (weak, nonatomic) IBOutlet UIView *codeView;
@property (weak, nonatomic) IBOutlet UILabel *receivedLabel;
@property (weak, nonatomic) IBOutlet UIView *codeInputView;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;

/*用于存放单个数字*/
@property (nonatomic, strong) NSMutableArray *numberArray;

@end

@implementation LoginAndCodeVC

+ (LoginAndCodeVC *)initLoginAndCodeVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"login" bundle:nil];
    LoginAndCodeVC *controller = [storyboard instantiateInitialViewController];
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showLoginView];
    
    [_sendCodeBtn addTarget:self action:@selector(sendeCodeClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initCodeInputTextField
{
    self.numberArray = [[NSMutableArray alloc] init];

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.codeInputView.frame), CGRectGetHeight(self.codeInputView.frame))];
    [self.codeInputView addSubview:textField];
    // _textField属性
    textField.backgroundColor = [UIColor whiteColor];
    //输入的文字颜色为白色
    textField.textColor = [UIColor whiteColor];
    //输入框光标的颜色为白色
    textField.tintColor = [UIColor whiteColor];
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.borderStyle = UITextBorderStyleNone;
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    // 每个数字输入框的宽度及高度
    CGFloat numberInputWidth = (CGRectGetWidth(self.codeInputView.frame)- FiguresSpace*(FiguresCount-1))/FiguresCount;
    CGFloat numberInputHeight = CGRectGetHeight(self.codeInputView.frame);

    for (int i = 0; i < FiguresCount; i++) {
        // 生成单个输入框
        UIView *numberInputView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(textField.frame) + i*(numberInputWidth+FiguresSpace), CGRectGetMinY(textField.frame), numberInputWidth, numberInputHeight)];
        numberInputView.layer.borderWidth = 1.0;
        numberInputView.layer.borderColor = [UIColor grayColor].CGColor;
        numberInputView.clipsToBounds = YES;
        [self.codeInputView addSubview:numberInputView];

        // 生成单个数字
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 + (numberInputWidth - FiguresSize.width) / 2, (numberInputHeight - FiguresSize.height) / 2, FiguresSize.width, FiguresSize.height)];
        numberLabel.textColor = [UIColor blackColor];
        numberLabel.backgroundColor = [UIColor redColor];
        numberLabel.font = [UIFont systemFontOfSize:18];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.hidden = NO;
        [numberInputView addSubview:numberLabel];
        //把创建的数字位置加入到数组中
        [self.numberArray addObject:numberLabel];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"变化%@", string);
    if([string isEqualToString:@"\n"]) {
        //按回车关闭键盘
        [textField resignFirstResponder];
        return NO;
    } else if(string.length == 0) {
        //判断是不是删除键
        return YES;
    }
    else if(textField.text.length >= FiguresCount) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        NSLog(@"输入的字符个数大于6，忽略输入");
        return NO;
    } else {
        return YES;
    }
}

/**
 *  重置显示的点
 */
- (void)textFieldDidChange:(UITextField *)textField
{
    NSLog(@"textField的值:%@", textField.text);
    for (UILabel *numberLabel in self.numberArray) {
        numberLabel.hidden = YES;
    }
    for (int i = 0; i < textField.text.length; i++) {
        ((UILabel *)[self.numberArray objectAtIndex:i]).hidden = NO;
        ((UILabel *)[self.numberArray objectAtIndex:i]).text = [textField.text substringWithRange:NSMakeRange(i,1)];
    }
    if (textField.text.length == FiguresCount) {
        NSLog(@"输入完毕");
    }
}

#pragma mark - 显示 登录View
- (void)showLoginView {
    self.loginView.hidden = NO;
    self.codeView.hidden = YES;
}

#pragma mark - 显示 验证码View
- (void)showCodeViewWithPhone:(NSString *)phone {
    self.loginView.hidden = YES;
    self.codeView.hidden = NO;
    
    // 验证码框
    //[self initCodeInputTextField];
    
    WJ_CodeInputView *codeInputView = [[WJ_CodeInputView alloc] initWithFrame:_codeInputView.frame
                                                               inputViewStyle:WJ_CodeInputViewStyleSpace
                                                                    textStyle:WJ_CodeInputTextStyleNone];
    codeInputView.delegate = self;
    [self.codeInputView addSubview:codeInputView];
}

#pragma mark - WJ_CodeInputViewDelegate
- (void)wj_CodeInputViewInputComplete:(NSString*)code {
    
}

#pragma mark - Action
- (IBAction)closeCurrentView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendeCodeClick:(id)sender {
    [self showCodeViewWithPhone:@""];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

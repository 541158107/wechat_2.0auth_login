//
//  ViewController.m
//  loginDemo
//
//  Created by wujing on 2019/7/1.
//  Copyright © 2019 wujing. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WeChatManager.h"
#import "HttpManager.h"

@interface AnimationDelegate : NSObject  <CAAnimationDelegate>

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.player play];
}

@end

@interface ViewController ()<CAAnimationDelegate,WeChatManagerDelegate>

/*初始化隐藏背景*/
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
/*初始登录相关 未登录显示,登录成功隐藏*/
@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *wexinBtn;
@property (weak, nonatomic) IBOutlet UIButton *touristBtn;
/*登录成功相关 登录成功显示,未登录隐藏*/
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) CABasicAnimation *scaleAnimation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 选择本地的视频
    _movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"QidongVideo" ofType:@"mp4"]];
    
    // 微信相关
    [WeChatManager sharedManager].delegate = self;
    [_wexinBtn addTarget:self action:@selector(wechatLogin:) forControlEvents:UIControlEventTouchUpInside];
    [_logoutBtn addTarget:self action:@selector(wechatLogout:) forControlEvents:UIControlEventTouchUpInside];
    
    // 启动页到视频播放过渡
    CALayer *backLayer = [CALayer layer];
    backLayer.frame = [UIScreen mainScreen].bounds;
    backLayer.contents = (__bridge id _Nullable)([self getLaunchImage].CGImage);
    [self.movieView.layer addSublayer:backLayer];
    
    // 播放
    AVPlayer *player = [[AVPlayer alloc] initWithURL:_movieURL];
    self.player = player;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer = playerLayer;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    playerLayer.frame = [UIScreen mainScreen].bounds;
    [self.movieView.layer addSublayer:playerLayer];
    
    // 动画渐变
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    self.scaleAnimation = scaleAnimation;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.duration = 3.0f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    AnimationDelegate *animationDelegate = [AnimationDelegate new];
    animationDelegate.player = self.player;
    scaleAnimation.delegate = animationDelegate;
    [self.playerLayer addAnimation:scaleAnimation forKey:nil];
    [UIView animateWithDuration:2.7 animations:^{
        self.backgroundImage.alpha = 0.0;
    }];
    
    // 视频循环播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // UI
    [self refreshUIWithInit:YES login:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - 刷新UI 退出登录时resultData为nil
- (void)refreshUIWithInit:(BOOL)first login:(NSDictionary*)resultData{
    if (first) {
        // 默认
        self.phoneBtn.alpha = 0.0;
        self.wexinBtn.alpha = 0.0;
        self.touristBtn.alpha = 0.0;
        self.avatarImage.alpha = 0.0;
        self.detailLabel.alpha = 0.0;
        self.logoutBtn.alpha = 0.0;
        self.phoneBtn.enabled = NO;
        self.touristBtn.enabled = NO;
        [UIView animateWithDuration:5.7 animations:^{
            self.phoneBtn.alpha = 1.0;
            self.wexinBtn.alpha = 1.0;
            self.touristBtn.alpha = 1.0;
        }];
    }else{
        if (resultData) {
            // 登录
            NSURL *url = [NSURL URLWithString:resultData[@"headimgurl"]];
            [self.avatarImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]];
            NSString *nickname,*sex,*openid;
            nickname = resultData[@"nickname"];
            sex = resultData[@"sex"];
            if ([sex intValue] == 1) sex = @"男性";
            if ([sex intValue] == 2) sex = @"女性";
            openid = resultData[@"openid"];
            self.detailLabel.text = [NSString stringWithFormat:@"昵称:%@\n性别:%@\nopenid:%@",nickname,sex,openid];
            [UIView animateWithDuration:2.4 animations:^{
                self.phoneBtn.alpha = 0.0;
                self.wexinBtn.alpha = 0.0;
                self.touristBtn.alpha = 0.0;
                self.avatarImage.alpha = 1.0;
                self.detailLabel.alpha = 1.0;
                self.logoutBtn.alpha = 1.0;
            }];
        }else{
            // 退出登录
            [UIView animateWithDuration:2.4 animations:^{
                self.phoneBtn.alpha = 1.0;
                self.wexinBtn.alpha = 1.0;
                self.touristBtn.alpha = 1.0;
                self.avatarImage.alpha = 0.0;
                self.detailLabel.alpha = 0.0;
                self.logoutBtn.alpha = 0.0;
            }];
        }
    }
}

#pragma mark - NSNotification (前后台切换)
- (void)onAppWillResignActive:(NSNotification*)notification {
    [self.player pause];
}

- (void)onAppDidBecomeActive:(NSNotification*)notification {
    [self.player play];
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification {

}

- (void)onAppWillEnterForeground:(NSNotification *)notification {
    
}

#pragma mark - 视频循环播放
- (void)playbackFinished:(NSNotification *)notifation {
    // 回到视频的播放起点
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark - 下一步
- (void)nextClick:(id)sender {
    [self.player pause];
    self.player = nil;
    self.scaleAnimation.delegate = nil;
    self.scaleAnimation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 微信登录
- (void)wechatLogin:(UIButton *)sender {
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [self wechatAuth];
}

#pragma mark - 退出登录
- (void)wechatLogout:(UIButton *)sender {
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [self refreshUIWithInit:NO login:nil];
}

#pragma mark - 获取启动图片
- (UIImage *)getLaunchImage {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString *orientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray *imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary *dic in imagesDict) {
        CGSize imageSize = CGSizeFromString(dic[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(screenSize, imageSize) && [dic[@"UILaunchImageOrientation"] isEqualToString:orientation]) {
            launchImageName = dic[@"UILaunchImageName"];
            break;
        }
    }
    return [UIImage imageNamed:launchImageName];
}

#pragma mark - WeChatManagerDelegate
- (void)managerDidReceiveAuthResponse:(SendAuthResp *)response {
    // 用户换取access_token的code，仅在ErrCode为0时有效
    if (response.errCode == 0 && [response.code length]) {
        [self wechatByCodeObtainAccessToken:response.code];
    }
}

#pragma mark - /* 微信登录 第一步：请求CODE*/
- (void)wechatAuth {
    /*开放文档地址 参数 返回结果
     https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317851&token=&lang=zh_CN
     
     appid    是    应用唯一标识，在微信开放平台提交应用审核通过后获得
     scope    是    应用授权作用域，如获取用户个人信息则填写snsapi_userinfo（ 什么是授权域？ ）
     state    否    用于保持请求和回调的状态，授权请求后原样带回给第三方。该参数可用于防止csrf攻击（跨站请求伪造攻击），
                    建议第三方带上该参数，可设置为简单的随机数加session进行校验
     
     ErrCode  ERR_OK = 0(用户同意) ERR_AUTH_DENIED = -4（用户拒绝授权） ERR_USER_CANCEL = -2（用户取消）
     code     用户换取access_token的code，仅在ErrCode为0时有效
     state    第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang     微信客户端当前语言
     country  微信用户当前国家信息
    */
    [[WeChatManager sharedManager] sendAuthRequestInViewController:self];
}

#pragma mark - /* 微信登录 第二步：通过code获取access_token*/
- (void)wechatByCodeObtainAccessToken:(NSString *)code {
    
    /* 请求地址 参数 返回结果
     https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
     
     appid      是         应用唯一标识，在微信开放平台提交应用审核通过后获得
     secret     是         应用密钥AppSecret，在微信开放平台提交应用审核通过后获得
     code       是         填写第一步获取的code参数
     grant_type 是         填authorization_code
     
     "access_token" = "23_4RnSRdisWjkoB1KYGd-e1m1l4k7Ty4-fGDCcaeWzEzowqU1_G2g08uOv-PT6a4dePEB0fIxfvwd8iR44HBr6W5bPip_D2YDIRBteklVa4ig";
     "expires_in" = 7200;
     openid = "oJtUD1Tt-X2JmrrArLtvDsB1LeLg";
     "refresh_token" = "23_NyZNOUyTWpT1y-R_EN_hGR7uMZsCguHwXK0IrTvBwmLZeGei1ZejqQMsV1nn67C2TYcg24HGl40m2bO4lHBRULG8UpNDwW9hqBlNCab4OG8";
     scope = "snsapi_userinfo";
     unionid = "oCYkm5-IbnymfsfIeoKYeK7c8BPk";
     
     access_token    接口调用凭证
     expires_in      access_token接口调用凭证超时时间，单位（秒）
     refresh_token   用户刷新access_token
     openid          授权用户唯一标识
     scope           用户授权的作用域，使用逗号（,）分隔
     unionid         当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段
     */
    
    NSString *url = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    NSDictionary *params = @{
                             @"appid": @"wx54fdc2099a3603c4",
                             @"secret": @"27dde938cc2b5168eae0f08571dc6228",
                             @"code": code,
                             @"grant_type": @"authorization_code",
                             };
    
    [[HttpManager defaultManager] postDataWithUrl:url params:params responseBlock:^(id resultData) {
        
        if ([resultData isKindOfClass:[NSDictionary class]]){
            
            //[self wechatExamineAccessTokenValid:resultData[@"access_token"] openId:resultData[@"openid"]];
            
            //[self wechatByCodeObtainAccessRefreshToken:resultData[@"refresh_token"]];
            
            [self wechatUserPersonalInformation:resultData[@"access_token"] openId:resultData[@"openid"]];
        }
    }];
}

#pragma mark - /* 微信登录 刷新或续期access_token使用 -> 获取第一步的code后，进行refresh_token*/
- (void)wechatByCodeObtainAccessRefreshToken:(NSString *)refresh_token  {
    
    /* 请求地址 参数 返回结果
     https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=APPID&grant_type=refresh_token&refresh_token=REFRESH_TOKEN
     
     appid         是    应用唯一标识
     grant_type    是    填refresh_token
     refresh_token 是    填写通过access_token获取到的refresh_token参数
     
     "access_token" = "23_4RnSRdisWjkoB1KYGd-e1m1l4k7Ty4-fGDCcaeWzEzowqU1_G2g08uOv-PT6a4dePEB0fIxfvwd8iR44HBr6W5bPip_D2YDIRBteklVa4ig";
     "expires_in" = 7200;
     openid = "oJtUD1Tt-X2JmrrArLtvDsB1LeLg";
     "refresh_token" = "23_NyZNOUyTWpT1y-R_EN_hGR7uMZsCguHwXK0IrTvBwmLZeGei1ZejqQMsV1nn67C2TYcg24HGl40m2bO4lHBRULG8UpNDwW9hqBlNCab4OG8";
     scope = "snsapi_base,snsapi_userinfo,";
     
     access_token    接口调用凭证
     expires_in      access_token接口调用凭证超时时间，单位（秒）
     refresh_token   用户刷新access_token
     openid          授权用户唯一标识
     scope           用户授权的作用域，使用逗号（,）分隔
     */
    
    NSString *url = @"https://api.weixin.qq.com/sns/oauth2/refresh_token";
    NSDictionary *params = @{
                             @"appid": @"wx54fdc2099a3603c4",
                             @"refresh_token": refresh_token,
                             @"grant_type": @"refresh_token",
                             };
    
    [[HttpManager defaultManager] postDataWithUrl:url params:params responseBlock:^(id resultData) {
        
    }];
}

#pragma mark - /* 微信登录 检验授权凭证（access_token）是否有效*/
- (void)wechatExamineAccessTokenValid:(NSString *)access_token openId:(NSString *)openid {
    
    /* 请求地址 参数 返回结果
     https://api.weixin.qq.com/sns/auth?access_token=ACCESS_TOKEN&openid=OPENID
     
     access_token  是    调用接口凭证
     openid        是    普通用户标识，对该公众帐号唯一
     
     errcode = 0;
     errmsg = ok;
     */
    
    NSString *url = @"https://api.weixin.qq.com/sns/auth";
    NSDictionary *params = @{
                             @"openid": openid,
                             @"access_token": access_token,
                             };
    
    [[HttpManager defaultManager] postDataWithUrl:url params:params responseBlock:^(id resultData) {
        
    }];
}

#pragma mark - /* 微信登录 获取用户个人信息（UnionID机制*/
- (void)wechatUserPersonalInformation:(NSString *)access_token openId:(NSString *)openid {
    
    /* 请求地址 参数 返回结果
     https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
     
     access_token    是    调用凭证
     openid          是    普通用户的标识，对当前开发者帐号唯一
     lang            否    国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语，默认为zh-CN
     
     city = "";
     country = BO;
     headimgurl = "http://thirdwx.qlogo.cn/mmopen/vi_32/eXtnhgc630kUTYW6Oj5nOFgII0ibEBjp9M7VCZln32TPZLtq4K5YbRgkns3P8vVuAKeib0sXtOD1BJ75bRS3RvTQ/132";
     language = "zh_CN";
     nickname = "\U4e8e\U679c\Ud83c\Udf3b";
     openid = "oJtUD1Tt-X2JmrrArLtvDsB1LeLg";
     privilege =     (
     );
     province = "";
     sex = 2;
     unionid = "oCYkm5-IbnymfsfIeoKYeK7c8BPk";
     
     openid      普通用户的标识，对当前开发者帐号唯一
     nickname    普通用户昵称
     sex         普通用户性别，1为男性，2为女性
     province    普通用户个人资料填写的省份
     city        普通用户个人资料填写的城市
     country     国家，如中国为CN
     language    国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语，默认为zh-CN
     headimgurl  用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空
     privilege   用户特权信息，json数组，如微信沃卡用户为（chinaunicom）
     unionid     用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的。
     */
    
    NSString *url = @"https://api.weixin.qq.com/sns/userinfo";
    NSDictionary *params = @{
                             @"openid": openid,
                             @"access_token": access_token,
                             };
    
    [[HttpManager defaultManager] postDataWithUrl:url params:params responseBlock:^(id resultData) {
        if ([resultData isKindOfClass:[NSDictionary class]]) {
            [self refreshUIWithInit:NO login:resultData];
        }
    }];
}

@end

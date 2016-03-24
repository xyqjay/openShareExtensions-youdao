//
//  YouDaoOAuthViewController.m
//  openShare-youdaoDemo
//
//  Created by Jay on 16/3/24.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "YouDaoOAuthViewController.h"
#import "OpenShare+YouDao.h"
@interface YouDaoOAuthViewController ()<UIWebViewDelegate, NSURLConnectionDelegate, NSURLSessionDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) authSuccess authSuccess;
@end

@implementation YouDaoOAuthViewController
#pragma mark -- view lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNav];
    [self initWebView];
    
    [self loadOAuthorized];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNav
{
    self.title = @"登陆授权";
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClickCancel:)];
    
    self.navigationItem.rightBarButtonItem = right;
}
- (void)initWebView
{
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    // 设置WebView不上下滚动...
    [(UIScrollView *)[[_webView subviews] objectAtIndex:0] setBounces:NO];
    _webView.scalesPageToFit = NO;
    [self.view addSubview:_webView];
}
#pragma mark - 加载登录授权界面
-(void)loadOAuthorized {
    
    //   GET  请求
    //    1.设置请求路径
    NSString *baseurl = [NSString stringWithFormat:@"%@oauth/authorize2",baseURL];
    
    NSString *urlString = [NSString stringWithFormat:@"%@?client_id=%@&response_type=code&redirect_uri=%@&state=1",baseurl, _youDaoNote_consumerKey, _youDaoNote_domains];
    //  转码
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    _webView.delegate = self;
    [_webView loadRequest:request];
}
#pragma mark -- Action
- (void)onClickCancel:(UIButton *)sender{

    [self dismissViewControllerAnimated:YES completion:^{
        if (self.authSuccess) {
            self.authSuccess(nil);
            self.authSuccess = nil;
        }
    }];
}
#pragma mark -- Public Methods
+ (void)beginOAuth{
    YouDaoOAuthViewController *youdao = [[YouDaoOAuthViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:youdao];
     UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentViewController:navigationController animated:YES completion:nil];
    NSAssert(window.rootViewController, @"keyWindow.rootViewController不能为空");
}
- (void)beginOAuth:(authSuccess)success{
    self.authSuccess = success;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController presentViewController:navigationController animated:YES completion:nil];
    NSAssert(window.rootViewController, @"keyWindow.rootViewController不能为空");
}
#pragma mark - UIWebVeiwDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //containsString: 从iOS8开始支持，如需支持iOS7，可自己更换判断字符串方法
    NSString *containsString = [NSString stringWithFormat:@"http://%@/?state=1&code=",_youDaoNote_domains];
    if ([request.URL.absoluteString containsString:containsString]) {
        
        NSString *code = [request.URL.absoluteString stringByReplacingOccurrencesOfString:containsString withString:@""];
//        认证成功，开始获取accessToken
        [self getAccessToken:code];
    }
    return YES;
}
#pragma mark -- getAccessToken
//发送请求，获取accessToken
-(void)getAccessToken:(NSString *)code
{
    NSString *url =  [baseURL stringByAppendingString:@"oauth/access2"];
    NSDictionary *params = @{
                             @"client_id" : _youDaoNote_consumerKey,
                             @"client_secret" : _youDaoNote_consumerSecret,
                             @"grant_type":@"authorization_code",
                             @"redirect_uri":_youDaoNote_domains,
                             @"code":code
                             };
    NSURL *rurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:rurl];
    request.HTTPMethod = @"POST";
    NSMutableString *mtbStr = [NSMutableString string];
    [params.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = params[key];
        [mtbStr appendFormat:@"%@=%@&", key, value];
    }];
    NSString *body = [mtbStr substringToIndex:mtbStr.length - 1];
    
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!weakSelf || error || !data) return;//错误返回
        NSError *errorX = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errorX];
           /*
            *字典格式：
            {
            accessToken = xxx;
            "access_token" = xxx;
            }
            */
        if (!errorX && dict[@"accessToken"]) {
            [self getAccessTokenSuccess:dict];
        }else{
            //错误。
        }
    }];
    
    [task resume];
    
}
//获取accessToken成功
- (void)getAccessTokenSuccess:(NSDictionary *)dictionary{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.authSuccess) {
            self.authSuccess(dictionary);
            self.authSuccess = nil;
        }
    }];
}
@end

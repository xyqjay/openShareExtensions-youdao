//
//  OpenShare+YouDao.m
//  openShare-youdaoDemo
//
//  Created by Jay on 16/3/24.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "OpenShare+YouDao.h"
#import "YouDaoOAuthViewController.h"
@implementation OpenShare (YouDao)
static NSString* schema=@"YouDao";
static NSString* accessToken;

+(void)connectYouDaoWithAPPKey:(NSString *)appKey
                  AndAppSecret:(NSString*)appSecret
                  AndAppDomain:(NSString *)appDomain{
    [self set:schema Keys:@{@"appKey":appKey,
                            @"appSecret":appSecret,
                            @"appDomain":appDomain}];

}
+(void)YouDaoAuth:(NSString*)scope Success:(authSuccess)success Fail:(authFail)fail{
    if ([self beginAuth:schema Success:success Fail:fail]) {
        NSDictionary *dict = [self keyFor:schema];
        YouDaoOAuthViewController *controller = [[YouDaoOAuthViewController alloc] init];
        controller.youDaoNote_consumerKey = dict[@"appKey"];
        controller.youDaoNote_consumerSecret = dict[@"appSecret"];
        controller.youDaoNote_domains = dict[@"appDomain"];
        [controller beginOAuth:^(NSDictionary *message) {
            if (!message) {
                if (fail) {
                    fail(nil,nil);
                }
            }else{
                accessToken = message[@"accessToken"];
                if (success) {
                    success(message);
                }
            }
        }];
    }
}
+(void)shareToYouDao:(OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail{
    if ([self beginShare:schema Message:msg Success:success Fail:fail]) {

        if (!accessToken) {
            [self YouDaoAuth:nil Success:^(NSDictionary *message) {
                if (!message) {
                    if (fail) {
                        fail(nil,nil);
                    }
                }else{
                    accessToken = message[@"accessToken"];
                    [self creatYouDaoNote:msg];
                }
            } Fail:^(NSDictionary *message, NSError *error) {
                //
            }];
        }else{
            [self creatYouDaoNote:msg];
        }
        
    }
}
+(void)shareToYouDao:(OSMessage*)msg
               token:(NSString *)token
             Success:(shareSuccess)success
                Fail:(shareFail)fail{
    accessToken = token;
    [self shareToYouDao:msg Success:success Fail:fail];
}
// 创建笔记
+ (void)creatYouDaoNote:(OSMessage*)msg{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:msg.link ? msg.link : @"desc" forKey:@"source"];
    [params setObject:msg.title ? msg.title : @"title" forKey:@"title"];
    [params setObject:msg.desc ? msg.desc : @"desc" forKey:@"content"];
    NSString *url = [baseURL stringByAppendingString:@"yws/open/note/create.json"];
    [self YouDaoNoteWithUrl:url withParams:params token:accessToken];
}

+(void)YouDaoNoteWithUrl:(NSString *)url withParams:(NSMutableDictionary *)params token:(NSString *)touken
{
    //初始化
    NSString *hyphens = @"--";
    NSString *boundary = @"lxs";//一位大侠的留名 大侠博客：http://www.jianshu.com/users/4b0c0a14ef87/latest_articles
    NSString *end = @"\r\n";
    //初始化数据
    NSMutableData *myRequestData1=[NSMutableData data];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //添加其他参数
    for(int i = 0;i < [keys count];i ++)
    {
        NSMutableString *body = [[NSMutableString alloc]init];
        [body appendString:hyphens];
        [body appendString:boundary];
        [body appendString:end];
        //得到当前key
        NSString *key = [keys objectAtIndex:i];
        //添加字段名称
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"%@%@",key,end,end];
        
        //添加字段的值
        [body appendFormat:@"%@",[params objectForKey:key]];
        [body appendString:end];
        [myRequestData1 appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //拼接结束~~~
    [myRequestData1 appendData:[hyphens dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData1 appendData:[boundary dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData1 appendData:[hyphens dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData1 appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    //设置HTTPHeader中Content-Type的值
    NSString *content = [[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",boundary];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    NSString *oauth_token = [NSString stringWithFormat:@"OAuth oauth_token=\"%@\"", touken];
    [request setValue:oauth_token forHTTPHeaderField:@"Authorization"];
    //设置Content-Length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData1 length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData1];
    //http method
    [request setHTTPMethod:@"POST"];
    //回调返回值
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ( error || !data){
            shareFail fail = [self shareFailCallback];
            fail(nil,nil);
        }
            return;//错误返回
        NSError *errorX = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errorX];
        if (errorX&&!dict) {
            shareFail fail = [self shareFailCallback];
            fail(nil,nil);
        }else{
            shareSuccess success = [self shareSuccessCallback];
            success(nil);
        }
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }];
    
    [task resume];
}
@end

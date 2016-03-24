//
//  YouDaoOAuthViewController.h
//  openShare-youdaoDemo
//
//  Created by Jay on 16/3/24.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenShare.h"

// 有道测试环境的baseUrl:
//#define baseURL @"http://sandbox.note.youdao.com/"
// 有道线上环境的baseUrl:
#define baseURL @"https://note.youdao.com/"



@interface YouDaoOAuthViewController : UIViewController
@property (nonatomic, strong) NSString *youDaoNote_consumerKey;
@property (nonatomic, strong) NSString *youDaoNote_consumerSecret;
@property (nonatomic, strong) NSString *youDaoNote_domains;
//+ (void)beginOAuth;
- (void)beginOAuth:(authSuccess)success;
@end

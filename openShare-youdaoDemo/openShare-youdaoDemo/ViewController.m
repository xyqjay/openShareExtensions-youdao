//
//  ViewController.m
//  openShare-youdaoDemo
//
//  Created by Jay on 16/3/24.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "ViewController.h"
#import "OpenShare.h"
#import "OpenShare+YouDao.h"
@interface ViewController ()
@property (nonatomic, strong) NSString *accessToken;
@end

@implementation ViewController
#warning 这里自己找有道申请
//这些自己去有道申请
//consumerName不需要传
//#define YouDaoNote_consumerName @"example"
//#define YouDaoNote_consumerKey @"example"
//#define YouDaoNote_consumerSecret @"example"
//#define domains @"example.example.com"

- (void)viewDidLoad {
    [super viewDidLoad];
    [OpenShare connectYouDaoWithAPPKey:YouDaoNote_consumerKey
                          AndAppSecret:YouDaoNote_consumerSecret
                          AndAppDomain:domains];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickOauth:(id)sender{

    
    [OpenShare YouDaoAuth:nil Success:^(NSDictionary *message) {
        //怎么取都可以
        self.accessToken = message[@"accessToken"];
        self.accessToken = message[@"access_token"];

    } Fail:^(NSDictionary *message, NSError *error) {
        //
    }];
}
- (IBAction)onClickShare:(id)sender{
    OSMessage *msg = [[OSMessage alloc] init];
    msg.title = @"标题";
    msg.link = @"https://www.github.com";
    msg.desc = @"描述";
    [OpenShare shareToYouDao:msg Success:^(OSMessage *message) {
        //
    } Fail:^(OSMessage *message, NSError *error) {
        //
    }];
}
@end

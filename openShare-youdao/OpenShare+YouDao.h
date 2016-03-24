//
//  OpenShare+YouDao.h
//  openShare-youdaoDemo
//
//  Created by Jay on 16/3/24.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenShare.h"
@interface OpenShare (YouDao)
//有道需要这三个东西。
+(void)connectYouDaoWithAPPKey:(NSString *)appKey
                  AndAppSecret:(NSString*)appSecret
                  AndAppDomain:(NSString *)appDomain;

+(void)YouDaoAuth:(NSString*)scope Success:(authSuccess)success Fail:(authFail)fail;
+(void)shareToYouDao:(OSMessage*)msg Success:(shareSuccess)success Fail:(shareFail)fail;

+(void)shareToYouDao:(OSMessage*)msg
               token:(NSString *)token
             Success:(shareSuccess)success
                Fail:(shareFail)fail;

@end

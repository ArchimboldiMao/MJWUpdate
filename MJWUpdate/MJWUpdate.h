//
//  MJWUpdate.h
//  MJWUpdate
//
//  Created by Archimboldi Mao on 16/12/2016.
//  Copyright © 2016 Archimboldi Mao. All rights reserved.
//  LICENSE file in the root directory of this source tree.
//

#import <UIKit/UIKit.h>

@interface MJWUpdate : NSObject

@property NSString *alertTitle;

@property NSString *alertSummary;

@property NSString *updateButtonTitle;

@property NSString *ignoreButtonTitle;

/**
 * 1. The method will block main thread, until check success or failure.
 * 1. App 在启动时会查询 App Store, 检测是否有新版本，联网或查询失败时跳过检测直接启动
 * 2. 版本号支持的格式 Major，Major.Minor，Major.Minor.Patch 如 V1, V1.1, V1.1.1
 * 3. 没有设置当前版本号时，必须升级
 * 4. 当前版本号的格式与最新版本号格式不一致时，必须升级
 * 5. 当前版本号的格式不是数字和英文的.时(也不能包含空格或空字符串)，必须升级
 * 6. 当前版本的主版本号小于App Store的版本时，必须升级
 * 7. 当前版本的主版本号等于App Store的版本时，a后面的第2个版本号小于App Store的版本时，b主版本号和第2个版本号都等于App Store的版本，后面的第3个版本号小于App Store的版本时, 会提示升级（可跳过）
 *
 * appleID App的Apple ID
 * rootViewController is a UIWindow.rootViewController
 * applicationBlock 检测版本之后，执行正常启动的代码块
 */
- (void)checkAppStoreLatestVersionWithAppleID:(NSNumber *)appleID rootViewController:(UIViewController *)rootViewController  block:(void (^)())applicationBlock;

@end



//
//  MJWUpdate.m
//  MJWUpdate
//
//  Created by Archimboldi Mao on 16/12/2016.
//  Copyright © 2016 Archimboldi Mao. All rights reserved.
//  LICENSE file in the root directory of this source tree.
//

#import "MJWUpdate.h"

@implementation MJWUpdate

static NSString *kAppLookupURL = @"https://itunes.apple.com/lookup";
static NSString *kAppleIDKey = @"id";

static NSString *kAlertTitle = @"A new version for you";
static NSString *kAlertSummary = @"Please update your app to the latest version.";
static NSString *kUpdateButtonTitle = @"Update now";
static NSString *kIgnoreButtonTitle = @"Ignore";

static NSString *kAlertTitle_zh = @"有新版本可以更新";
static NSString *kAlertSummary_zh = @"您当前使用的App版本过低，\n请立即升级！";
static NSString *kUpdateButtonTitle_zh = @"立即下载";
static NSString *kIgnoreButtonTitle_zh = @"跳过";

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)checkAppStoreLatestVersionWithAppleID:(NSNumber *)appleID rootViewController:(UIViewController *)rootViewController block:(void (^)())applicationBlock {
    [self runOnMainQueueWithoutDeadlocking:^(){
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:kAppLookupURL] resolvingAgainstBaseURL:YES];
        NSMutableArray *queryItems = [NSMutableArray new];
        NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:kAppleIDKey value:[appleID stringValue]];
        [queryItems addObject:queryItem];
        urlComponents.queryItems = queryItems;
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:urlComponents.URL];
        NSLog(@"request is %@", request);
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"dataTaskWithRequest error is %@", error);
                applicationBlock();
                return;
            }
            NSError *jsonError;
            NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError || !jsonResults) {
                NSLog(@"jsonError error is %@, results is %@", error, jsonResults);
                applicationBlock();
                return;
            }
            // NSLog(@"jsonResults is %@", jsonResults);
            BOOL appStoreHasANewVersion = NO;
            BOOL haveToUpdateToNewVersion = NO;
            NSString *latestVersionURL = @"";
            NSNumber *resultCount = jsonResults[@"resultCount"];
            if (resultCount && [resultCount integerValue] >= 1) {
                NSArray *apps = [jsonResults objectForKey:@"results"];
                for (NSDictionary *appDic in apps) {
                    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                    NSString *bundleID = [appDic objectForKey:@"bundleId"];
                    NSNumber *trackID = [appDic objectForKey:@"trackId"];
                    latestVersionURL = [appDic objectForKey:@"trackViewUrl"];
                    // NSLog(@"bundleIdentifier is %@", bundleIdentifier);
                    // NSLog(@"bundleID is %@", bundleID);
                    // NSLog(@"trackID is %@", trackID);
                    // NSLog(@"latestVersionURL is %@", latestVersionURL);
                    if (!latestVersionURL || ![latestVersionURL hasPrefix:@"https"]) {
                        NSLog(@"The App Store latest version web page url has a wrong formula, the url is %@", latestVersionURL);
                        appStoreHasANewVersion = NO;
                        haveToUpdateToNewVersion = NO;
                        break;
                    }
                    if ([bundleIdentifier isEqualToString:bundleID] && [appleID longLongValue] == [trackID longLongValue]) {
                        NSString *latestVersionString = [appDic objectForKey:@"version"];
                        NSString *bundleVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
                        NSArray *latestVersions = [latestVersionString componentsSeparatedByString:@"."];
                        NSArray *bundleVersions = [bundleVersionString componentsSeparatedByString:@"."];
                        // App Store 返回的信息中不包含版本信息时，跳出版本检测
                        if (latestVersions.count <= 0) {
                            NSLog(@"The App Store return a wrong version, the return value is %@", latestVersionString);
                            appStoreHasANewVersion = NO;
                            haveToUpdateToNewVersion = NO;
                            break;
                        }
                        // * 3. 没有设置当前版本号时，必须升级
                        // * 4. 当前版本号的格式与最新版本号格式不一致时，必须升级
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        if (bundleVersions.count <= 0 || bundleVersions.count != latestVersions.count) {
                            NSLog(@"The current version has a wrong version formula, the current version is %@", bundleVersionString);
                            appStoreHasANewVersion = YES;
                            haveToUpdateToNewVersion = YES;
                            break;
                        }
                        // * 5. 当前版本号的格式不是数字和英文的.时(也不能包含空格或空字符串)，必须升级
                        BOOL bundleVersionFormatError = NO;
                        for (NSString *version in bundleVersions) {
                            NSString *finalVersion = [version stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if (![version isEqualToString:finalVersion] || [formatter numberFromString:finalVersion] == nil) {
                                bundleVersionFormatError = YES;
                                break;
                            }
                        }
                        if (bundleVersionFormatError) {
                            NSLog(@"The current version has a wrong version formula, the current version is %@", bundleVersionString);
                            appStoreHasANewVersion = YES;
                            haveToUpdateToNewVersion = YES;
                            break;
                        }
                        NSString *bundleMajorVersionString = [bundleVersions firstObject];
                        NSString *latestMajorVersionString = [latestVersions firstObject];
                        NSNumber *bundleMajorVersion = [formatter numberFromString:bundleMajorVersionString];
                        NSNumber *latestMajorVersion = [formatter numberFromString:latestMajorVersionString];
                        if ([latestMajorVersion integerValue] > [bundleMajorVersion integerValue]) {
                            NSLog(@"The current major version(%@) is less than the App Store version(%@), you have to update.", bundleMajorVersion, latestMajorVersion);
                            appStoreHasANewVersion = YES;
                            haveToUpdateToNewVersion = YES;
                            break;
                        } else if ([bundleMajorVersion integerValue] > 0 && [latestMajorVersion integerValue] == [bundleMajorVersion integerValue]) {
                            if (bundleVersions.count >= 2 && latestVersions.count >= 2) {
                                NSString *bundleMinorVersionString = bundleVersions[1];
                                NSString *latestMinorVersionString = latestVersions[1];
                                NSNumber *bundleMinorVersion = [formatter numberFromString:bundleMinorVersionString];
                                NSNumber *latestMinorVersion = [formatter numberFromString:latestMinorVersionString];
                                if ([latestMinorVersion integerValue] > [bundleMinorVersion integerValue]) {
                                    NSLog(@"The current major version(%@) is equal to the App Store version(%@), but the current minor version(%@) is less than the App Store version(%@), so you can choose to update or ignore.", bundleMajorVersion, latestMajorVersion, bundleMinorVersion, latestMinorVersion);
                                    appStoreHasANewVersion = YES;
                                    haveToUpdateToNewVersion = NO;
                                    break;
                                } else if ([latestMinorVersion integerValue] == [bundleMinorVersion integerValue] && bundleVersions.count >= 3 && latestVersions.count >= 3) {
                                    NSString *bundlePatchVersionString = bundleVersions[2];
                                    NSString *latestPatchVersionString = latestVersions[2];
                                    NSNumber *bundlePatchVersion = [formatter numberFromString:bundlePatchVersionString];
                                    NSNumber *latestPatchVersion = [formatter numberFromString:latestPatchVersionString];
                                    if ([latestPatchVersion integerValue] > [bundlePatchVersion integerValue]) {
                                        NSLog(@"The current major version(%@) is equal to the App Store version(%@), and the current minor version(%@) is equal to the App Store version(%@), but the current patch version(%@) is less than the App Store version(%@), so you can choose to update or ignore.", bundleMajorVersion, latestMajorVersion, bundleMinorVersion, latestMinorVersion, bundlePatchVersion, latestPatchVersion);
                                        appStoreHasANewVersion = YES;
                                        haveToUpdateToNewVersion = NO;
                                        break;
                                    }
                                }
                            }
                        }
                        break;
                    }
                }
            }
            if (appStoreHasANewVersion) {
                NSLog(@"appStoreHasANewVersion");
                [self showUpdateAlerView:rootViewController appStoreURL:latestVersionURL haveToUpdateToNewVersion:haveToUpdateToNewVersion block:applicationBlock];
            } else {
                NSLog(@"Current version is the latest version");
                [self runOnMainQueueWithoutDeadlocking: ^{
                    applicationBlock();
                }];
            }
        }];
        NSLog(@"dataTask.state is %ld", (long)dataTask.state);
        [dataTask resume];
        NSLog(@"after resume dataTask.state is %ld", (long)dataTask.state);
    }];
}

- (void)fillAlertTextValue {
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    BOOL is_zh = [language hasPrefix:@"zh"];
    if (!_alertTitle || [_alertTitle isEqualToString:@""]) {
        _alertTitle = is_zh ? kAlertTitle_zh : kAlertTitle;
    }
    if (!_alertSummary || [_alertSummary isEqualToString:@""]) {
        _alertSummary = is_zh ? kAlertSummary_zh : kAlertSummary;
    }
    if (!_updateButtonTitle || [_updateButtonTitle isEqualToString:@""]) {
        _updateButtonTitle = is_zh ? kUpdateButtonTitle_zh : kUpdateButtonTitle;
    }
    if (!_ignoreButtonTitle || [_ignoreButtonTitle isEqualToString:@""]) {
        _ignoreButtonTitle = is_zh ? kIgnoreButtonTitle_zh : kIgnoreButtonTitle;
    }
}

- (void)showUpdateAlerView:(UIViewController *)rootViewController appStoreURL:(NSString *)appStoreURL haveToUpdateToNewVersion:(BOOL)haveToUpdateToNewVersion block:(void (^)())block {
    [self fillAlertTextValue];
    [self runOnMainQueueWithoutDeadlocking: ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_alertTitle message:_alertSummary preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:_updateButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:appStoreURL];
            UIApplication *application = [UIApplication sharedApplication];
            if ([application canOpenURL:url]) {
                if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                    [application openURL:url options:@{} completionHandler:^(BOOL success){
                        // 强制更新，跳出 App 时需要退出当前 App, 防止用户连按 Home 键／左上角返回，回到 App 时会跳过提醒框继续使用旧版本
                        exit(0);
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                    // 强制更新，跳出 App 时需要退出当前 App, 防止用户连按 Home 键／左上角返回，回到 App 时会跳过提醒框继续使用旧版本
                    exit(0);
                }
            }
        }];
        if (!haveToUpdateToNewVersion) {
            NSLog(@"choose to update or ignore");
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:_ignoreButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                block();
            }];
            [alertController addAction:cancle];
        }
        [alertController addAction:alertAction];
        [rootViewController.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)runOnMainQueueWithoutDeadlocking:(void (^)())block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end

//
//  AppDelegate.m
//  MJWUpdateExample
//
//  Created by Archimboldi Mao on 16/12/2016.
//  Copyright © 2016 Archimboldi Mao. All rights reserved.
//  LICENSE file in the root directory of this source tree.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <MJWUpdate/MJWUpdate.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSNumber *appleID = @284882215;
    MJWUpdate *versionUpdate = [MJWUpdate new];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIViewController *rootViewController;
    if ([[NSBundle mainBundle] pathForResource:@"LaunchScreen" ofType:@"storyboardc"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
        rootViewController = storyboard.instantiateInitialViewController;
    } else {
        rootViewController = [[UIViewController alloc] init];
        UIView *updateView = [[UIView alloc] initWithFrame:self.window.bounds];
        updateView.backgroundColor = [UIColor whiteColor];
        [rootViewController.view addSubview:updateView];
    }
    _window.rootViewController = rootViewController;
    [_window makeKeyAndVisible];
    [versionUpdate checkAppStoreLatestVersionWithAppleID:appleID rootViewController:_window.rootViewController block:^{
        
        ViewController *viewController;
        if ([[NSBundle mainBundle] pathForResource:@"Main" ofType:@"storyboardc"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            viewController = storyboard.instantiateInitialViewController;
        } else {
            viewController = [ViewController new];
        }
        _window.rootViewController = viewController;
    }];
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

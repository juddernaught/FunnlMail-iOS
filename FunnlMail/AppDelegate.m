//
//  AppDelegate.m
//  FunnlMail
//
//  Created by Daniel Judd on 3/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SQLiteDatabase.h"
#import "ServiceTests.h"
#import <Mixpanel/Mixpanel.h>

#define MIXPANEL_TOKEN @"08b1e55d72f1b22a8e5696c2b56a6777"

@implementation AppDelegate
@synthesize menuController,drawerController,appActivityIndicator,currentFunnelString,currentFunnelDS,progressHUD,funnelUpDated;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // MixPanel setup
    [Mixpanel sharedInstanceWithToken:@"08b1e55d72f1b22a8e5696c2b56a6777"];
    [[Mixpanel sharedInstance] track:@"App opened"];
    funnelUpDated = FALSE;
    progressHUD = [[MBProgressHUD alloc] init];
    //initializing currentFunnelString to "All"
    currentFunnelString = @"all";
    currentFunnelDS = nil;
    appActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(320 - 20 - 10, 10, 20, 20)];
    //FunnlViewController *fvc = [[FunnlViewController alloc] init];
    //self.window.rootViewController = fvc;
  
    //
    // initialize the database by referencing the shared instance
    //
    [SQLiteDatabase sharedInstance];
  
    //
    // run database tests
    //
    //[ServiceTests runTests];
  
    LoginViewController *vc = [[LoginViewController alloc]init];
    vc.view.backgroundColor = [UIColor clearColor];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nav;
    self.startDate = [NSDate date];

    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self endInterval];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    self.startDate = [NSDate date];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self endInterval];

}

//saves the amount of time spent in app
-(void)endInterval{
    NSTimeInterval time = [self.startDate timeIntervalSinceNow];
    NSInteger ti = 0 - (NSInteger)time;
    NSInteger secondsInDecimal = (ti % 60)/60;
    NSInteger minutes = (ti / 60);
    NSInteger time2 = secondsInDecimal + minutes;
    NSLog(@"Time: %@",[NSString stringWithFormat:@"%02ld", (long)time2]);
    [[Mixpanel sharedInstance] track:@"Time Open" properties:@{@"Time": [NSString stringWithFormat:@"%02ld", (long)time2]}];
}

@end

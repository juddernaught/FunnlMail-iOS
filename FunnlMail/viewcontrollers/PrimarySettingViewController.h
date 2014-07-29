//
//  PrimarySettingViewController.h
//  FunnlMail
//
//  Created by Macbook on 7/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "View+MASAdditions.h"
#import "MainVC.h"
#import "AppDelegate.h"

@interface PrimarySettingViewController : UIViewController
{
    AppDelegate *tempAppDelegate;
    NSMutableDictionary *settingsDictionary;
    NSMutableArray *switchArray,*categoryArray;
}
@property (weak) id<MainVCDelegate> mainVCdelegate;
@end

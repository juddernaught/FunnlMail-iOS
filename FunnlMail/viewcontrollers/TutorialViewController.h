//
//  TutorialViewController.h
//  FunnlMail
//
//  Created by Macbook on 9/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexString.h"
#import "PageContentVC.h"

@interface TutorialViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
{
    NSArray *images;

}
@property (strong, nonatomic) UIPageViewController *pageController;

@end

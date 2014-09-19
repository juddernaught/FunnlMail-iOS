//
//  VIPViewController.h
//  VIPFunnelCreationOptions
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIPCreateFunnelViewController.h"
#import "FMCreateFunnlViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "UIColor+HexString.h"
@interface VIPViewController : UIViewController
{
    NSMutableArray *contactMutableArray;
    NSMutableArray *buttonArray;
    NSMutableArray *selectedContact;
}
@end

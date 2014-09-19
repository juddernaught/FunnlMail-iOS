//
//  VIPCreateFunnelViewController.h
//  VIPFunnel
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "ContactModel.h"
#import "UIColor+HexString.h"
#import "VIPFunnelCreationConfirmationController.h"
#define COMMON_DIFFERENCE 30
@interface VIPCreateFunnelViewController : UIViewController<UITextFieldDelegate>
{
    NSArray *randomColors;
    UIScrollView *mainScrollView;
    NSMutableArray *contactMutableArray;
    UITextField *funnelNameTextField;
    UITextField *subjectTextField;
    NSMutableArray *buttonArray;
    BOOL advanceFlag;
    int finalHeight;
    UIView *containerView;
    int innerY;
    UIView *footerView;
    NSMutableArray *editButtonArray;
    NSMutableArray *textFieldArray;
    BOOL flag;
    //newly added for saving funnl
    NSMutableArray *senderArray;
    NSMutableArray *subjectArray;
    BOOL enableNotification;
    BOOL skipPrimary;
}
- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray;
@end

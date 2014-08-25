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

@interface VIPCreateFunnelViewController : UIViewController<UITextFieldDelegate>
{
    UIScrollView *mainScrollView;
    NSMutableArray *contactMutableArray;
    UITextField *funnelNameTextField;
    UITextField *subjectTextField;
    NSMutableArray *buttonArray;
    BOOL advanceFlag;
    int finalHeight;
    UIView *containerView;
    int innerY;
}
- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray;
@end

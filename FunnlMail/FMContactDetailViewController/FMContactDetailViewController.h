//
//  FMContactDetailViewController.h
//  FunnlMail
//
//  Created by shrinivas on 05/09/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MailCore/MailCore.h>
#import "ContactModel.h"
#import "ContactService.h"
#import "GTMOAuth2ViewControllerTouch.h"

@interface FMContactDetailViewController : UIViewController<UITextFieldDelegate>
{
    MCOAddress *selectedAddress;
    ContactModel *selectedContact;
    UIImageView *contactImageView;
    UILabel *emailLabel;
}
- (id)initWithMessage:(MCOAddress *)address;
@end

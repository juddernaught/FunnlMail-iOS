//
//  VIPFunnelCreationConfirmationController.h
//  FunnlMail
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "ContactModel.h"
#import "UIColor+HexString.h"
@interface VIPFunnelCreationConfirmationController : UIViewController
{
    NSMutableArray *contactMutableArray;
    NSMutableArray *buttonArray;
}
- (id)initWithContacts:(NSMutableArray*)contacts;
@end

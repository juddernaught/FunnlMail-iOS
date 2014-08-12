//
//  CreateFunnlViewController.h
//  FunnlMail
//
//  Created by Krunal on 5/26/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "View+MASAdditions.h"
#import "MainVC.h"
#import "AppDelegate.h"
#import "ContactModel.h"
#import "ContactService.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "WEPopoverController.h"
#import "UIPopoverController+iPhone.h"

@class FilterModel;
@interface CreateFunnlViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate,GTMFetcherAuthorizationProtocol,GTMHTTPFetcherServiceProtocol,WEPopoverControllerDelegate, UIPopoverControllerDelegate,UIScrollViewDelegate>
{
    WEPopoverController *popoverController;
    AppDelegate *tempAppDelegate;
    UITableView *Tableview;
    UITextField *nameTextField,*conversattionTextField,*subjectTextField;
    NSMutableDictionary *dictionaryOfConversations,*dictionaryOfSubjects;
    NSString *funnlName;
    UITextField *activeField;
    NSArray *randomColors;
    FunnelModel *oldModel;
    UISwitch *skipAllSwitch;
    UISwitch *enableNotificationsSwitch;
    BOOL areNotificationsEnabled;
    BOOL isSkipAll;
    NSInteger currentPopoverCellIndex;
    Class popoverClass;
    CGFloat _keyboardHeight;
}
@property (nonatomic, retain) IBOutlet UIPopoverController *poc;
@property (nonatomic, retain) WEPopoverController *popoverController;
@property (weak) id<MainVCDelegate> mainVCdelegate;
@property (assign) BOOL isEdit;
-(id)initTableViewWithSenders:(NSMutableDictionary*)sendersDictionary subjects:(NSMutableDictionary*)subjectsDictionary filterModel:(FunnelModel*)model;
@end


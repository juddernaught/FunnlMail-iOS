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

@class FilterModel;
@interface CreateFunnlViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *tempAppDelegate;
    UITableView *tableview;
    UITextField *nameTextField,*conversattionTextField,*subjectTextField;
    NSMutableDictionary *dictionaryOfConversations,*dictionaryOfSubjects;
    NSString *funnlName;
    id activeField;
    NSArray *randomColors;
    FunnelModel *oldModel;
    UISwitch *skipAllSwitch;
    UISwitch *enableNotificationsSwitch;
    BOOL isSkipALl;
    BOOL areNotificationsEnabled;
}
@property (weak) id<MainVCDelegate> mainVCdelegate;
@property (assign) BOOL isEdit;

-(id)initTableViewWithSenders:(NSMutableDictionary*)sendersDictionary subjects:(NSMutableDictionary*)subjectsDictionary filterModel:(FunnelModel*)model;
@end


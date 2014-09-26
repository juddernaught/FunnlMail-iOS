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
#import "FunnelModel.h"
#import <Mixpanel/Mixpanel.h>
#import "FunnelService.h"
#import "EmailService.h"

#define COMMON_DIFFERENCE 30
@interface FMCreateFunnlViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>
{
    UIButton *addButton;
    BOOL isTextFieldEditing;
    UIScrollView *suggestionScroll;
    NSArray *suggestionArray;
    NSMutableArray *senderArray;
    NSArray *randomColors;
    UIScrollView *mainScrollView;
    NSMutableArray *contactMutableArray;
    UITextField *funnelNameTextField;
    UITextField *subjectTextField;
    UITextField *additionalTextField;
    UIButton *addEmailButton;
    NSMutableArray *buttonArray;
    UIButton *deleteButton;
    BOOL advanceFlag;
    int finalHeight;
    UIView *containerView;
    int innerY;
    UIView *footerView;
    NSMutableArray *editButtonArray;
    NSMutableArray *textFieldArray;
    NSMutableArray *seperatorViewArray;
    BOOL flag;
    NSMutableArray *emailTempArray;
    BOOL isEditing;
    NSString *subjectString;
    BOOL enableNotification;
    BOOL skipPrimary;
    ContactModel *addedContact;
    NSMutableArray *subjectArray;
    UIView *seperatorAdditionalTextField;
    
    id activeTextField;
    BOOL keyboardFlag;
    NSMutableArray *fetcherArray;
    BOOL isFunnlNameTextFieldEditing;
    //autosuggestion resource
    NSMutableArray *searchArray;
    UITableView *autocompleteTableView;
    NSMutableArray *emailArr;
    CGFloat _keyboardHeight;
    
}
@property (weak) id<MainVCDelegate> mainVCdelegate;
@property (strong, nonatomic)FunnelModel *oldModel;
@property BOOL isEditFunnel;
@property BOOL shareFunnl;

- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray;
- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray name:(NSString *)name andSubjects:(NSMutableArray *)subjects;
@end

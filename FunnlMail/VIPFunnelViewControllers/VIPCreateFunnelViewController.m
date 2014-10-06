//
//  VIPCreateFunnelViewController.m
//  VIPFunnel
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "VIPCreateFunnelViewController.h"
#import "AppDelegate.h"
#import "FXBlurView.h"
#import "FunnelService.h"
#import "EmailService.h"
#import <Parse/Parse.h>
#import <Mixpanel/Mixpanel.h>

@interface VIPCreateFunnelViewController ()

@end

@implementation VIPCreateFunnelViewController

#pragma mark Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSelectedContactArray:(NSMutableArray *)contactArray {
    self = [super init];
    if (self) {
        // Custom initialization
        contactMutableArray = contactArray;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    randomColors = GRADIENT_ARRAY;
    flag = TRUE;
    advanceFlag = TRUE;
    buttonArray = [[NSMutableArray alloc] init];
//    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
    UIBarButtonItem *sampleBarButton = [[UIBarButtonItem alloc] init];
    [sampleBarButton setTitle:@"Cancel"];
    [self.navigationItem setLeftBarButtonItem:sampleBarButton];
    sampleBarButton = nil;
    
    sampleBarButton = [[UIBarButtonItem alloc] init];
    [sampleBarButton setTitle:@"Save"];
    [self.navigationItem setLeftBarButtonItem:sampleBarButton];
    sampleBarButton = nil;
    [self performSelectorOnMainThread:@selector(applyBackgroundImage) withObject:nil waitUntilDone:YES];
    [self setUpCustomNavigationBar];
    [self setUpViewForCreatingFunnel];
}

- (void)viewWillAppear:(BOOL)animated {
//    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark -
#pragma mark Helper
-(void) createWebhooksAndSaveFunnl
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *senders = senderArray;
    NSArray *subjects = subjectArray;
    __block int reqCnt = (int)[senders count];
    if ([subjects count]) {
        reqCnt *= [subjects count];
    }
    NSMutableDictionary *webhooks = [[NSMutableDictionary alloc] init];
    //creation of webhooks
    for (NSString *sender in senders) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:sender forKey:@"filter_from"];
        //[params setObject:@"0" forKey:@"sync_period"];
        if ([subjects count]) {
            for (NSString *subject in subjects) {
                [params setObject:subject forKey:@"filter_subject"];
                [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
                    [webhooks setObject:responseDict forKey:sender];
                    reqCnt--;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (reqCnt == 0) {
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:webhooks options:NSJSONWritingPrettyPrinted error:nil];
                            NSString *webhookIds = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            [self saveFunnlWithWebhookId:webhookIds];
                        }
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    reqCnt--;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"createWebhooksandSaveFunnl --- deleteWebhookWithID : %@",error.userInfo.description);
                        //[self showAlertForError:error];
                        if (reqCnt == 0) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                    });
                }];
                continue;
            }
        } else {
            [appDelegate.contextIOAPIClient createWebhookWithCallbackURLString:@"http://funnlmail.parseapp.com/send_notification" failureNotificationURLString:@"http://funnlmail.parseapp.com/failure" params:params success:^(NSDictionary *responseDict) {
                [webhooks setObject:responseDict forKey:sender];
                reqCnt--;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (reqCnt == 0) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:webhooks options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *webhookIds = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [self saveFunnlWithWebhookId:webhookIds];
                    }
                });
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                reqCnt--;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"createWebhooksAndSaveFunnl --- Email : %@",error.userInfo.description);
                    //[self showAlertForError:error];
                    if (reqCnt == 0) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [self saveFunnlWithWebhookId:nil];
                    }
                });
            }];
        }
    }
}

-(void) saveFunnlWithWebhookId:(NSString *) webhookId
{
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(webhookId != nil){
        //---- Added by Krunal to get work PNs
        NSData* jsonData = [webhookId dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *webhooks = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil]];
        NSArray *senders = [[webhooks allKeys] copy];
        NSMutableArray *webhookChannelArray = [NSMutableArray new];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        for (NSString *sender in senders) {
            NSDictionary *webhook_id_Dictionary = [webhooks objectForKey:sender];
            NSString *webhook_id = [webhook_id_Dictionary objectForKey:@"webhook_id"];
            [webhookChannelArray addObject:webhook_id];
            [currentInstallation addUniqueObject:([NSString stringWithFormat:@"webhook_id_%@", webhook_id]) forKey:@"channels"];
        }
        [currentInstallation saveInBackground];
        //---- end
    }
    else{
        
    }
    
    unsigned long temp = [[FunnelService instance] allFunnels].count%8;
    //NSInteger gradientInt = arc4random_uniform((uint32_t)randomColors.count);
    NSString *colorString = @"#F9F9F9";
    UIColor *color = [UIColor colorWithHexString:colorString];
    
    colorString = [randomColors objectAtIndex:temp];
    if(color == nil){
        color = [UIColor colorWithHexString:@"#F9F9F9"];
    }
    else {
        color = [UIColor colorWithHexString:colorString];
    }
    FunnelModel *model;
    model = [[FunnelModel alloc]initWithBarColor:color filterTitle:funnelNameTextField.text newMessageCount:0 dateOfLastMessage:[NSDate new] sendersArray:senderArray subjectsArray:subjectArray skipAllFlag:skipPrimary funnelColor:colorString];
    model.notificationsFlag = enableNotification;
    model.webhookIds = webhookId ? webhookId : @"";
    model.skipFlag = skipPrimary;
    
    [[FunnelService instance] insertFunnel:model];
    [[EmailService instance] applyingFunnel:model toMessages:[[MessageService instance] messagesAllTopMessages]];
    [EmailService setNewFilterModel:model];
    [tempAppDelegate.mainVCdelegate filterSelected:model];
    model = nil;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_VIP_CREATED"]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"IS_VIP_CREATED"];
    }
    VIPFunnelCreationConfirmationController *viewController = [[VIPFunnelCreationConfirmationController alloc] initWithContacts:contactMutableArray];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [tempAppDelegate.progressHUD setHidden:YES];
    [tempAppDelegate.progressHUD removeFromSuperview];
    [MBProgressHUD hideHUDForView:tempAppDelegate.window animated:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (int)validateFunnelName:(NSString*)funnelName {
    NSArray *funnelArray = [[FunnelService instance] allFunnels];
    for (FunnelModel *tempFunnelName in funnelArray) {
        if ([tempFunnelName.funnelName.lowercaseString isEqualToString:funnelName.lowercaseString]) {
            return 2;
        }
    }
    if ([[funnelName stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
        return 3;
    }
    return 1;
}

- (void)showHUD {
    AppDelegate *tempAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [MBProgressHUD showHUDAddedTo:tempAppDelegate.window animated:YES];
}

- (void)applyBackgroundImage {
    AppDelegate *tempAppDelegate = APPDELEGATE;
    UIGraphicsBeginImageContext(tempAppDelegate.window.bounds.size);
    [tempAppDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    UIImageView *backgroundImageView = nil;
    if (backgroundImageView) {
        backgroundImageView = nil;
    }
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backgroundImageView setImage:[UIImage imageWithData:data]];
    data = nil;
    [self.view addSubview:backgroundImageView];
    FXBlurView *backgroundView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backgroundView setBlurEnabled:YES];
    backgroundView.tintColor = [UIColor lightGrayColor];
    backgroundView.blurRadius = 10;
    [self.view addSubview:backgroundView];
    backgroundView = nil;
    [backgroundView setUserInteractionEnabled:YES];
    backgroundView = nil;
}

- (void)resignAllTextField {
    for (UITextField *tempTextField in textFieldArray) {
        [tempTextField resignFirstResponder];
    }
}

- (UITextField*)getTextFieldForButton:(UIButton*)sender {
    for (UITextField *tempTextField in textFieldArray) {
        if (tempTextField.tag == sender.tag) {
            return tempTextField;
        }
    }
    return nil;
}

- (void)moveElementsBelowButton:(UIButton*)sender {
    for (UITextField *tempTextField in textFieldArray) {
        if (sender.tag < tempTextField.tag) {
            tempTextField.frame = CGRectMake(tempTextField.frame.origin.x, tempTextField.frame.origin.y - COMMON_DIFFERENCE - 5, tempTextField.frame.size.width, tempTextField.frame.size.height);
        }
    }
    
    for (UIButton *tempButton in editButtonArray) {
        if (sender.tag < tempButton.tag) {
            tempButton.frame = CGRectMake(tempButton.frame.origin.x, tempButton.frame.origin.y - COMMON_DIFFERENCE - 5, tempButton.frame.size.width, tempButton.frame.size.height);
        }
    }
}

- (void)setUpViewForCreatingFunnel {
    int y = 0;
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 22, WIDTH, HEIGHT - self.navigationController.navigationBar.frame.size.height - 22)];
    [mainScrollView setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6]];
    
    UILabel *sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 125, 40)];
    [sampleLAbel setTextAlignment:NSTextAlignmentLeft];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Funnel Name";
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    funnelNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 0, WIDTH - 125 - 10, 40)];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_VIP_CREATED"]) {
        funnelNameTextField.text = @""; //REMOVE this DEFAULT NAME
    }
    else {
        funnelNameTextField.text = @"";
    }
    [funnelNameTextField becomeFirstResponder];
    funnelNameTextField.returnKeyType = UIReturnKeyDone;
    funnelNameTextField.delegate = self;
    [funnelNameTextField setFont:[UIFont boldSystemFontOfSize:18]];
    [funnelNameTextField setTextColor:[UIColor whiteColor]];
    [funnelNameTextField setTextAlignment:NSTextAlignmentLeft];
    [mainScrollView addSubview:funnelNameTextField];
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, 40, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    
    y = y + 40 + 1;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + 10, 300, 20)];
    sampleLAbel.text = @"Include People";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setTextAlignment:NSTextAlignmentLeft];
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    y = y + 20 + 20;
    
    
    float buttonSize = 75.0;
    int margin = 40;
    //    int xMargine = 10;
    int x = 10;
    //    int yMargine = 10;
    int label_height = 40;
    float color = 255;
    
    UIFont *labelFont = REGULAR_FONT_12;
    
    for (int counter = 0; counter < 9 && counter < contactMutableArray.count; counter++) {
        if (counter > 0)
            color = 255/(counter*2);
        unsigned long temp = counter % 8;
        randomColors = nil;
        randomColors = GRADIENT_ARRAY;
        NSString *colorString = [randomColors objectAtIndex:temp];
        UIColor *color = [UIColor colorWithHexString:colorString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[(ContactModel*)[contactMutableArray objectAtIndex:counter] thumbnail]]];
        [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        fetcher.comment = [NSString stringWithFormat:@"%d",counter];
        GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
        [fetcher setAuthorizer:currentAuth];
        [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
        
        
        if (counter % 3 == 0) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
            
            if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] length]) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            else if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] length]) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
        
            tempButton.tag = counter;
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [mainScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + buttonSize + 0, buttonSize, label_height)];
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [mainScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 1) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y, buttonSize, buttonSize)];
            tempButton.tag = counter;
            if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] length]) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            else if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] length]) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [mainScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y + buttonSize + 0, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [mainScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 2) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y, buttonSize, buttonSize)];
            tempButton.tag = counter;
            if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] length]) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            else if ([[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] length]) {
                [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] email] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            }
            [tempButton setBackgroundColor:color];
            
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [mainScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y + buttonSize + 0, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [mainScrollView addSubview:sampleLabel];
            sampleLabel = nil;
            
            y = y + buttonSize + margin;
        }
    }
    
    if (contactMutableArray.count % 3 == 0) {
        
    }
    else {
        y = y + buttonSize + 20 + 20;
    }
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    sampleView = nil;
    
    y = y + 1 + 10;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 40 - 10)];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Enable Notifications";
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    UISwitch *notificationEnableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 10 - 50, y, 70, 40)];
    [notificationEnableSwitch setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [notificationEnableSwitch addTarget:self action:@selector(enableNotificationChanges:) forControlEvents:UIControlEventValueChanged];
    [mainScrollView addSubview:notificationEnableSwitch];
    notificationEnableSwitch = nil;
    
    y = y + 20 + 20;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    sampleView = nil;
    
    y = y + 1 + 10;
    
    if (containerView) {
        containerView = nil;
    }
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, WIDTH, 10)];
    
//    [containerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    innerY = 0;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, innerY, 300, 40)];
    sampleLAbel.text = @"ADVANCED";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
//    [sampleLAbel setFont:[UIFont boldSystemFontOfSize:20]];
//    [mainScrollView addSubview:sampleLAbel];
    [containerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    UIImageView *sampleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH - 10 - 18, innerY + 20 - 10, 18, 10)];
    [sampleImageView setImage:[UIImage imageNamed:@"expandIcon.png"]];
    [containerView addSubview:sampleImageView];
    sampleImageView = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, innerY, WIDTH, 40)];
    [sampleButton addTarget:self action:@selector(advanceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [mainScrollView addSubview:sampleButton];
    [containerView addSubview:sampleButton];
    sampleButton = nil;
    
//    y = y + 40 + 10;
    innerY = innerY + 40 + 10;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, innerY, WIDTH, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
//    [mainScrollView addSubview:sampleView];
    [containerView addSubview:sampleView];
    sampleView = nil;
    
//    y = y + 1 + 20;
    innerY = innerY + 1 + 20;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, innerY, WIDTH - 20, 15)];
    sampleLAbel.text = @"Include Subject Keywords:";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
//    [mainScrollView addSubview:sampleLAbel];
    [containerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
//    y = y + 15 + 5;
    innerY = innerY + 15 + 10;
    
    textFieldArray = [[NSMutableArray alloc] init];
    
    subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, innerY, 300 - 45, 20)];
    subjectTextField.tag = 0;
//    [subjectTextField setPlaceholder:@"Enter the subject"];
    subjectTextField.returnKeyType = UIReturnKeyDone;
    subjectTextField.delegate = self;
    [textFieldArray addObject:subjectTextField];
    NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the subject"];
    [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the subject".length)];
    [subjectTextField setAttributedPlaceholder:tempString];
    tempString = nil;
    [subjectTextField setTextColor:[UIColor whiteColor]];
//    [mainScrollView addSubview:subjectTextField];
    [containerView addSubview:subjectTextField];
    
    editButtonArray = [[NSMutableArray alloc] init];
    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, innerY + 10 - 30.0/2.0, 30, 30)];
    [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
    sampleButton.tag = 0;
    [sampleButton setBackgroundColor:[UIColor clearColor]];
    [editButtonArray addObject:sampleButton];
    [containerView addSubview:sampleButton];
    
//    y = y + 20;
    innerY = innerY + 20;
    
    innerY = innerY + 5;
    
    if (footerView) {
        footerView = nil;
    }
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, innerY, WIDTH, 100)];
    
    int internalY = 0;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, internalY, WIDTH - 20, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
//    [containerView addSubview:sampleView];
    [footerView addSubview:sampleView];
    sampleView = nil;
    
    internalY = internalY + 5;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, internalY, WIDTH - 20, 40)];
    sampleLAbel.numberOfLines = 2;
    [sampleLAbel setFont:[UIFont systemFontOfSize:14]];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Only emails having subjects containing your keywords will be filtered into this Funnel";
//    [containerView addSubview:sampleLAbel];
    [footerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    internalY = internalY + 40;
    
    internalY = internalY + 5;
    
    
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, internalY, WIDTH - 20, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
//    [containerView addSubview:sampleView];
    [footerView addSubview:sampleView];
    sampleView = nil;
    
//    innerY = innerY + 5 + 10;
    internalY = internalY + 15;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, internalY, 300, 40 - 10)];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Skip Primary Inbox";
//    [containerView addSubview:sampleLAbel];
//    [footerView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    UISwitch *primarySkipSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH - 10 - 50, internalY, 70, 40)];
    [primarySkipSwitch setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    [containerView addSubview:primarySkipSwitch];
    [primarySkipSwitch addTarget:self action:@selector(skipPrimaryMailChange:) forControlEvents:UIControlEventValueChanged];
//    [footerView addSubview:primarySkipSwitch];
    primarySkipSwitch = nil;
    
//    innerY = innerY + 40;
    internalY = internalY + 40;
    
    footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y, footerView.frame.size.width, internalY);
    
    innerY = internalY + innerY;
    
    containerView.frame = CGRectMake(0, y, WIDTH, innerY);
    
    [containerView setClipsToBounds:YES];
    [containerView addSubview:footerView];
    
    [mainScrollView addSubview:containerView];
    
    [self.view addSubview:mainScrollView];
    [mainScrollView setContentSize:CGSizeMake(WIDTH, y + innerY)];
    y = y + innerY;
    finalHeight = y;
}

- (void)setUpCustomNavigationBar {
    UIView *naviGationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
//    [naviGationBar setBackgroundColor:[UIColor clearColor]];
    [naviGationBar setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 100, 44)];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [sampleButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(106, 22, 108, 44)];
    [sampleLabel setTextAlignment:NSTextAlignmentCenter];
    sampleLabel.text = @"Create Funnel";
    [sampleLabel setTextColor:[UIColor whiteColor]];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    [naviGationBar addSubview:sampleLabel];
    sampleLabel = nil;
    
    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 100 - 10, 22, 100, 44)];
    [sampleButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setTitle:@"Save" forState:UIControlStateNormal];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sampleButton setTitleColor:[UIColor colorWithHexString:DONE_BUTTON_BLUE] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 2)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [naviGationBar addSubview:sampleView];
    sampleView = nil;
    
    [self.view addSubview:naviGationBar];
}

#pragma mark -
#pragma mark Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (mainScrollView.contentSize.height - mainScrollView.contentOffset.y < HEIGHT - 66) {
        [mainScrollView setContentOffset:CGPointMake(0, mainScrollView.contentSize.height - HEIGHT + 66) animated:YES];
    }
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (textField == funnelNameTextField) {
        [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else {
        if (HEIGHT == 568) {
            [mainScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y + containerView.frame.origin.y - 200) animated:YES];
        }
        else {
            [mainScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y + containerView.frame.origin.y - 150) animated:YES];
        }
    }
    [UIView commitAnimations];
    return YES;
}
- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
    }
    else {
        NSLog(@"--------> %@",imageFetcher.comment);
        UIButton *tempButton = [buttonArray objectAtIndex:[imageFetcher.comment integerValue]];
        //        TextFieldCell *tempCell = (TextFieldCell*)[Tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[imageFetcher.comment integerValue] inSection:1]];
        //        [tempCell.thumbnailImageView setImage:[UIImage imageWithData:imageData]];
        [tempButton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        [tempButton setBackgroundColor:[UIColor clearColor]];
        [tempButton setTitle:@"" forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark Event Handler
- (void)enableNotificationChanges:(UISwitch *)tempSwitch {
    enableNotification = !enableNotification;
}

- (void)skipPrimaryMailChange:(UISwitch *)tempSwitch {
    skipPrimary = !skipPrimary;
}

- (void)addSubject:(UIButton*)sender {
    if ([[[self getTextFieldForButton:sender] text] length] > 0) {
        flag = FALSE;
//        [self resignAllTextField];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y + 35, footerView.frame.size.width, footerView.frame.size.height);
        containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height + 35);
        mainScrollView.contentSize = CGSizeMake(WIDTH, mainScrollView.contentSize.height + 35);
        UITextField *sampleTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(10, sender.frame.origin.y + 30 + 10, WIDTH - 20 - 45, 20)];
        sampleTextFiled.returnKeyType = UIReturnKeyDone;
        sampleTextFiled.tag = sender.tag + 1;
        [sampleTextFiled setTextColor:[UIColor whiteColor]];
        sampleTextFiled.delegate = self;
        NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Enter the subject"];
        [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:PLACEHOLDER_COLOR] range:NSMakeRange(0,@"Enter the subject".length)];
        [sampleTextFiled setAttributedPlaceholder:tempString];
        tempString = nil;
        [containerView addSubview:sampleTextFiled];
        [sampleTextFiled becomeFirstResponder];
        [textFieldArray addObject:sampleTextFiled];
        sampleTextFiled = nil;
        UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 30 - 10, sender.frame.origin.y + 30 + 5, 30, 30)];
        sampleButton.tag = sender.tag + 1;
        [sampleButton setBackgroundColor:[UIColor clearColor]];
        [sampleButton addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
        [sampleButton setImage:[UIImage imageNamed:@"addIcon_white_22x22.png"] forState:UIControlStateNormal];
        [sampleButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [containerView addSubview:sampleButton];
        [editButtonArray addObject:sampleButton];
        sampleButton = nil;
        [UIView commitAnimations];
        [sender removeTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
        [sender addTarget:self action:@selector(deleteSubject:) forControlEvents:UIControlEventTouchUpInside];
        [sender setImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)deleteSubject:(UIButton *)sender {
    [self resignAllTextField];
    [[self getTextFieldForButton:sender] removeFromSuperview];
    [sender removeFromSuperview];
    [textFieldArray removeObjectIdenticalTo:[self getTextFieldForButton:sender]];
    [editButtonArray removeObjectIdenticalTo:sender];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self moveElementsBelowButton:sender];
    footerView.frame = CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y - 35, footerView.frame.size.width, footerView.frame.size.height);
    containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y, containerView.frame.size.width, containerView.frame.size.height - 35);
    mainScrollView.contentSize = CGSizeMake(WIDTH, mainScrollView.contentSize.height - 35);
    [UIView commitAnimations];
    [sender removeTarget:self action:@selector(deleteSubject:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(addSubject:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)advanceButtonClicked:(UIButton*)sender {
    if (advanceFlag) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        containerView.frame = CGRectMake(0, containerView.frame.origin.y, containerView.frame.size.width, 50);
        [UIView commitAnimations];
        advanceFlag = FALSE;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        containerView.frame = CGRectMake(0, containerView.frame.origin.y, containerView.frame.size.width, innerY);
        [UIView commitAnimations];
        advanceFlag = TRUE;
    }
}

- (void)cancelButtonPressed:(UIButton*)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_VIP_ENABLED) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)saveButtonPressed:(UIButton*)sender {
    
    if (senderArray) {
        senderArray = nil;
    }
    senderArray = [[NSMutableArray alloc] init];
    
    for (ContactModel *tempContact in contactMutableArray) {
        if ([tempContact.name isEqualToString:ADD_FUNNL] || [tempContact.email isEqualToString:@""]) {
            
        }
        else {
            [senderArray addObject:tempContact.email];
        }
    }
    
    if (subjectArray) {
        subjectArray = nil;
    }
    subjectArray = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"Save Butoon pressed");
    
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Created a new Funnl or modified existing Funnl"];
#endif
    
    NSString *funnlName = funnelNameTextField.text;
    if(funnelNameTextField.text.length){
        int validCode = [self validateFunnelName:funnlName];
        if (validCode != 1) {
            if (validCode == 2) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_REPEATED message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [appDelegate.progressHUD setHidden:YES];
                [appDelegate.progressHUD removeFromSuperview];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            }
            else if (validCode == 3) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:FUNNEL_NAME_BLANK message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                alertView = nil;
                [appDelegate.progressHUD setHidden:YES];
                [appDelegate.progressHUD removeFromSuperview];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
            }
            return;
        }
        if((contactMutableArray.count > 1 || (![[(ContactModel *)[contactMutableArray objectAtIndex:0] name] isEqualToString:ADD_FUNNL] && contactMutableArray.count == 1)) || subjectArray.count){
            [self performSelectorInBackground:@selector(showHUD) withObject:nil];
            if (!enableNotification) {
                [self saveFunnlWithWebhookId:nil];
            } else {
                if (senderArray.count) {
                    [self createWebhooksAndSaveFunnl];
                }
                else {
                    [self saveFunnlWithWebhookId:nil];
                }
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnel" message:@"Please add at least one email or subject" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            alert = nil;
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Funnel" message:@"Please add name for Funnel" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    /*[appDelegate.progressHUD setHidden:YES];
    [appDelegate.progressHUD removeFromSuperview];
    [MBProgressHUD hideHUDForView:appDelegate.window animated:YES];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

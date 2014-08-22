//
//  VIPCreateFunnelViewController.m
//  VIPFunnel
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "VIPCreateFunnelViewController.h"
#import "AppDelegate.h"

@interface VIPCreateFunnelViewController ()

@end

@implementation VIPCreateFunnelViewController

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
    buttonArray = [[NSMutableArray alloc] init];
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    // Do any additional setup after loading the view.
    UIBarButtonItem *sampleBarButton = [[UIBarButtonItem alloc] init];
    [sampleBarButton setTitle:@"Cancel"];
    [self.navigationItem setLeftBarButtonItem:sampleBarButton];
    sampleBarButton = nil;
    
    sampleBarButton = [[UIBarButtonItem alloc] init];
    [sampleBarButton setTitle:@"Save"];
    [self.navigationItem setLeftBarButtonItem:sampleBarButton];
    sampleBarButton = nil;
    [self setUpCustomNavigationBar];
    [self setUpViewForCreatingFunnel];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark -
#pragma mark Helper
- (void)setUpViewForCreatingFunnel {
    int y = 0;
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 22, WIDTH, HEIGHT - self.navigationController.navigationBar.frame.size.height)];
    [mainScrollView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    
    UILabel *sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 125, 40)];
    [sampleLAbel setTextAlignment:NSTextAlignmentLeft];
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    sampleLAbel.text = @"Funnel Name";
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    funnelNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 0, WIDTH - 125 - 10, 40)];
    funnelNameTextField.text = @"VIP";
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
    int label_height = 25;
    float color = 255;
    
    UIFont *labelFont = [UIFont boldSystemFontOfSize:15];
    
    for (int counter = 0; counter < 9 && counter < contactMutableArray.count; counter++) {
        if (counter > 0)
            color = 255/(counter*2);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[(ContactModel*)[contactMutableArray objectAtIndex:counter] thumbnail]]];
        [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        fetcher.comment = [NSString stringWithFormat:@"%d",counter];
        GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
        [fetcher setAuthorizer:currentAuth];
        [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
        
        
        if (counter % 3 == 0) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
            
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString
                                                                   ]] forState:UIControlStateNormal];
            tempButton.tag = counter;
            NSArray *randomColors = GRADIENT_ARRAY;
            NSInteger gradientInt = randomColors.count - 1;
            NSString *colorString = [randomColors objectAtIndex:gradientInt];
            UIColor *color = [UIColor colorWithHexString:colorString];
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [mainScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + buttonSize + 5, buttonSize, label_height)];
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            //            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [mainScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 1) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y, buttonSize, buttonSize)];
            tempButton.tag = counter;
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            NSArray *randomColors = GRADIENT_ARRAY;
            NSInteger gradientInt = randomColors.count - 1;
            NSString *colorString = [randomColors objectAtIndex:gradientInt];
            UIColor *color = [UIColor colorWithHexString:colorString];
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [mainScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y + buttonSize + 5, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            //            sampleLabel.numberOfLines = 2;
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
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            NSArray *randomColors = GRADIENT_ARRAY;
            NSInteger gradientInt = randomColors.count - 1;
            NSString *colorString = [randomColors objectAtIndex:gradientInt];
            UIColor *color = [UIColor colorWithHexString:colorString];
            [tempButton setBackgroundColor:color];
            
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [mainScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y + buttonSize + 5, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
            //            sampleLabel.numberOfLines = 2;
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
    [mainScrollView addSubview:notificationEnableSwitch];
    notificationEnableSwitch = nil;
    
    y = y + 20 + 20;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    sampleView = nil;
    
    y = y + 1 + 10;
    
    sampleLAbel = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 40)];
    sampleLAbel.text = @"Subject (Optional):";
    [sampleLAbel setTextColor:[UIColor whiteColor]];
    [sampleLAbel setBackgroundColor:[UIColor clearColor]];
    [sampleLAbel setFont:[UIFont boldSystemFontOfSize:20]];
    [mainScrollView addSubview:sampleLAbel];
    sampleLAbel = nil;
    
    y = y + 40 + 10;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 1)];
    [sampleView setBackgroundColor:[UIColor lightGrayColor]];
    [mainScrollView addSubview:sampleView];
    sampleView = nil;
    
    y = y + 1 + 20;
    
    subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, y, 300, 20)];
    [subjectTextField setPlaceholder:@"Enter the subject"];
    subjectTextField.returnKeyType = UIReturnKeyDone;
    subjectTextField.delegate = self;
    [subjectTextField setTextColor:[UIColor whiteColor]];
    [mainScrollView addSubview:subjectTextField];
    
    [self.view addSubview:mainScrollView];
    [mainScrollView setContentSize:CGSizeMake(WIDTH, y)];
}

- (void)setUpCustomNavigationBar {
    UIView *naviGationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
    [naviGationBar setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 22, 100, 44)];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [sampleButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 100, 40)];
    [sampleLabel setTextAlignment:NSTextAlignmentCenter];
    sampleLabel.text = @"Create Funnl";
    [sampleLabel setTextColor:[UIColor whiteColor]];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    [mainScrollView addSubview:sampleLabel];
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
    [mainScrollView setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [mainScrollView setContentOffset:CGPointMake(0, 200)];
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
- (void)cancelButtonPressed:(UIButton*)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_FUNNEL_POP_UP_ENABLE) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)saveButtonPressed:(UIButton*)sender {
//    VIPFunnelCreationConfirmationController *viewController = [[VIPFunnelCreationConfirmationController alloc] initWithContacts:contactMutableArray];
//    [self.navigationController pushViewController:viewController animated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_FUNNEL_POP_UP_ENABLE) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
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

//
//  FMContactDetailViewController.m
//  FunnlMail
//
//  Created by shrinivas on 05/09/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FMContactDetailViewController.h"
#import "UIView+Toast.h"

@interface FMContactDetailViewController ()

@end

@implementation FMContactDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMessage:(MCOAddress *)address {
    self = [super init];
    if (self) {
        // Custom initialization
        selectedAddress = address;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    selectedContact = [self getUserName:selectedAddress.mailbox];
    [self drawView];
}

#pragma mark -
#pragma mark Helper 
- (ContactModel *)getUserName:(NSString *)emailAddress {
    NSArray *contactArray = [[ContactService instance] retrieveAllContact];
    for (ContactModel *tempContact in contactArray) {
        if ([tempContact.email isEqualToString:emailAddress]) {
            return tempContact;
        }
    }
    return nil;
}

- (void)drawView {
    
    UIFont *normalFont = [UIFont systemFontOfSize:14];
    
    int y = 0;
    y = y + 66 + 20;
    UILabel *sampleLabel = nil;
    
    [self.view addSubview:sampleLabel];
    sampleLabel = nil;
    if (selectedContact.thumbnail.length) {
        NSLog(@"%@",selectedContact.thumbnail);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:selectedContact.thumbnail]];
        [request setValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        GTMOAuth2Authentication *currentAuth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:kMyClientID clientSecret:kMyClientSecret];
        [fetcher setAuthorizer:currentAuth];
        [fetcher beginFetchWithDelegate:self didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
        
        contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, y, 60, 60)];
        [contactImageView setImage:[UIImage imageNamed:@"userPlaceholder.png"]];
        contactImageView.clipsToBounds = YES;
        contactImageView.layer.cornerRadius = 30;
        [contactImageView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:contactImageView];
        
        sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35 + 60 + 10, y, WIDTH - 20 - 35 - 60 - 10, 30)];
        [sampleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        if (selectedAddress.displayName) {
            sampleLabel.text = selectedAddress.displayName;
        }
        else {
            sampleLabel.text = selectedAddress.mailbox;
        }
        
        [self.view addSubview:sampleLabel];
        sampleLabel = nil;
        
        y = y + 60 + 10;
    }
    else {
        sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, y, WIDTH - 70, 30)];
        [sampleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        if (selectedAddress.displayName) {
            sampleLabel.text = selectedAddress.displayName;
        }
        else {
            sampleLabel.text = selectedAddress.mailbox;
        }
        
        [self.view addSubview:sampleLabel];
        sampleLabel = nil;
        
        y = y + 30 + 10;
    }
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(35, y, WIDTH - 35, 0.5)];
    [sampleView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:sampleView];
    sampleView = nil;
    
    y = y + 0.5 + 10;
    
    sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, y, WIDTH - 35, 20)];
    [sampleLabel setFont:normalFont];
    [sampleLabel setTextColor:[UIColor blueColor]];
    sampleLabel.text = @"Email";
    [self.view addSubview:sampleLabel];
    sampleLabel = nil;
    
    y = y + 20;
    
//    UITextField *sampleTextField = [[UITextField alloc] initWithFrame:CGRectMake(35, y, WIDTH - 35, 20)];
//    sampleTextField.delegate = self;
//    [sampleTextField setFont:normalFont];
//    sampleTextField.text = selectedContact.email;
//    [self.view addSubview:sampleTextField];
//    sampleTextField = nil;
    
    emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, y, WIDTH - 35, 20)];
    [emailLabel setFont:normalFont];
    [emailLabel setTextColor:[UIColor blackColor]];
    emailLabel.text = selectedAddress.mailbox;
    UILongPressGestureRecognizer *tempGuesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(emailLongPress:)];
    tempGuesture.minimumPressDuration = 0.5;
    tempGuesture.numberOfTapsRequired = 0;
    [emailLabel setUserInteractionEnabled:YES];
    [emailLabel addGestureRecognizer:tempGuesture];
    tempGuesture = nil;
    [self.view addSubview:emailLabel];
}

#pragma mark -
#pragma mark Delegate 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}

- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        
    }
    else {
        [contactImageView setImage:[UIImage imageWithData:imageData]];
    }
}

- (void)emailLongPress:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:emailLabel.text];
    [self.view showToast:[self tostViewForOperation:1] duration:TOST_DISPLAY_DURATION position:@"bottom"];
}

- (UIView*)tostViewForOperation:(int)operation {
    
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    returnView.clipsToBounds = YES;
    returnView.layer.cornerRadius = 2;
    [returnView setBackgroundColor:[UIColor colorWithWhite:COLOR_OF_WHITE alpha:ALPHA_FOR_TOST]];
    
    UILabel *sampleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [sampleLable setTextAlignment:NSTextAlignmentCenter];
    [sampleLable setFont:[UIFont systemFontOfSize:14]];
    [sampleLable setTextColor:[UIColor whiteColor]];
    [sampleLable setBackgroundColor:[UIColor clearColor]];
    sampleLable.text = @"Text colpied to clipboard.";
    [returnView addSubview:sampleLable];
    sampleLable = nil;
    
    return returnView;
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

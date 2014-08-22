//
//  VIPViewController.m
//  VIPFunnelCreationOptions
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "VIPViewController.h"
#import "AppDelegate.h"
#import "ContactService.h"
#import "ContactModel.h"
@interface VIPViewController ()

@end

@implementation VIPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedContact = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6]];
    [self retrieveContact];
    [self setUpView];
}

- (void)viewWillAppear:(BOOL)animated {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark -
#pragma mark Helper
- (void)setUpView {
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, WIDTH - 20, 95 - 30)];
    [sampleLabel setBackgroundColor:[UIColor clearColor]];
    sampleLabel.text = @"To help you organise better, we have identified some key sender in your indox!";
    sampleLabel.numberOfLines = 3;
    [sampleLabel setTextColor:[UIColor whiteColor]];
    sampleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [sampleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.view addSubview:sampleLabel];
    sampleLabel = nil;
    
    if (!buttonArray) {
        buttonArray = [[NSMutableArray alloc] init];
    }
    
    UIScrollView *sampleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 110, WIDTH, HEIGHT - 110 - 100)];
    [sampleScrollView setBackgroundColor:[UIColor clearColor]];
    
    float buttonSize = 75.0;
    int margin = 40;
//    int xMargine = 10;
    int x = 10;
//    int yMargine = 10;
    int y = 10;
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
            [tempButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            NSArray *randomColors = GRADIENT_ARRAY;
            NSInteger gradientInt = randomColors.count - 1;
            NSString *colorString = [randomColors objectAtIndex:gradientInt];
            UIColor *color = [UIColor colorWithHexString:colorString];
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [sampleScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y + buttonSize + 5, buttonSize, label_height)];
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setTextColor:[UIColor whiteColor]];
//            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [sampleScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 1) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y, buttonSize, buttonSize)];
            tempButton.tag = counter;
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
            [tempButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            NSArray *randomColors = GRADIENT_ARRAY;
            NSInteger gradientInt = randomColors.count - 1;
            NSString *colorString = [randomColors objectAtIndex:gradientInt];
            UIColor *color = [UIColor colorWithHexString:colorString];
            
            [tempButton setBackgroundColor:color];
            tempButton.clipsToBounds = YES;
            tempButton.layer.cornerRadius = buttonSize/2.0;
            tempButton.layer.borderColor = [[UIColor clearColor] CGColor];
            tempButton.layer.borderWidth = BUTTON_BORDER_WIDTH_VIP;
            [sampleScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake((WIDTH / 2) - buttonSize / 2, y + buttonSize + 5, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
//            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [sampleScrollView addSubview:sampleLabel];
            sampleLabel = nil;
        }
        else if (counter % 3 == 2) {
            UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y, buttonSize, buttonSize)];
            [tempButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
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
            [sampleScrollView addSubview:tempButton];
            [buttonArray addObject:tempButton];
            
            UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 10 - buttonSize, y + buttonSize + 5, buttonSize, label_height)];
            [sampleLabel setTextColor:[UIColor whiteColor]];
//            sampleLabel.numberOfLines = 2;
            sampleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            sampleLabel.text = [[contactMutableArray objectAtIndex:counter] name];
            [sampleLabel setFont:labelFont];
            [sampleLabel setTextAlignment:NSTextAlignmentCenter];
            [sampleScrollView addSubview:sampleLabel];
            sampleLabel = nil;
            
            y = y + buttonSize + margin;
        }
    }
    [sampleScrollView setContentSize:CGSizeMake(WIDTH, y)];
    [self.view addSubview:sampleScrollView];
    sampleScrollView = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH - 165.0) / 2.0, HEIGHT - 100 + 15, 165, 25)];
    [sampleButton setTitle:@"Add to Funnl" forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    sampleButton.clipsToBounds = YES;
    sampleButton.layer.cornerRadius = 5.0;
    sampleButton.layer.borderWidth = 1.0;
    sampleButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [sampleButton addTarget:self action:@selector(pushCreateFunnelViewController:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sampleButton];
    sampleButton = nil;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT - 100 + 15 + 25 + 15, WIDTH, 15)];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"Remind Later" attributes:underlineAttribute];
    [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, @"Remind Later".length)];
    [sampleButton setAttributedTitle:tempString forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(remindMeLaterPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sampleButton];
    sampleButton = nil;
    tempString = nil;
    underlineAttribute = nil;
}
#pragma mark -
#pragma mark Delegate
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
- (void)contactButtonPressed:(UIButton*)sender {
    if ([selectedContact containsObject:[contactMutableArray objectAtIndex:sender.tag]]) {
        [selectedContact removeObjectIdenticalTo:[contactMutableArray objectAtIndex:sender.tag]];
        sender.layer.borderColor = [[UIColor clearColor] CGColor];
    }
    else {
        [selectedContact addObject:[contactMutableArray objectAtIndex:sender.tag]];
        sender.layer.borderColor = [[UIColor colorWithHexString:BUTTON_BORDER_COLOR_SELECTED] CGColor];
    }
}

- (void)pushCreateFunnelViewController:(UIButton*)sender {
    if (selectedContact.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please select atleast one contact to create funnel." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    }
    else {
        VIPCreateFunnelViewController *viewControllerToBePushed = [[VIPCreateFunnelViewController alloc] initWithSelectedContactArray:selectedContact];
        [self.navigationController pushViewController:viewControllerToBePushed animated:YES];
    }
}

- (void)remindMeLaterPressed:(UIButton*)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_FUNNEL_POP_UP_ENABLE) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)retrieveContact {
    NSArray *contactArray = [[ContactService instance] retrieveAllContact];
    NSLog(@"number of contact ---> %d",contactArray.count);
    for (ContactModel *tempContact in contactArray) {
        if (tempContact.name && tempContact.email && ![tempContact.name isEqualToString:@""]) {
            if (!contactMutableArray) {
                contactMutableArray = [[NSMutableArray alloc] init];
            }
            [contactMutableArray addObject:tempContact];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

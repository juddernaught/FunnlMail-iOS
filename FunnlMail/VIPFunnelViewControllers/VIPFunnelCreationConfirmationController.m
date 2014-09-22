//
//  VIPFunnelCreationConfirmationController.m
//  FunnlMail
//
//  Created by Macbook on 22/08/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "VIPFunnelCreationConfirmationController.h"
#import "AppDelegate.h"
#import "FXBlurView.h"

@interface VIPFunnelCreationConfirmationController ()

@end

@implementation VIPFunnelCreationConfirmationController

#pragma mark -
#pragma mark Lifecycle
- (id)initWithContacts:(NSMutableArray*)contacts
{
    self = [super init];
    if (self) {
        // Custom initialization
        contactMutableArray = contacts;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.5]];
    [self applyBackgroundImage];
    [self setView];
//    [self performSelectorInBackground:@selector(setView) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated {

    [self.view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.5]];
//    [self.view setBackgroundColor:[UIColor blackColor]];
}

#pragma mark -
#pragma mark Helper
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
    backgroundView.tintColor = [UIColor grayColor];
    backgroundView.blurRadius = 10;
    [self.view addSubview:backgroundView];
    backgroundView = nil;
    [backgroundView setUserInteractionEnabled:YES];
    backgroundView = nil;
}

- (void)setView {
    UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [backGroundView setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.5]];
    [self.view addSubview:backGroundView];
    
    backGroundView = nil;
    UILabel *sampleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, WIDTH, 44)];
    [sampleLabel setTextAlignment:NSTextAlignmentCenter];
    sampleLabel.text = @"Funnl successfully Created!";
    [sampleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [sampleLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:sampleLabel];
    sampleLabel = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, WIDTH, 1)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:sampleView];
    sampleView = nil;
    
    int y1 = 66 + 15;
    
    UIImageView *sampleImage = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH - 270/2)/2, y1, 270/2, 200/2)];
    [sampleImage setImage:[UIImage imageNamed:@"funnl.png"]];
    [sampleImage setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:sampleImage];
    sampleImage = nil;
    
    y1 = y1 + 100 + 20;
    
    float buttonSize = 75.0;
    int margin = 40;
    int x = 10;
    int y = 10;
    int label_height = 40;
    float color = 255;
    
    UIFont *labelFont = REGULAR_FONT_12;
    
    UIScrollView *mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y1, WIDTH, HEIGHT - y1 - 100)];
    [mainScrollView setBackgroundColor:[UIColor clearColor]];
    for (int counter = 0; counter < 9 && counter < contactMutableArray.count; counter++) {
        if (counter > 0)
            color = 255/(counter*2);
        unsigned long temp = counter % 8;
        NSArray *randomColors = GRADIENT_ARRAY;
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
            
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString
                                                                   ]] forState:UIControlStateNormal];
            tempButton.tag = counter;
//            NSArray *randomColors = GRADIENT_ARRAY;
//            NSInteger gradientInt = randomColors.count - 1;
//            NSString *colorString = [randomColors objectAtIndex:gradientInt];
//            UIColor *color = [UIColor colorWithHexString:colorString];
            
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
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
//            NSArray *randomColors = GRADIENT_ARRAY;
//            NSInteger gradientInt = randomColors.count - 1;
//            NSString *colorString = [randomColors objectAtIndex:gradientInt];
//            UIColor *color = [UIColor colorWithHexString:colorString];
            
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
            [tempButton setTitle:[NSString stringWithFormat:@"%@",[[[(ContactModel*)[contactMutableArray objectAtIndex:counter] name] substringWithRange:NSMakeRange(0, 1)] uppercaseString]] forState:UIControlStateNormal];
//            NSArray *randomColors = GRADIENT_ARRAY;
//            NSInteger gradientInt = randomColors.count - 1;
//            NSString *colorString = [randomColors objectAtIndex:gradientInt];
//            UIColor *color = [UIColor colorWithHexString:colorString];
            
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
    
    [mainScrollView setContentSize:CGSizeMake(WIDTH, y)];
    
    [self.view addSubview:mainScrollView];
    mainScrollView = nil;
    
    sampleView = [[UIView alloc] initWithFrame:CGRectMake(10, HEIGHT - 100, WIDTH - 20, 1)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:sampleView];
    sampleView = nil;
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH - 165.0) / 2.0, HEIGHT - 100 + 15, 165, 25)];
    [sampleButton setTitle:@"Create another Funnl" forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    sampleButton.clipsToBounds = YES;
    sampleButton.layer.cornerRadius = 5.0;
    sampleButton.layer.borderWidth = 1.0;
    sampleButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    [sampleButton addTarget:self action:@selector(popToRootView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sampleButton];
    sampleButton = nil;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT - 100 + 15 + 25 + 15, WIDTH, 15)];
    [sampleButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    NSMutableAttributedString *tempString = [[NSMutableAttributedString alloc] initWithString:@"I'm done" attributes:underlineAttribute];
    [tempString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, @"I'm done".length)];
    [sampleButton setAttributedTitle:tempString forState:UIControlStateNormal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(remindMeLaterPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sampleButton];
    
}
- (void)setUpCustomNavigationBar {
    UIView *naviGationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 66)];
//    [naviGationBar setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    
    UIButton *sampleButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 100 - 10, 22, 100, 44)];
    [sampleButton setTitle:@"Done" forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [sampleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [naviGationBar addSubview:sampleButton];
    sampleButton = nil;
    
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 1)];
    [sampleView setBackgroundColor:[UIColor whiteColor]];
    [naviGationBar addSubview:sampleView];
    sampleView = nil;
    
    [self.view addSubview:naviGationBar];
}

#pragma mark -
#pragma mark DELEGATE
- (void)imageFetcher:(GTMHTTPFetcher *)imageFetcher finishedWithData:(NSData *)imageData error:(NSError *)error {
    if (error) {
        NSLog(@"Error");
    }
    else {
        NSLog(@"--------> %@",imageFetcher.comment);
        UIButton *tempButton = [buttonArray objectAtIndex:[imageFetcher.comment integerValue]];
        [tempButton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        [tempButton setBackgroundColor:[UIColor clearColor]];
        [tempButton setTitle:@"" forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark Event Handler 
- (void)remindMeLaterPressed:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"VIP_FUNNL_APPERANCE"];
    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
    if (IS_VIP_ENABLED) {
        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
    }
}

- (void)popToRootView:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(UIButton*)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    AppDelegate *tempAppDelegate = [[UIApplication sharedApplication] delegate];
//    if (IS_VIP_ENABLED) {
//        [tempAppDelegate performSelector:@selector(loadVIPFunnelViewController) withObject:nil afterDelay:kVIP_FUNNEL_POP_UP_DISPLY_INTERVAL];
//    }
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

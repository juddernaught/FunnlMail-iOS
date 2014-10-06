//
//  SPFirstViewController.m
//  SampleProject
//
//  Created by shrinivas on 25/09/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import "SPFirstViewController.h"
#import "AppDelegate.h"
#import "MessageService.h"
#import <Mixpanel/Mixpanel.h>
#import "FMFunnlStoreViewController.h"

@implementation SPFirstViewController

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"outter_tutorial"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
    /*if ([[NSUserDefaults standardUserDefaults] boolForKey:@"outter_tutorial"]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }*/
}

-(id)init{
    self = [super init];
    if(self){
    }
    return self;
}    

-(void)setupView{
    self.view.frame = [[UIScreen mainScreen] bounds];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    pageNumber = 1;
    imageArray = [[NSArray alloc] initWithObjects:@"", nil];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 568)];
    [imageView setImage:[UIImage imageNamed:[self formImageString:pageNumber]]];
    [self.view addSubview:imageView];
    [self performSelector:@selector(addFeatureToSliderWithPageNo:) withObject:[NSNumber numberWithInt:pageNumber] afterDelay:TIME_FOR_ANIMATION];
    nextButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 50, HEIGHT/2 - 25, 50, 50)];
    [self.view addSubview:nextButton];
    [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
    textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
    [self.view addSubview:textImage];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"outter_tutorial"]) {
        skipToPrimaryButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH - 180)/2, HEIGHT - 50, 180, 35)];
        [skipToPrimaryButton setImage:[UIImage imageNamed:@"IntroTakeMeToInbox.png"] forState:UIControlStateNormal];
        [skipToPrimaryButton addTarget:self action:@selector(skipTOPrimaryPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:skipToPrimaryButton];
    }
}

- (void)viewDidLoad {
    [self setupView];

    //    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    //    halo = layer;
    //    halo.position = nextButton.center;
    //    [self.view.layer insertSublayer:halo below:nextButton.layer];
    
}

- (NSString *)formImageString:(int)pageNo {
    NSString *returnString = [NSString stringWithFormat:@"%@%02d.png",IMAGE_NAME,pageNo];
    return returnString;
}

- (NSString *)formImageText:(int)pageNo {
    NSString *returnString = [NSString stringWithFormat:@"%@%02d.png",IMAGE_TEXT,pageNo];
    return returnString;
}

- (void)addFeatureToSliderWithPageNo:(NSNumber *)pageNo {
    if (pageNo.integerValue >= 1 && pageNo.integerValue < 11) {
        if (pageNo.integerValue == 1) {
            UIView *tapHere = [[UIView alloc] initWithFrame:CGRectMake(WIDTH - 46, HEIGHT/2 - 8, 165, 165)];
            
            UIImageView *tapHereImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-here"]];
            [tapHere addSubview:tapHereImageView];
            [self.view addSubview:tapHere];
        }
        PulsingHaloLayer *layer = [PulsingHaloLayer layer];
        halo = layer;
        halo.pulseInterval = 0;
        halo.useTimingFunction = YES;
        halo.animationDuration = 1;
        halo.fromValueForAlpha = 0.9;
        if (pageNo.intValue == 7) {
            halo.radius = 30;
        }
        else
            halo.radius = 50;
        halo.position = nextButton.center;
        [self.view.layer insertSublayer:halo below:nextButton.layer];
    }
    switch ([pageNo integerValue]) {
        case 1:
            nextButton.tag = 1;
            nextButton.backgroundColor = [UIColor clearColor];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
//            [UIView animateWithDuration:TIME_FOR_FADE_IN
//                             animations:^{
//                                 nextButton.alpha = 1;
//                                 textImage.alpha = 1;
//                             }
//                             completion:^(BOOL finished){
//                                 NSLog(@"completion block");
//                             }];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 2:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(350/2.0 - 25, 227, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 2;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 3:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(240/2 - 25, 227, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 3;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 4:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(444/2 - 25, 227, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 4;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 5:
            halo.animationDuration = 0.7;
            [halo setBackgroundColor:[[UIColor colorWithHexString:@"757CFD"] CGColor]];
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(245.0/2.0 - 25, HEIGHT/2 - 30, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 5;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 6:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(180/2 - 25, 504/2 - 25, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 6;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 7:{
            if (nextButton) {
                nextButton = nil;
            }
            UIScrollView *sampleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(113.0/2.0, 268, 420/2, 120/2)];
            sampleScrollView.delegate = self;
            [sampleScrollView setBackgroundColor:[UIColor greenColor]];
            
            UIImageView *sampleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 210, 60)];
            [sampleImageView setImage:[UIImage imageNamed:@"leftCell.png"]];
            [sampleScrollView addSubview:sampleImageView];
            sampleImageView = nil;
            
            sampleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(210, 0, 210, 60)];
            [sampleImageView setImage:[UIImage imageNamed:@"rightCell.png"]];
            [sampleScrollView addSubview:sampleImageView];
            sampleImageView = nil;
            
            [self.view addSubview:sampleScrollView];
            
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(460/2 + 40, 590/2 - 25, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 7;
            nextButton.backgroundColor = [UIColor clearColor];
            nextButton.alpha = 0;
            nextButton.hidden = YES;

            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            sampleScrollView.contentSize = CGSizeMake(420, 60);
            sampleScrollView.bounces = NO;
            [sampleScrollView setShowsHorizontalScrollIndicator:NO];
            
            [self.view addSubview:textImage];
//            [self.view addSubview:nextButton];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            //nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
//            [self.view bringSubviewToFront:nextButton];
            break;
        }
        case 8:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(490/2 - 25, 506/2 - 25, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 8;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 9:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 50, HEIGHT/2 - 25, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 9;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            textImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 190/2, WIDTH, 70)];
            [textImage setImage:[UIImage imageNamed:[self formImageText:pageNumber]]];
            [self.view bringSubviewToFront:textImage];
            [textImage setContentMode:UIViewContentModeTop];
            textImage.alpha = 0;
            
            nextButton.frame = CGRectMake(160 - 25, 190/2, 50, 50);
            
            [self.view addSubview:nextButton];
            [self.view addSubview:textImage];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 10:
            if (nextButton) {
                nextButton = nil;   
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 50, HEIGHT/2 - 25, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 10;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            nextButton.frame = CGRectMake(160 - 25, 190/2, 50, 50);
            [self.view addSubview:nextButton];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            //            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        case 11:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"outter_tutorial"]) {
                
            }
            else {
                if (nextButton) {
                    nextButton = nil;
                }
                nextButton = [[UIButton alloc] initWithFrame:CGRectMake((WIDTH - 180)/2, HEIGHT - 50, 180, 35)];
                [nextButton setImage:[UIImage imageNamed:@"IntroTakeMeToInbox.png"] forState:UIControlStateNormal];
                [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
                nextButton.tag = 11;
                nextButton.backgroundColor = [UIColor clearColor];
                [self.view bringSubviewToFront:nextButton];
                nextButton.alpha = 0;
                
                if (textImage) {
                    textImage = nil;
                }
                
                [self.view addSubview:nextButton];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:TIME_FOR_FADE_IN];
                nextButton.alpha = 1;
                textImage.alpha = 1;
                [UIView commitAnimations];
            }
            break;
        case 12:
            if (nextButton) {
                nextButton = nil;
            }
            nextButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 50, HEIGHT/2 - 25, 50, 50)];
            [nextButton addTarget:self action:@selector(nextButtonPresed:) forControlEvents:UIControlEventTouchUpInside];
            nextButton.tag = 12;
            nextButton.backgroundColor = [UIColor clearColor];
            [self.view bringSubviewToFront:nextButton];
            nextButton.alpha = 0;
            
            if (textImage) {
                textImage = nil;
            }
            
            [self.view addSubview:nextButton];
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:TIME_FOR_FADE_IN];
            nextButton.alpha = 1;
            //            textImage.alpha = 1;
            [UIView commitAnimations];
            break;
        default:
            break;
    }
    if ((pageNo.integerValue >= 1 && pageNo.integerValue < 11) && pageNo.integerValue != 7) {
        halo.hidden = NO;
        halo.position = nextButton.center;
    }
    else {
        halo.hidden = YES;
    }
}

- (void)skipTOPrimaryPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonPresed:(UIButton *)sender {
    int tag = (int)sender.tag;
    if (tag < 11) {
        NSArray *tempArray = [self.view subviews];
        for (UIView *sampleView in tempArray) {
            [sampleView removeFromSuperview];
        }
        textImage.hidden = YES;
        nextButton.hidden = YES;
        pageNumber = tag + 1;
        [imageView setImage:[UIImage imageNamed:[self formImageString:pageNumber]]];
        [imageView removeFromSuperview];
        [self.view addSubview:imageView];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"outter_tutorial"]) {
            [skipToPrimaryButton removeFromSuperview];
            [self.view addSubview:skipToPrimaryButton];
        }
        [self performSelector:@selector(addFeatureToSliderWithPageNo:) withObject:[NSNumber numberWithInt:pageNumber] afterDelay:TIME_FOR_ANIMATION];
    }
    else {
        
        NSLog(@"Write dismissing pop up");
        AppDelegate *appDelegate = APPDELEGATE;
        BOOL isFromLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"outter_tutorial"];
        if(appDelegate.isFreshInstall == NO &&  isFromLogin == NO) {
            [[Mixpanel sharedInstance] track:@"first time user finished tutorial"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_FRESH_INSTALL"];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"is_tutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadInitActivity];
        //[self dismissViewControllerAnimated:YES completion:^{ [self loadInitActivity]; }];
    }
}

-(void)loadInitActivity{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.view setHidden:YES];
    [appDelegate.window setRootViewController:appDelegate.drawerController];
    [appDelegate.window makeKeyAndVisible];
#ifdef TRACK_MIXPANEL
    //[[Mixpanel sharedInstance] track:@"Viewed last slider"];
#endif
}

- (void)trackProgress:(UISlider *)statusBar {
    if (statusBar.value < SLIDER_VALUE) {
        statusBar.value = 0;
        UIButton *sender = [[UIButton alloc] init];
        sender.tag = 7;
        [self nextButtonPresed:sender];
    }
    halo.position = CGPointMake([self xPositionFromSliderValue:slider], 570/2 + 1);
}

- (float)xPositionFromSliderValue:(UISlider *)aSlider;
{
    float sliderRange = aSlider.frame.size.width - aSlider.currentThumbImage.size.width;
    float sliderOrigin = aSlider.frame.origin.x + (aSlider.currentThumbImage.size.width / 2.0);
    
    float sliderValueToPixels = (((aSlider.value-aSlider.minimumValue)/(aSlider.maximumValue-aSlider.minimumValue)* sliderRange) + sliderOrigin);
    
    return sliderValueToPixels;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.x > 105) {
        [UIView animateWithDuration:.25
                         animations:^{
                             scrollView.contentOffset = CGPointMake(210, 0);
                         }
                         completion:^(BOOL finished){
                             NSLog(@"completion block");
                             UIButton *tempButton = [[UIButton alloc] init];
                             tempButton.tag = 7;
                             [self nextButtonPresed:tempButton];
                             tempButton = nil;
                         }];
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        scrollView.contentOffset = CGPointMake(0, 0);
        [UIView commitAnimations];
    }
}

@end

//
//  SPFirstViewController.h
//  SampleProject
//
//  Created by shrinivas on 25/09/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PulsingHaloLayer.h"

@interface SPFirstViewController : UIViewController
{
    UIImageView *imageView;
    UIImageView *textImage;
    UIButton *nextButton;
    NSArray *imageArray;
    PulsingHaloLayer *halo;
    int pageNumber;
    UISlider *slider;
    UIButton *skipToPrimaryButton;
}
@end

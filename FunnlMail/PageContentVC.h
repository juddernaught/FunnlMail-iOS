//
//  PageContentVC.h
//  FunnlMail
//
//  Created by Pranav Herur on 8/1/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentVC : UIViewController
@property (assign, nonatomic) NSInteger index;
-(PageContentVC*) initWithImage: (NSString *)image;
@end

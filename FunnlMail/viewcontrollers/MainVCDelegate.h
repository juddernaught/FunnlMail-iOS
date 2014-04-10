//
//  MainVCDelegate.h
//  FunnlMail
//
//  Created by Michael Raber on 4/9/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterModel.h"

@protocol MainVCDelegate <NSObject>

-(void) filterSelected:(FilterModel *)filterModel;
-(void) pushViewController:(UIViewController *)viewController;

@end

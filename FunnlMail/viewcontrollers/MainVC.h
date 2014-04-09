//
//  MainVC.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterView.h"
#import "MainView.h"
#import "MainVCDelegate.h"
#import "FilterModel.h"

@interface MainVC : UIViewController<MainVCDelegate>{
  MainView *mainView;
  FilterView *filterView;
  FilterModel *currentFilterModel;
}

@end

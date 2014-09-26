//
//  FMFunnlStoreViewController.h
//  CSVParser
//
//  Created by shrinivas on 26/09/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMFunnlObject.h"

@interface FMFunnlStoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString *fileContentString;
    NSMutableArray *funnlStorageArray;
    NSMutableArray *funnlStorageAccordingToSection;
    UITableView *funnlStoreTableView;
}
@end

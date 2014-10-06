//
//  FMFunnlStoreViewController.h
//  CSVParser
//
//  Created by shrinivas on 26/09/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMFunnlObject.h"
#import "FunnelModel.h"

@interface FMFunnlStoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSString *fileContentString;
    NSMutableArray *funnlStorageArray;
    NSMutableArray *funnlStorageAccordingToSection;
    UITableView *funnlStoreTableView;
    NSMutableArray *flagArray;
    FunnelModel *funnlModel;
    FMFunnlObject *tempObject;
}
@end

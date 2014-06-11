//
//  LoginViewController.h
//  FunnlMail
//
//  Created by Daniel Judd on 4/19/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "MMDrawerController.h"
#import "EmailServerModel.h"
@interface LoginViewController : UIViewController <NSURLConnectionDataDelegate>

@property (nonatomic, retain) UITextField *username;
@property (nonatomic, retain) UITextField *password;

// The mutable data object that is used for storing incoming data in each connection.
@property (nonatomic, strong) NSMutableData *receivedData;
// A NSURLConnection object.
@property (nonatomic, strong) NSURLConnection *urlConnection;

@property (nonatomic, strong) EmailServerModel *emailServerModel;

// A flag indicating whether an access token refresh is on the way or not.
@property (nonatomic) BOOL isRefreshing;

@end

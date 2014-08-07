//
//  ContactModel.h
//  FunnlMail
//
//  Created by Macbook on 8/7/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactModel : NSObject
@property (copy) NSString *name;
@property (copy) NSString *email;
@property (assign) NSInteger count;
@property (assign) NSInteger sent_count;
@property (assign) NSInteger sent_from_account_count;
@property (assign) NSInteger received_count;
@property (copy) NSString *thumbnail;
@property (copy) NSString *resource_url;
@end

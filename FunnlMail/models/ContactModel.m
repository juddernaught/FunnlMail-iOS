//
//  ContactModel.m
//  FunnlMail
//
//  Created by Macbook on 8/7/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel
@synthesize count,email,name,received_count,resource_url,sent_count,sent_from_account_count,thumbnail;
-(NSString *) description{
    return [NSString stringWithFormat:@"{email:%@, name:%@, thumbnail:%@, count:%d received_count:%d sent_from_account_count:%d sent_count:%d }", self.email, self.name, self.thumbnail,self.count,self.received_count,self.sent_from_account_count,self.sent_count];
}
@end

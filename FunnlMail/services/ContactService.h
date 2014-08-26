//
//  ContactService.h
//  FunnlMail
//
//  Created by Macbook on 8/7/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactModel.h"

@interface ContactService : NSObject
+(ContactService *)instance;
-(BOOL) insertBulkContacts:(NSArray *)ContactModelArray;
-(NSArray *) searchContactsWithString:(NSString*)searchTerm;
-(NSMutableArray*)retrieveContactWithEmail:(NSString*)emailID;
-(NSArray *)getAllContacts;
@end

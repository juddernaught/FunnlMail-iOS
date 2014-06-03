//
//  EmailServersService.h
//  FunnlMail
//
//  Created by Michael Raber on 6/2/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmailServerModel.h"

@interface EmailServersService : NSObject

-(BOOL) insertEmailServer:(EmailServerModel *)emailServerModel;

@end

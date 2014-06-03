//
//  EmailServerModel.h
//  FunnlMail
//
//  Created by Michael Raber on 6/2/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmailServerModel : NSObject

@property (copy) NSString *emailAddress;
@property (copy) NSString *accessToken;
@property (copy) NSString *refreshToken;

@end

//
//  EmailServerModel.m
//  FunnlMail
//
//  Created by Michael Raber on 6/2/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "EmailServerModel.h"

@implementation EmailServerModel

-(NSString *) description{
  return [NSString stringWithFormat:@"{emailAddress:%@, accessToken:%@, refreshToken:%@}", self.emailAddress, self.accessToken, self.refreshToken];
}

@end

//
//  FunnelModel.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "FunnelModel.h"

@implementation FunnelModel

-(NSString *) description{
  return [NSString stringWithFormat:@"{funnelName:%@, emailAddresses:%@, phrases:%@}", self.funnelName, self.emailAddresses, self.phrases];
}

@end

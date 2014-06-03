//
//  MessageModel.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

-(NSString *) description{
  return [NSString stringWithFormat:@"{messageID:%@, read:%i, date:%@}", self.messageID, self.read, self.date];
}

@end

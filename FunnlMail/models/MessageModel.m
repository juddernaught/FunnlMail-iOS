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
  return [NSString stringWithFormat:@"{messageID:%@, read:%i, date:%@, threadID:%@, mails_in_thread:%d messageBodyToBeRendered:%@ messageHTMLBody:%@ skipFlag:%d}", self.messageID, self.read, self.date,self.gmailThreadID,self.numberOfEmailInThread,self.messageBodyToBeRendered,self.messageHTMLBody,self.skipFlag];
}

@end

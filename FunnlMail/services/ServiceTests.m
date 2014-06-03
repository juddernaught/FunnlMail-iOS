//
//  ServiceTests.m
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "ServiceTests.h"
#import "EmailServerModel.h"
#import "EmailServersService.h"
#import "FunnelModel.h"
#import "FunnelService.h"
#import "MessageModel.h"
#import "MessageService.h"

@implementation ServiceTests

+(void) runTests{
  //
  // Test EmailServerService
  //
  EmailServerModel *emailModel = [[EmailServerModel alloc]init];
  emailModel.emailAddress = @"test-1@gmail.com";
  emailModel.accessToken = @"access-OIUOIHMHJKH";
  emailModel.refreshToken = @"refresh-LKJOIUOIJLKJ";
  
  BOOL inserted = [[EmailServersService instance] insertEmailServer:emailModel];
  
  if(inserted){
    NSLog(@"EmailServersService insert worked");
  }
  else{
    NSLog(@"EmailServersService insert failed");
  }
  
  NSArray *emailServerArray = [[EmailServersService instance] allEmailServers];
  
  NSLog(@"emailServerArray: %@", emailServerArray);
  
  BOOL deleted = [[EmailServersService instance] deleteEmailServer:@"test-1@gmail.com"];
  
  if(deleted){
    NSLog(@"EmailServersService delete worked");
  }
  else{
    NSLog(@"EmailServersService delete failed");
  }
  
  emailServerArray = [[EmailServersService instance] allEmailServers];
  
  NSLog(@"emailServerArray: %@", emailServerArray);
  
  //
  // Test FunnelService
  //
  FunnelModel *funnelModel = [[FunnelModel alloc] init];
  funnelModel.funnelName = @"test-inbox";
  funnelModel.emailAddresses = @"test@test.com";
  funnelModel.phrases = @"";
  
  inserted = [[FunnelService instance] insertFunnel:funnelModel];
  
  if(inserted){
    NSLog(@"FunnelService insert worked");
  }
  else{
    NSLog(@"FunnelService insert failed");
  }
  
  NSArray *funnelArray = [[FunnelService instance] allFunnels];
  
  NSLog(@"funnelArray: %@", funnelArray);
  
  deleted = [[FunnelService instance] deleteFunnel:funnelModel.funnelName];
  
  if(deleted){
    NSLog(@"EmailServersService delete worked");
  }
  else{
    NSLog(@"EmailServersService delete failed");
  }
  
  funnelArray = [[FunnelService instance] allFunnels];
  
  NSLog(@"funnelArray: %@", funnelArray);
  
  //
  // Test MessageService
  //
  MessageModel *messageModel = [[MessageModel alloc] init];
  messageModel.messageID = [[NSUUID UUID] UUIDString];
  messageModel.messageJSON = @"JSON";
  messageModel.read = NO;
  messageModel.date = [NSDate new];
  
  inserted = [[MessageService instance] insertMessage:messageModel];
  
  if(inserted){
    NSLog(@"MessageService insert worked");
  }
  else{
    NSLog(@"MessageService insert failed");
  }
  
  NSArray *messageArray = [[MessageService instance] messagesWithTop:10];
  
  NSLog(@"messageArray: %@", messageArray);
  
  deleted = [[MessageService instance] deleteMessage:messageModel.messageID];
  
  if(deleted){
    NSLog(@"MessageService delete worked");
  }
  else{
    NSLog(@"MessageService delete failed");
  }
  
  messageArray = [[MessageService instance] messagesWithTop:10];
  
  NSLog(@"messageArray: %@", messageArray);
}

@end

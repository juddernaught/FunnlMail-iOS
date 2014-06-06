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
#import "MessageFilterXRefService.h"

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
  
  funnelModel = funnelArray[0];
  
  NSLog(@"funnelModel: %@", funnelModel);
  
  deleted = [[FunnelService instance] deleteFunnel:funnelModel.funnelId];
  
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
    
    NSLog(@"messageModel: %@",  messageModel);
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
  
  //
  // Test retrieving messages by funnel name
  //
  
  funnelModel = [[FunnelModel alloc] init];
  funnelModel.funnelName = @"TestFunnel-1";
  funnelModel.emailAddresses = @"test@test.com";
  funnelModel.phrases = @"phrase1,phrase2";
  
  inserted = [[FunnelService instance] insertFunnel:funnelModel];
  
  NSString *funnelId1 = funnelModel.funnelId;
  
  funnelModel = [[FunnelModel alloc] init];
  funnelModel.funnelName = @"TestFunnel-2";
  funnelModel.emailAddresses = @"test@test.com";
  funnelModel.phrases = @"phrase1,phrase2";
  
  inserted = [[FunnelService instance] insertFunnel:funnelModel];
  
  NSString *funnelId2 = funnelModel.funnelId;
  
  funnelModel.funnelName = @"TestFunnel-2-updated";
  BOOL updated = [[FunnelService instance] updateFunnel:funnelModel];
  
  NSLog(@"funnelModel updated: %@:%i", funnelModel, updated);
  
  NSString *messageID_1 = [[NSUUID UUID] UUIDString];
  messageModel = [[MessageModel alloc] init];
  messageModel.messageID = messageID_1;
  messageModel.messageJSON = @"JSON";
  messageModel.read = NO;
  messageModel.date = [NSDate new];
  
  inserted = [[MessageService instance] insertMessage:messageModel];
  
  NSString *messageID_2 = [[NSUUID UUID] UUIDString];
  messageModel = [[MessageModel alloc] init];
  messageModel.messageID = messageID_2;
  messageModel.messageJSON = @"JSON";
  messageModel.read = NO;
  messageModel.date = [NSDate new];
  
  inserted = [[MessageService instance] insertMessage:messageModel];
  
  inserted = [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID_1 funnelId:funnelId1];
  inserted = [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID_1 funnelId:funnelId2];
  
  inserted = [[MessageFilterXRefService instance] insertMessageXRefMessageID:messageID_2 funnelId:funnelId1];
  
  NSArray *xrefRows = [[MessageFilterXRefService instance] xrefWithMessageID:messageID_1];
  
  NSLog(@"xrefRows: %@", xrefRows);
  
  xrefRows = [[MessageFilterXRefService instance] xrefWithFunnelId:funnelId1];
  
  NSLog(@"xrefRows: %@", xrefRows);
  
  funnelArray = [[MessageService instance]funnelsWithMessageID:messageID_1];
  
  NSLog(@"funnelArray: %@", funnelArray);
  
  messageArray = [[MessageService instance] messagesWithFunnelId:funnelId1 top:100];
  NSLog(@"messageArray: %@", messageArray);
  
  messageArray = [[MessageService instance] messagesWithFunnelId:funnelId2 top:100];
  NSLog(@"messageArray: %@", messageArray);
  
  messageArray = [[MessageService instance] messagesWithFunnelId:funnelId1 top:1 count:100];
  NSLog(@"messageArray: %@", messageArray);
  
  //
  // clean up
  //
  
  deleted = [[MessageService instance] deleteMessage:messageID_1];
  deleted = [[MessageService instance] deleteMessage:messageID_2];
  deleted = [[FunnelService instance]deleteFunnel:funnelId1];
  deleted = [[FunnelService instance]deleteFunnel:funnelId2];
  deleted = [[MessageFilterXRefService instance] deleteXRefWithMessageID:messageID_1 funnelId:funnelId1];
  deleted = [[MessageFilterXRefService instance] deleteXRefWithMessageID:messageID_1 funnelId:funnelId2];
  deleted = [[MessageFilterXRefService instance] deleteXRefWithMessageID:messageID_2 funnelId:funnelId1];
}

@end

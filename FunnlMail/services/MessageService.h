//
//  MessageService.h
//  FunnlMail
//
//  Created by Michael Raber on 6/3/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"

@interface MessageService : NSObject

+(MessageService *)instance;

-(BOOL) insertMessage:(MessageModel *)messageModel;
-(BOOL) insertBulkMessages:(NSArray *)messageModelArray;
-(BOOL) updateMessage:(MessageModel *)messageModel;
-(NSArray *) messagesWithTop:(NSInteger)top;
-(NSArray *) messagesWithStart:(NSInteger)start count:(NSInteger)count;
-(NSArray *) messagesWithFunnelId:(NSString *)funnelId top:(NSInteger)top;
-(NSArray *) messagesWithFunnelId:(NSString *)funnelId top:(NSInteger)top count:(NSInteger)count;
-(NSArray *) funnelsWithMessageID:(NSString *)messageID;
-(BOOL) deleteMessage:(NSString *)messageID;
//newly added on 13th June 2014 by iauro001
-(NSArray *) retrieveAllMessages;
- (NSArray *) retrieveLatestMessages;
//newly added on 17th June 2014 by iauro001
-(NSArray *) retrieveAllMessagesForThread:(NSString*)gmailthreadID;
-(NSArray *) retrieveAllMessagesWithSameGmailID:(NSString*)gmailID;
-(NSArray *) messagesAllTopMessages;
-(BOOL) updateMessageWithDictionary:(NSDictionary *)messageDict;
-(BOOL) updateMessageWithHTMLContent:(NSDictionary *)messageDict;
- (NSString*)retrieveHTMLContentWithID:(NSString*)uid;
- (NSString*)retrievePreviewContentWithID:(NSString*)uid ;
- (void)insertFunnelJsonForMessages;
@end

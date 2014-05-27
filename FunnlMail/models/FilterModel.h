//
//  FilterModel.h
//  FunnlMail
//
//  Created by Michael Raber on 3/29/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterModel : NSObject

@property (strong) UIColor *barColor;
@property (copy) NSString *filterTitle;
@property (assign) NSInteger newMessageCount;
@property (copy) NSDate *dateOfLastMessage;
@property (copy) NSMutableArray *sendersArray;
@property (copy) NSMutableArray *subjectsArray;

- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage;
- (id)initWithBarColor:(UIColor *)barColor filterTitle:(NSString *)filterTitle newMessageCount:(NSInteger)newMessageCount dateOfLastMessage:(NSDate *)dateOfLastMessage sendersArray:(NSMutableArray*)sendersArray subjectsArray:(NSMutableArray*)subjectsArray;
- (NSMutableDictionary*) getEmailsForFunnl: (NSString *) funnlName ;
@end

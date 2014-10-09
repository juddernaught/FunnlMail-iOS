//
//  FMFunnlObject.h
//  CSVParser
//
//  Created by shrinivas on 26/09/14.
//  Copyright (c) 2014 iauro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMFunnlObject : NSObject
{

}
@property(nonatomic, strong) NSString *funnelName;
@property(nonatomic, strong) NSString *senderString;
@property(nonatomic, strong) NSString *subjectString;
@property(nonatomic, strong) NSString *categoryName;
@property(nonatomic, strong) NSString *funnelPreview;
@property(nonatomic, strong) NSString *expandSection;
@end

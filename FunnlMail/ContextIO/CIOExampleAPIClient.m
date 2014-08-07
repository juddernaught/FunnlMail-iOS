//
//  CIOExampleAPIClient.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/15/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOExampleAPIClient.h"

//#error Please enter your Context.IO API credentials below and comment out this line.
static NSString * const kContextIOConsumerKey = @"npe4azak";
static NSString * const kContextIOConsumerSecret = @"OcBGyTDYEdSat6fz";

@implementation CIOExampleAPIClient

+ (CIOExampleAPIClient *)sharedClient {
    static CIOExampleAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret];
    });
    
    return _sharedClient;
}

@end

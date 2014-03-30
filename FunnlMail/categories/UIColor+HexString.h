//
//  UIColor+HexString.h
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
//
// NO license specififed
//

@interface UIColor (HexString)

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end

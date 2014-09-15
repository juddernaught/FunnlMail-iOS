//
//  UIColor+HexString.m
//  FunnlMail
//
//  Created by Michael Raber on 3/30/14.
//  Copyright (c) 2014 FunnlMail. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor (HexString)

+ (UIColor *) colorWithHexString: (NSString *) hexString {
  NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
  CGFloat alpha, red, blue, green;
  if (colorString.length == 3 || colorString.length == 4 || colorString.length == 6 || colorString.length == 8) {
        
    
    switch ([colorString length]) {
      case 3: // #RGB
        alpha = 1.0f;
        red   = [self colorComponentFrom: colorString start: 0 length: 1];
        green = [self colorComponentFrom: colorString start: 1 length: 1];
        blue  = [self colorComponentFrom: colorString start: 2 length: 1];
        break;
      case 4: // #ARGB
        alpha = [self colorComponentFrom: colorString start: 0 length: 1];
        red   = [self colorComponentFrom: colorString start: 1 length: 1];
        green = [self colorComponentFrom: colorString start: 2 length: 1];
        blue  = [self colorComponentFrom: colorString start: 3 length: 1];
        break;
      case 6: // #RRGGBB
        alpha = 1.0f;
        red   = [self colorComponentFrom: colorString start: 0 length: 2];
        green = [self colorComponentFrom: colorString start: 2 length: 2];
        blue  = [self colorComponentFrom: colorString start: 4 length: 2];
        break;
      case 8: // #AARRGGBB
        alpha = [self colorComponentFrom: colorString start: 0 length: 2];
        red   = [self colorComponentFrom: colorString start: 2 length: 2];
        green = [self colorComponentFrom: colorString start: 4 length: 2];
        blue  = [self colorComponentFrom: colorString start: 6 length: 2];
        break;
      default:
        [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
        break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
  }
  else {
    NSLog(@"[UIColor colorWithHexString] -- Invalid color passed.");
    return [UIColor whiteColor];
  }
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
  NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
  NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
  unsigned hexComponent;
  [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
  return hexComponent / 255.0;
}

@end

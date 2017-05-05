//
//  Utility.h
//  Cy-Woods
//
//  Created by Krish Suchdev on 12/13/15.
//  Copyright © 2015 Krish Suchdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (NSString *)getAuthKey;
+ (NSString *)decode:(NSString *)salted;
+ (NSString *)encode:(NSString *)original;

@end

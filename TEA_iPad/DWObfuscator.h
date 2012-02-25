//
//  DWObfuscator.h
//  TEA_iPad
//
//  Created by Oguz Demir on 20/2/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWObfuscator : NSObject

+ (DWObfuscator*) sharedInstance;
- (BOOL) obfuscateFile:(NSString *)filePath;
- (NSData*) readObfuscatedFile:(NSString *)filePath;
- (BOOL) isObfuscated:(NSString *)filePath;
- (BOOL) fileTypeNeedsObfuscation:(NSString*) fileTypeExtension;

@end

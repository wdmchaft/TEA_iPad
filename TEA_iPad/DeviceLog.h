//
//  DeviceLog.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 20.02.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceLog : NSObject
{
    
}

+ (void) deviceLog:(NSString*)type withLecture:(NSString*)lectureName withContentType:(NSString*)contentType;
+ (void) deviceLogWithData:(NSString*)data;


@end

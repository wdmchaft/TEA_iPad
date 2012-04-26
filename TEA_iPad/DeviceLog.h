//
//  DeviceLog.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 20.02.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DeviceLog : NSObject
{
    
}

+ (void) deviceLog:(NSString*)type withLecture:(NSString*)lectureName withContentType:(NSString*)contentType withGuid:(NSString*)guid;
+ (void) deviceLogWithData:(NSString*)data;
+ (void) deviceLogWithLocation:(CLLocation*) location;
+ (void) updateDurationTime:(long)duration withGuid:(NSString*) guid withDate:(NSDate*)openedDate;

@end

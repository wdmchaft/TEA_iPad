//
//  DeviceLog.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 20.02.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "DeviceLog.h"
#import "LocalDatabase.h"
#import "TEA_iPadAppDelegate.h"


@implementation DeviceLog

/*
+ (DeviceLog *) sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[DeviceLog alloc] init ]; 
    }
    
    return _sharedInstance;
}
*/

+ (void) deviceLog:(NSString*)type withLecture:(NSString*)lectureName withContentType:(NSString*)contentType withGuid:(NSString*)guid
{
    NSString *session_name=@"";
    if ((lectureName && contentType) && guid) {
        NSString *selectSql = [NSString stringWithFormat:@"select session.name as name from session, library where guid = '%@' and library.session_guid = session.session_guid", guid];
        NSArray *result = [[LocalDatabase sharedInstance] executeQuery:selectSql];
        if (result && [result count]>0) {
            session_name = [[result objectAtIndex:0] objectForKey:@"name"];
        }
    }
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *iPadOSVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *iPadVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *insertSQL;
    
    if (lectureName && contentType) {
        insertSQL = [NSString stringWithFormat:@"insert into device_log (device_id, system_version, version, key, lecture, content_type, time, guid, session_name) values ('%@','%@','%@', '%@','%@','%@','%@','%@', '%@')", [appDelegate getDeviceUniqueIdentifier], iPadOSVersion, iPadVersion, @"openedLibraryItems",lectureName, contentType, dateString, guid, session_name];
    }
    else{
        insertSQL = [NSString stringWithFormat:@"insert into device_log (device_id, system_version, version, key, time) values ('%@','%@','%@','%@','%@')", [appDelegate getDeviceUniqueIdentifier], iPadOSVersion, iPadVersion, type, dateString];
    }
    
    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
}

+ (void) deviceLogWithLocation:(CLLocation*) location
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *iPadOSVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *iPadVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *insertSQL;
    
    insertSQL = [NSString stringWithFormat:@"insert into device_log (device_id, system_version, version, key, lat, long, time) values ('%@','%@','%@', '%@','%f','%f','%@')", [appDelegate getDeviceUniqueIdentifier], iPadOSVersion, iPadVersion, @"locationUpdate", location.coordinate.latitude, location.coordinate.longitude, dateString];
 

    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
}

+ (void) deviceLogWithData:(NSString*)data
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *iPadOSVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *iPadVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert into device_log (device_id, system_version, version, key, data, time) values ('%@','%@','%@','%@','%@')", [appDelegate getDeviceUniqueIdentifier], iPadOSVersion, iPadVersion, @"Extra Info", data, dateString];
    
    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
}

+ (void) updateDurationTime:(long)duration withGuid:(NSString*)guid withDate:(NSDate *)openedDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [df stringFromDate:openedDate];
  
    long durationTime=0;
    NSString *selectSql = [NSString stringWithFormat:@"select duration from device_log where guid = '%@' and time = '%@'", guid, dateString];
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:selectSql];

    if (result && [result count]>0) {
        int old_duration = [[[result objectAtIndex:0] objectForKey:@"duration"] intValue];
        durationTime = duration+old_duration;
    }
    
    NSString *updateSQL = [NSString stringWithFormat:@"update device_log set duration = '%ld' where guid = '%@' and time = '%@'", durationTime, guid, dateString];
    [[LocalDatabase sharedInstance] executeQuery:updateSQL];

    [df release];
}

@end

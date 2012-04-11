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

+ (void) deviceLog:(NSString*)type withLecture:(NSString*)lectureName withContentType:(NSString*)contentType
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *iPadOSVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *iPadVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *insertSQL;
    
    if (lectureName && contentType) {
        insertSQL = [NSString stringWithFormat:@"insert into device_log (device_id, system_version, version, key, lecture, content_type, time) values ('%@','%@','%@', '%@','%@','%@','%@')", [appDelegate getDeviceUniqueIdentifier], iPadOSVersion, iPadVersion, @"openedLibraryItems",lectureName, contentType, dateString];
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

@end

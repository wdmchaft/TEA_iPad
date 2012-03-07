//
//  CalendarDataClass.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "CalendarDataClass.h"
#import "LocalDatabase.h"
#import "DWDatabase.h"
#import "TEA_iPadAppDelegate.h"

@implementation CalendarDataClass

@synthesize calendarEntity, notificationDictionary;

static CalendarDataClass *_sharedInstance;


- (id)init {
    self = [super init];
    if (self) {
        [self reloadEntity];
    }
    return self;
}

+ (CalendarDataClass *) sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[CalendarDataClass alloc] init ]; 
    }
    
    return _sharedInstance;
}


- (void) reloadEntity
{
    NSString *selectSql = [NSString stringWithFormat:@"select * from calendar order by valid_date_time"];
    self.calendarEntity = [[LocalDatabase sharedInstance] executeQuery:selectSql];
}


- (void)dealloc {
    [calendarEntity release];
    [notificationDictionary release];
    [super dealloc];
}



- (void) insertEventToRemoteDatabase:(NSDictionary*)dataDictionary
{
    NSString *guid = [dataDictionary valueForKey:@"guid"];
    NSString *eventTitle = [dataDictionary valueForKey:@"title"];
    NSString *body = [dataDictionary valueForKey:@"body"];
    NSString *dateString = [dataDictionary valueForKey:@"date"];
    NSString *validDateString = [dataDictionary valueForKey:@"validDate"];
    NSString *alarmDate = [dataDictionary valueForKey:@"alarmDate"];
    NSString *imageURL = [dataDictionary valueForKey:@"imageURL"];
    int repeated = [[dataDictionary valueForKey:@"repeated"] intValue];
    int completed = [[dataDictionary valueForKey:@"completed"] intValue];
    int alarmState = [[dataDictionary valueForKey:@"alarm_state"] intValue];
    NSString *homework_ref_id = [dataDictionary valueForKey:@"homework_ref_id"];
    int type = [[dataDictionary valueForKey:@"type"] intValue];

    
    NSString *selectSQL = [NSString stringWithFormat:@"select * from notification where guid = '%@'", guid];
    NSArray *result = [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:selectSQL];
    
    if (result && [result count]>0) {
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from notification where guid = '%@'", guid];
        [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:deleteSQL];
    }
    
    NSString *insertRemoteNotificationSQL = [NSString stringWithFormat:@"insert into `notification` (`guid`, `title`, `summary`, `date`, `valid_date`, `alarm_date`,  `file_url`, `repeated`, `completed`, `alarm_state`, `related_hw`, `type`) values ('%@', '%@', '%@', '%@','%@', '%@', '%@', %d, %d, %d, '%@', %d);", guid, eventTitle, body, dateString, validDateString, alarmDate, imageURL, repeated, completed, alarmState, homework_ref_id, type];
    [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:insertRemoteNotificationSQL];
    
    
    
    
    
    NSString *selectSQLOfReceived = [NSString stringWithFormat:@"select * from receivedNotifications where guid = '%@'", guid];
    NSArray *resultOfReceived = [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:selectSQLOfReceived];
    
    if (resultOfReceived && [resultOfReceived count]>0) {
        NSString *deleteSQLOfReceived = [NSString stringWithFormat:@"delete from receivedNotifications where guid = '%@'", guid];
        [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:deleteSQLOfReceived];
    }
    
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSString *insertRemoteReceivedNotificationSQL = [NSString stringWithFormat:@"insert into `receivedNotifications` (`guid`,`student_device_id`,`date`,`valid_date`,`is_read`, `deleted`) values ('%@', '%@', '%@', '%@', 1, 0);", guid, [appDelegate getDeviceUniqueIdentifier], dateString, validDateString];
    [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:insertRemoteReceivedNotificationSQL];
    
}

- (void) insertEventToCalendar:(NSDictionary*)dataDictionary
{
    
    NSString *guid = [dataDictionary valueForKey:@"guid"];
    NSString *eventTitle = [dataDictionary valueForKey:@"title"];
    NSString *body = [dataDictionary valueForKey:@"body"];
    NSString *dateString = [dataDictionary valueForKey:@"date"];
    NSString *validDateString = [dataDictionary valueForKey:@"validDate"];
    NSString *alarmDate = [dataDictionary valueForKey:@"alarmDate"];
    NSString *imageURL = [dataDictionary valueForKey:@"imageURL"];
    int repeated = [[dataDictionary valueForKey:@"repeated"] intValue];
    int completed = [[dataDictionary valueForKey:@"completed"] intValue];
    int alarmState = [[dataDictionary valueForKey:@"alarm_state"] intValue];
    NSString *homework_ref_id = [dataDictionary valueForKey:@"homework_ref_id"];
    int type = [[dataDictionary valueForKey:@"type"] intValue];
    
    NSString *selectSQL = [NSString stringWithFormat:@"select * from calendar where id = '%@'", guid];
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:selectSQL];
    if (result && [result count]>0) {
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from calendar where id = '%@'", guid];
        [[LocalDatabase sharedInstance] executeQuery:deleteSQL];
    }
    
    
    NSString *insertSQL = [NSString stringWithFormat:@"insert into calendar (id, type, title, body, date_time, valid_date_time, alarm_date_time, image_url, repeated, completed, alarm_state, homework_ref_id) values ('%@','%d','%@','%@','%@','%@','%@','%@','%d','%d', '%d', '%@');", guid, type, eventTitle, body, dateString, validDateString, alarmDate, imageURL, repeated, completed, alarmState, homework_ref_id];
    
    
    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
}


- (void) deleteEventFromCalendar:(NSDictionary*)dataDictionary
{
    
}


@end

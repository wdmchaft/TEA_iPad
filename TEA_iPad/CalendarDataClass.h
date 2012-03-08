//
//  CalendarDataClass.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarDataClass : NSObject
{
    NSMutableArray *calendarEntity;
    NSMutableDictionary *notificationDictionary;
}

@property (nonatomic, retain) NSMutableArray *calendarEntity;
@property (nonatomic, retain) NSMutableDictionary *notificationDictionary;

+ (CalendarDataClass *) sharedInstance;

- (void) reloadEntity;
- (void) insertEventToCalendar:(NSDictionary*)dataDictionary;
- (void) deleteEventFromCalendar:(NSDictionary*)dataDictionary;
- (void) insertEventToRemoteDatabase:(NSDictionary*)dataDictionary;


@end

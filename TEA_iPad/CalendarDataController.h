//
//  CalendarDataController.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarDataClass.h"
#import "Calendar.h"
#import "CalendarView.h"
#import "NewEntryView.h"


enum calendarAlarmState 
{
    kCalendarAlarmOffState      = 0,
    kCalendarAlarmOnState       = 1,
    kCalendarAlarmShowedState   = 2,
    kCalendarAlarmSnoozedState  = 3
};

@class DailyView, WeeklyView;

@interface CalendarDataController : UIViewController
{
    CalendarView *calendarView;
    CalendarDataClass *calendarData;
    WeeklyView *weeklyView;
    DailyView *dailyView;
    
    
    UIImageView *bgImageView;
    
    UIButton *addEntry;
    UIButton *deleteEntry;
    UIButton *editEntry;
    
    UIPopoverController *newEntryPopover;
    
    UIView *containerVeiw;
    
//    int selectedRow;
    
    NSDictionary *currentEntry;
    NSString *remoteProtocolURL;
    
}

@property (nonatomic, retain) NSString *remoteProtocolURL;

@property (nonatomic, retain) NSDictionary *currentEntry;

@property (nonatomic, retain) UIImageView *bgImageView;

@property (nonatomic, retain) UIView *containerVeiw;

@property (nonatomic, retain) CalendarView *calendarView;
@property (nonatomic, retain) CalendarDataClass *calendarData;


@property (retain, nonatomic) WeeklyView *weeklyView;
@property (retain, nonatomic) DailyView *dailyView;

@property (retain, nonatomic) UIButton *addEntry;
@property (retain, nonatomic) UIButton *deleteEntry;
@property (retain, nonatomic) UIButton *editEntry;

@property (retain, nonatomic) UIPopoverController *newEntryPopover;

- (void) setHiddenComponents:(BOOL)hidden;


- (void) displayDailyEvents;
- (void) displayWeeklyEvents;

- (void) checkUnreadNotification;

@end

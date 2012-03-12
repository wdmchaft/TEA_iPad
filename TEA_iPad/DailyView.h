//
//  SummaryView.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CalendarDataController;


enum calendarAlarmColorState 
{
    kCalendarAlarmWhiteColor                = 0,
    kCalendarAlarmLigthOrangeColor          = 1,
    kCalendarAlarmOrangeColor               = 2,
    kCalendarAlarmDarkOrangeColor           = 3,
    kCalendarAlarmRedColor                  = 4
    
};

@interface DailyView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSString *selectedDayEvents;
    
    NSArray *dbResult;
    
    int selectedRow;
    
    CalendarDataController *controller;
    
    UIPopoverController *newEntryPopover;
    
    int uncompletedTask;
    
    
}


@property (assign, nonatomic) int uncompletedTask;

@property (retain, nonatomic) UIPopoverController *newEntryPopover;

@property (nonatomic, assign) CalendarDataController *controller;

@property (nonatomic, assign) int selectedRow;

@property (nonatomic, retain) NSString *selectedDayEvents;
@property (nonatomic, retain) NSArray *dbResult;
@property (nonatomic, retain) UITableView *tableView;


- (void) displaySelectedDayEvents;


@end

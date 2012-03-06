//
//  CalendarView.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeeklyView.h"
#import "DayComponent.h"

@class CalendarDataController,Calendar, DailyView;

@interface CalendarView : UIView
{
    UIButton *prevMonth;
    UIButton *nextMonth;
    UIButton *showToday;
    
    
    DailyView *dailyView;
    CalendarDataController *controller;
    
    
    NSString *currentDate;
}

@property (retain, nonatomic) NSString *currentDate;
@property (assign, nonatomic) CalendarDataController *controller;

@property (retain, nonatomic) DayComponent *dayLabelView;
@property (retain, nonatomic) Calendar *calendarComponent;

@property (retain, nonatomic) WeeklyView *weeklyView;
@property (retain, nonatomic) DailyView *dailyView;

- (IBAction)prevButtonClicked:(id)sender;
- (IBAction)nextButtonClicked:(id)sender;
- (IBAction)TodayButtonClicked:(id)sender;

@end

//
//  Calendar.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DayComponent.h"
#import "DailyView.h"
#import "CalendarDataController.h"


@interface Calendar : UIView
{
    NSDate *currentDate;
    id target;
    SEL dateSelectedSelector;
    DayComponent *currentDayLabel;
    NSString *currentDay;
    
    
    int fontSize;
    int viewWitdh;
    int viewHight;
    int dayLabelsHeight;
    UIColor *backGroundColor;
    UIColor *textColor;
    UIColor *selectedDayColor;
    NSString *fontType;
    NSString *titlePoint;
    
    
    NSString *selectedDate;
    
    CalendarDataController *controller;
    DailyView *dailyView;
        
}

@property (assign, nonatomic) CalendarDataController *controller;
@property (assign, nonatomic) DailyView *dailyView;


@property (nonatomic, retain) NSString *selectedDate;


@property (nonatomic, retain) NSDate *currentDate;
@property (nonatomic, retain) DayComponent *currentDayLabel;



@property (nonatomic, assign) int fontSize;
@property (nonatomic, assign) int viewWitdh;
@property (nonatomic, assign) int viewHight;
@property (nonatomic, assign) int dayLabelsHeight;
@property (nonatomic, retain) UIColor *backGroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *selectedDayColor;
@property (nonatomic, retain) NSString *fontType;
@property (nonatomic, retain) NSString *titlePoint;



- (void) drawCalendarForDate:(NSDate*) date;
- (void) markDate:(NSDate*) date;
- (void) markToday:(NSDate *) date;
- (void) markToday;
- (void) showPreviousMonth;
- (void) showNextMonth;

@end

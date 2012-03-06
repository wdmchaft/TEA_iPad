
//
//  Calendar.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "Calendar.h"
#import "CalendarView.h"

@implementation Calendar
@synthesize currentDate, currentDayLabel;

@synthesize fontSize, textColor, backGroundColor, viewHight, viewWitdh, selectedDayColor, dayLabelsHeight, fontType, titlePoint;

@synthesize selectedDate, controller, dailyView;

// Private methods;

- (void) drawCalendarForDate:(NSDate*) date
{
    
    for(NSObject *button in self.subviews)
    {
        if([button isKindOfClass:[UIButton class]])
        {
            [((UIButton*) button) removeFromSuperview];
        }
    }
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    // Generate new date for the first day of given date's month
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:date];
    
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    
    NSString *months;
    if (month < 10)
        months = [NSString stringWithFormat:@"0%d", month];
    else
        months = [NSString stringWithFormat:@"%d", month];
    
    NSString *stringOfDate = [NSString stringWithFormat:@"01-%@-%d", months, year];
    NSDate *firstDateOfMonth = [df dateFromString:stringOfDate];  
    
    components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:firstDateOfMonth];
    NSInteger dayOfWeek = [components weekday] - 2 ; // Get first day index of date.
    if (dayOfWeek == -1) {
        dayOfWeek = 6;
    }
    
    // Get number of Days in a Month
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstDateOfMonth];
    NSUInteger numberOfDaysInMonth = rng.length;
    
    
        
    int hUnit = viewWitdh;
    int vUnit = viewHight;                        
    int x;
    int y;
    
    // Place buttons to CalendarViews
    
    for (int i=0; i < numberOfDaysInMonth; i++) 
    {
        CGRect coordinates;
        x =  ((dayOfWeek + i) % 7) * hUnit;
        y =  (((dayOfWeek + i) / 7) * vUnit)+dayLabelsHeight+2;
        
        coordinates = CGRectMake(x, y, hUnit-2, vUnit-2);
        UIButton *button = [[UIButton alloc] initWithFrame:coordinates];
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        
        self.titlePoint = @"";//'";
        [button setTitle:[NSString stringWithFormat:@"%d\n%@", i+1, titlePoint] forState:UIControlStateNormal];
        [button setBackgroundColor:backGroundColor];
        [button setTitleColor:textColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(calendarDayClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i+1];
        
        [self addSubview:button];
        [button release];
    }
    
    // Place dayLabels to CalendarView
    
    UIColor *bgColor = [UIColor lightGrayColor];
    
    UILabel *dayPzts = [[UILabel alloc] initWithFrame:CGRectMake(hUnit*0, 0, hUnit, dayLabelsHeight)];
    [dayPzts setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayPzts setTextColor:textColor];
    [dayPzts setTextAlignment:UITextAlignmentCenter];
    [dayPzts setText:NSLocalizedString(@"Monday", NULL)];
    [dayPzts setBackgroundColor:bgColor];
    [self addSubview:dayPzts];
    
    UILabel *daySal = [[UILabel alloc] init];
    [daySal setFont:[UIFont fontWithName:fontType size:fontSize]];
    [daySal setTextColor:textColor];
    [daySal setTextAlignment:UITextAlignmentCenter];
    [daySal setText:NSLocalizedString(@"Tuesday", NULL)];
    [daySal setBackgroundColor:bgColor];
    [daySal setFrame:CGRectMake(hUnit*1, 0, hUnit, dayLabelsHeight)];
    [self addSubview:daySal];
    
    UILabel *dayCars = [[UILabel alloc] init];
    [dayCars setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayCars setTextColor:textColor];
    [dayCars setTextAlignment:UITextAlignmentCenter];
    [dayCars setText:NSLocalizedString(@"Wednesday", NULL)];
    [dayCars setBackgroundColor:bgColor];
    [dayCars setFrame:CGRectMake(hUnit*2, 0, hUnit, dayLabelsHeight)];
    [self addSubview:dayCars];
    
    UILabel *dayPers = [[UILabel alloc] init];
    [dayPers setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayPers setTextColor:textColor];
    [dayPers setTextAlignment:UITextAlignmentCenter];
    [dayPers setText:NSLocalizedString(@"Thursday", NULL)];
    [dayPers setBackgroundColor:bgColor];
    [dayPers setFrame:CGRectMake(hUnit*3, 0, hUnit, dayLabelsHeight)];
    [self addSubview:dayPers];
    
    UILabel *dayCuma = [[UILabel alloc] init];
    [dayCuma setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayCuma setTextColor:textColor];
    [dayCuma setTextAlignment:UITextAlignmentCenter];
    [dayCuma setText:NSLocalizedString(@"Friday", NULL)];
    [dayCuma setBackgroundColor:bgColor];
    [dayCuma setFrame:CGRectMake(hUnit*4, 0, hUnit, dayLabelsHeight)];
    [self addSubview:dayCuma];
    
    UILabel *dayCmts = [[UILabel alloc] init];
    [dayCmts setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayCmts setTextColor:textColor];
    [dayCmts setTextAlignment:UITextAlignmentCenter];
    [dayCmts setText:NSLocalizedString(@"Saturday", NULL)];
    [dayCmts setBackgroundColor:bgColor];
    [dayCmts setFrame:CGRectMake(hUnit*5, 0, hUnit, dayLabelsHeight)];
    [self addSubview:dayCmts];
    
    UILabel *dayPazr = [[UILabel alloc] init];
    [dayPazr setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayPazr setTextColor:textColor];
    [dayPazr setTextAlignment:UITextAlignmentCenter];
    [dayPazr setText:NSLocalizedString(@"Sunday", NULL)];
    [dayPazr setBackgroundColor:bgColor];
    [dayPazr setFrame:CGRectMake(hUnit*6, 0, hUnit-2, dayLabelsHeight)];
    [self addSubview:dayPazr];
    
    
    [self markToday:date];
    
    [dayPzts release];
    [daySal release];
    [dayCars release];
    [dayPers release];
    [dayCuma release];
    [dayCmts release];
    [dayPazr release];
    [df release];
    
}

- (IBAction)calendarDayClicked:(id)sender
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:currentDate];
    
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    
    NSString *months;
    if (month < 10)
        months = [NSString stringWithFormat:@"0%d", month];
    else
        months = [NSString stringWithFormat:@"%d", month];
    NSString *day;
    if ( [sender tag] <10) 
    {
        day = [NSString stringWithFormat:@"0%d", [sender tag]];
    }
    else 
    {
        day = [NSString stringWithFormat:@"%d", [sender tag]];
    }
    
    currentDay = day;
    
    NSString *stringOfDate = [NSString stringWithFormat:@"%@-%@-%d",day, months, year];
    NSDate *date= [df dateFromString:stringOfDate]; 
    
    
    for(NSObject *button in self.subviews)
    {
        if([button isKindOfClass:[UIButton class]]){
            if(((UIButton*) button).tag == [day intValue])
            {
                [((UIButton*) button) setTitleColor:selectedDayColor forState:UIControlStateNormal];
            }
            else 
            {
                [((UIButton*) button) setTitleColor:textColor forState:UIControlStateNormal];
            }
        }
    }
    [self markToday:date];
    
    if(currentDayLabel)
    {
        [currentDayLabel setCurrentDateDayLabel:date];
    }
    
    
    [df setDateFormat:@"yyyy-MM-dd"];
    stringOfDate = [df stringFromDate:date];
    dailyView.selectedDayEvents = stringOfDate;
    [controller displayDailyEvents];
    [controller.editEntry setHidden:YES];
    [controller.deleteEntry setHidden:YES];

    self.currentDate = date;
}

- (void) showPreviousMonth
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:currentDate];
    
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    
    if ([components day] < 10) {
        currentDay = [NSString stringWithFormat:@"0%d", [components day]];
    }
    else {
        currentDay = [NSString stringWithFormat:@"%d", [components day]];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    NSString *months;
    if (month-1 < 10 && month-1>1) {
        months = [NSString stringWithFormat:@"0%d", month-1];
    }
    else if (month == 1) {
        months = [NSString stringWithFormat:@"%d", 12];
        year--;
    }
    else {
        months = [NSString stringWithFormat:@"%d", month-1];
    }
    
    
    NSString *stringOfDate = [NSString stringWithFormat:@"01-%@-%d", months, year];
    
    NSDate *tempDate = [df dateFromString:stringOfDate];
    NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:tempDate];
    NSUInteger numberOfDaysInMonth = rng.length;
    
    if ([currentDay intValue] > numberOfDaysInMonth) {
        currentDay = [NSString stringWithFormat:@"%d", numberOfDaysInMonth];
    }
    
    stringOfDate = [NSString stringWithFormat:@"%@-%@-%d",currentDay, months, year];
    
    
    NSLog(@"prev button clicked: %@", stringOfDate);
    NSDate *newDate = [df dateFromString:stringOfDate];
    [self setCurrentDate:newDate];
    
    if(currentDayLabel)
    {
        [currentDayLabel setCurrentDateDayLabel:newDate];
    }
    
    
    [df setDateFormat:@"yyyy-MM-dd"];
    stringOfDate = [df stringFromDate:newDate];
    
    dailyView.selectedDayEvents = stringOfDate;
    [controller displayDailyEvents];
    [controller.editEntry setHidden:YES];
    [controller.deleteEntry setHidden:YES];
    
    [df release];
}

- (void) showNextMonth
{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:currentDate];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    if ([components day] < 10) {
        currentDay = [NSString stringWithFormat:@"0%d", [components day]];
    }
    else
        currentDay = [NSString stringWithFormat:@"%d", [components day]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"dd-MM-yyyy"];
    
    NSString *months;
    
    if (month+1 < 10) {
        months = [NSString stringWithFormat:@"0%d", month+1];
    }
    else if (month == 12){
        months = [NSString stringWithFormat:@"%d", 1];
        year++;
    }
    else {
        months = [NSString stringWithFormat:@"%d", month+1];
    }
    
    
    NSString *stringOfDate = [NSString stringWithFormat:@"01-%@-%d", months, year];
    
    NSDate *tempDate = [df dateFromString:stringOfDate];
    NSRange rng = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:tempDate];
    NSUInteger numberOfDaysInMonth = rng.length;
    
    if ([currentDay intValue] > numberOfDaysInMonth) {
        currentDay = [NSString stringWithFormat:@"%d", numberOfDaysInMonth];
    }
    
    stringOfDate = [NSString stringWithFormat:@"%@-%@-%d",currentDay, months, year];
    
    NSLog(@"next button clicked: %@", stringOfDate);
    NSDate *newDate = [df dateFromString:stringOfDate];
    
    
    [self setCurrentDate:newDate];
    if(currentDayLabel)
    {
        [currentDayLabel setCurrentDateDayLabel:newDate];
    }
    
    
    
    [df setDateFormat:@"yyyy-MM-dd"];
    stringOfDate = [df stringFromDate:newDate];
    dailyView.selectedDayEvents = stringOfDate;
    [controller displayDailyEvents];
    [controller.editEntry setHidden:YES];
    [controller.deleteEntry setHidden:YES];
    
    [df release];
}

- (void)markDate:(NSDate *)date
{
    
}

- (void) markToday
{
    NSDate *date = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:date];
    NSInteger day = [components day];
    
    
    for(NSObject *button in self.subviews)
    {
        if([button isKindOfClass:[UIButton class]] && ((UIButton*) button).tag == day)
        {
            [((UIButton*) button) setFont:[UIFont boldSystemFontOfSize:20]];
            
            break;
        }
        
        
    }
}


- (void) markToday:(NSDate *)date
{
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:date];
    NSInteger day = [components day];
    
    
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    NSInteger today = [todayComponents day];
    
    
    for(NSObject *button in self.subviews)
    {
        if([button isKindOfClass:[UIButton class]] && ((UIButton*) button).tag == day)
        {
            [((UIButton*) button) setFont:[UIFont boldSystemFontOfSize:fontSize]];
            [((UIButton*) button) setTitleColor:selectedDayColor forState:UIControlStateNormal];
        }
        else if([button isKindOfClass:[UIButton class]] && ((UIButton*) button).tag != day )
        {
            [((UIButton*) button) setFont:[UIFont systemFontOfSize:fontSize]];
        }
        
        if ([button isKindOfClass:[UIButton class]] && ((UIButton*) button).tag == today && ([components month] == [todayComponents month])) {
            [((UIButton*) button) setFont:[UIFont boldSystemFontOfSize:fontSize+1]];
        }
        
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setCurrentDate:[NSDate date]];
//        [self markToday];
        // Initialization code
    }
    return self;
}


- (void) setCurrentDate:(NSDate *)aCurrentDate
{
    if(currentDate)
    {
        [currentDate release];
        currentDate = nil;
    }
    currentDate = [aCurrentDate retain];
    [self drawCalendarForDate:aCurrentDate];
}

- (void)dealloc 
{
    
    [backGroundColor release];
    [selectedDayColor release];
    [textColor release];
    
    [currentDayLabel release];
    
    if(currentDate)
    {
        [currentDate release];
        currentDate = nil;
    }
    
    [super dealloc];
}


@end

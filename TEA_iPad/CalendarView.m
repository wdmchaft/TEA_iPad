//
//  CalendarView.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//


#import "CalendarView.h"
#import "WeeklyView.h"
#import "DailyView.h"
#import "DayComponent.h"
#import "Calendar.h"



@implementation CalendarView

@synthesize dailyView;
@synthesize dayLabelView;
@synthesize calendarComponent;
@synthesize weeklyView;

@synthesize controller, currentDate;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        calendarComponent = [[Calendar alloc] initWithFrame:CGRectMake(148, 35, 245, 150)];
        
        calendarComponent.fontSize = 11;
        calendarComponent.backGroundColor = [UIColor whiteColor];
        calendarComponent.textColor = [UIColor grayColor];
        calendarComponent.viewHight = calendarComponent.frame.size.height / 7;
        calendarComponent.viewWitdh = calendarComponent.frame.size.width / 7;
        calendarComponent.dayLabelsHeight = calendarComponent.frame.size.height * 0.10;
        calendarComponent.selectedDayColor = [UIColor blueColor];
        calendarComponent.fontType = @"Helvetica";
        
        
        dayLabelView = [[DayComponent alloc] initWithFrame:CGRectMake(4, 21, 142, 128)];
        dayLabelView.fontSize = 100;
        dayLabelView.textColor = [UIColor grayColor];
        dayLabelView.fontType = @"HelveticaLight";
        
        
        NSDate *date = [NSDate date];
        [calendarComponent setCurrentDate:date]; 
        [dayLabelView setCurrentDateDayLabel:date];
        calendarComponent.currentDayLabel = dayLabelView;
        
        [self addSubview:calendarComponent];
        [self addSubview:dayLabelView];
        
          
        prevMonth = [[UIButton alloc] initWithFrame:CGRectMake(278, 12, 25, 20)];
        [prevMonth setBackgroundImage:[UIImage imageNamed:@"CalendarPrevMonthButton.png"] forState:UIControlStateNormal]; 
//        [prevMonth setTitle:@"<" forState:UIControlStateNormal];
        [prevMonth setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [prevMonth addTarget:self action:@selector(prevButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:prevMonth];
        
        
        nextMonth = [[UIButton alloc] initWithFrame:CGRectMake(363, 12, 25, 20)];
        [nextMonth setBackgroundImage:[UIImage imageNamed:@"CalendarNextMonthButton.png"] forState:UIControlStateNormal];
//        [nextMonth setTitle:@">" forState:UIControlStateNormal];
        [nextMonth setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [nextMonth addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextMonth];
        
        
        showToday = [[UIButton alloc] initWithFrame:CGRectMake(305, 12, 55, 20)];
        [showToday setBackgroundImage:[UIImage imageNamed:@"CalendarTodayButton.png"] forState:UIControlStateNormal];
        [showToday setTitle:NSLocalizedString(@"Today", NULL) forState:UIControlStateNormal];
        showToday.titleLabel.font = [UIFont systemFontOfSize:12];
        [showToday setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [showToday addTarget:self action:@selector(TodayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showToday];
        
    }
    return self;
}

- (void)dealloc 
{
    
    [prevMonth release];
    [nextMonth release];
    [showToday release];
    
    [calendarComponent release];
    [weeklyView release];
    [dayLabelView release];
    [dailyView release];
    [super dealloc];
}


- (IBAction)prevButtonClicked:(id)sender {
    [calendarComponent showPreviousMonth];
}

- (IBAction)nextButtonClicked:(id)sender {
    [calendarComponent showNextMonth];
}

- (IBAction)TodayButtonClicked:(id)sender 
{
    NSDate *date = [NSDate date];
    calendarComponent.currentDate = date;
    dayLabelView.currentDay = date;
    [calendarComponent setCurrentDate:date];
    [dayLabelView setCurrentDateDayLabel:date];
    
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyy-MM-dd"];
    dailyView.selectedDayEvents = [NSString stringWithFormat:@"%@", [df stringFromDate:[NSDate date]]];
    [controller displayDailyEvents];
    [controller.editEntry setHidden:YES];
    [controller.deleteEntry setHidden:YES];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//
//  DayComponent.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "DayComponent.h"

@implementation DayComponent
@synthesize currentDay;


@synthesize textColor, backGroundColor, viewHight,viewWitdh,fontSize, fontType;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHidden:NO];
    }
    return self;
}


- (void) drawCurrentDay:(NSDate *)date
{
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:date];
    
    NSInteger year = [components year];
    NSInteger day = [components day];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.80)];
    
    [dayLabel setFont:[UIFont fontWithName:fontType size:fontSize]];
    [dayLabel setTextColor:textColor];
    [dayLabel setTextAlignment:UITextAlignmentCenter];
    [dayLabel setText:[NSString stringWithFormat:@"%d", day]];
    [self addSubview:dayLabel];
    [dayLabel release];
    
    
    
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"EEE"];
    NSString *weekDay =  [[formatter stringFromDate:date] stringByAppendingFormat:@","];
    
    UILabel *dayNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height*0.80, self.frame.size.width*0.45, self.frame.size.height*0.20)];
    [dayNameLabel setFont:[UIFont fontWithName:fontType size:(int)(fontSize / 8)]];  
    [dayNameLabel setTextColor:textColor];
    [dayNameLabel setTextAlignment:UITextAlignmentCenter];
    [dayNameLabel setText:weekDay];
    [self addSubview:dayNameLabel];
    [dayNameLabel release];
    
    
    UILabel *monthNameWithYearLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.45, self.frame.size.height*0.80, self.frame.size.width*0.55, self.frame.size.height*0.20)];
    [formatter setDateFormat:@"MMM"];
    NSString *monthName = [formatter stringFromDate:date];
    [monthNameWithYearLabel setFont:[UIFont fontWithName:fontType size:(int)(fontSize / 8)]];  
    [monthNameWithYearLabel setTextColor:textColor];
    [monthNameWithYearLabel setTextAlignment:UITextAlignmentLeft];
    [monthNameWithYearLabel setText:[NSString stringWithFormat:@"%@ %d", monthName, year]];
    [self addSubview:monthNameWithYearLabel];
    [monthNameWithYearLabel release];
}


- (void) setCurrentDateDayLabel:(NSDate *)aCurrentDate
{
    
    if(currentDay)
    {
        [currentDay release];
        currentDay = nil;
    }
    
    currentDay = [aCurrentDate retain];
    [self drawCurrentDay:aCurrentDate];
}


- (void)dealloc
{
    [backGroundColor release];
    [textColor release];
    
    if(currentDay)
    {
        [currentDay release];
        currentDay = nil;
    }
    
    [super dealloc];
}

@end

//
//  ListView.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "WeeklyView.h"
#import "LocalDatabase.h"
#import "DailyView.h"
#import "CalendarDataClass.h"
#import <QuartzCore/QuartzCore.h>
#import "CalendarDataController.h"

@implementation WeeklyView

@synthesize tableView, dbResult, selectedDailyView, controller, calendar, uncompletedTask;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHidden:NO];
        // Initialization code
        if(!tableView)
        {
            tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 395, 450) style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.layer.cornerRadius = 10;
            [[tableView layer] setBorderWidth:0.8];
            [[tableView layer] setBorderColor:[[UIColor grayColor] CGColor]];
            
            [tableView setOpaque:NO];
            [tableView setBackgroundColor:[UIColor whiteColor]];
            
            tableView.rowHeight = 50;
           
            [self addSubview:tableView];
            
            [tableView reloadData];
        }
        else{
            [tableView reloadData];
        }
    }
    return self;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    
	[myLabel setTextColor:[UIColor darkGrayColor]];
	[myLabel setOpaque:NO];
    [myLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
	[myLabel setBackgroundColor:[UIColor lightGrayColor]];
    
    myLabel.text = [NSString stringWithFormat:@"    %@", NSLocalizedString(@"WeeklyTitle", NULL)];
                    
    return [myLabel autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}


- (UITableViewCell *)tableView:(UITableView *)ptableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *tableViewCell = [ptableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (tableViewCell == nil) {
        tableViewCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
//    NSString *strFromDt = [[dbResult objectAtIndex:indexPath.row] objectForKey:@"date"];
    NSString *strName;
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *validDate = [df dateFromString:[[dbResult objectAtIndex:indexPath.row] objectForKey:@"date"]];
    
    [df setDateFormat:@"dd-MM-yyyy"];
    NSString *strFromVldt = [df stringFromDate:validDate];
    
    
    if ([[[dbResult objectAtIndex:indexPath.row] objectForKey:@"count"] intValue]<=1) {
        strName = [[[[dbResult objectAtIndex:indexPath.row] objectForKey:@"title"] componentsSeparatedByString:@"..."] objectAtIndex:0];
    }
    else
    {
        strName = [[dbResult objectAtIndex:indexPath.row] objectForKey:@"title"];
    }
    
    
    tableViewCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    tableViewCell.textLabel.textAlignment = UITextAlignmentLeft;
    tableViewCell.textLabel.numberOfLines = 2;
    tableViewCell.textLabel.text = [NSString stringWithFormat:@"%@ \r%@", strFromVldt,  strName]; 
    tableViewCell.textLabel.backgroundColor = [UIColor clearColor];
    
    
    NSDateComponents *componentsValidDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:validDate];
    
    NSInteger year = [componentsValidDate year];
    NSInteger day = [componentsValidDate day];
    NSInteger month = [componentsValidDate month];
    
    NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:[NSDate date]];
    
    NSInteger thisYear = [componentsToday year];
    NSInteger today = [componentsToday day];
    NSInteger thisMonth = [componentsToday month];
    
    
    NSString *uncompeteSQL = [NSString stringWithFormat:@"select count(*) as uncomplete from calendar where substr(valid_date_time, 1, 10) = '%@' and completed = 0", [[dbResult objectAtIndex:indexPath.row] objectForKey:@"date"]];
    
    
    NSArray *uncompleteArray = [[LocalDatabase sharedInstance] executeQuery:uncompeteSQL];
    if (uncompleteArray && [uncompleteArray count]>0) {
        uncompletedTask = [[[uncompleteArray objectAtIndex:0] valueForKey:@"uncomplete"] intValue];
    }
    else{
        uncompletedTask = 0;
    }
    
    if (year<=thisYear && month<=thisMonth) {
        if (uncompletedTask == 0) {
            tableViewCell.textLabel.textColor = [UIColor blackColor];
            tableViewCell.contentView.backgroundColor = [UIColor colorWithRed:153.0/255.f green:204.0/255.f blue:51.0/255.f alpha:1.0];
        }
        else if ((day <= today && month==thisMonth) || (month<thisMonth))
        { 
            tableViewCell.textLabel.textColor = [UIColor whiteColor];
            tableViewCell.contentView.backgroundColor = [UIColor colorWithRed:204.0/255.f green:51.0/255.f blue:0.0/255.f alpha:1.0];
        }
        else if (day == today+1)
        {
            tableViewCell.textLabel.textColor = [UIColor whiteColor];
            tableViewCell.contentView.backgroundColor = [UIColor colorWithRed:204.0/255.f green:102.0/255.f blue:0.0/255.f alpha:1.0];
        }
        else if (day == today+2)
        {
            tableViewCell.textLabel.textColor = [UIColor whiteColor];
            tableViewCell.contentView.backgroundColor = [UIColor colorWithRed:204.0/255.f green:153.0/255.f blue:0.0/255.f alpha:1.0];
        }
        else if (day == today+3)
        {
            tableViewCell.textLabel.textColor = [UIColor darkGrayColor];
            tableViewCell.contentView.backgroundColor = [UIColor colorWithRed:204.0/255.f green:204.0/255.f blue:0.0/255.f alpha:1.0];
        }
        else if (day > today+3)
        {
            tableViewCell.textLabel.textColor = [UIColor darkGrayColor];
            tableViewCell.contentView.backgroundColor = [UIColor whiteColor];
        }
        
    }
    
    return tableViewCell;
   
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dbResult count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", [[dbResult objectAtIndex:indexPath.row] valueForKey:@"date"]);
    
    selectedDailyView.selectedDayEvents = [[dbResult objectAtIndex:indexPath.row] valueForKey:@"date"];
    [self.controller displayDailyEvents];
    [self.controller.editEntry setHidden:YES];
    [self.controller.deleteEntry setHidden:YES];
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [[dbResult objectAtIndex:indexPath.row] valueForKey:@"date"];
    NSDate *calendarDate = [df dateFromString:str];
    [df release];
   
    
    self.calendar = controller.calendarView.calendarComponent;
    [self.calendar setCurrentDate:calendarDate];
    [self.calendar.currentDayLabel setCurrentDateDayLabel:calendarDate];
}

- (void)dealloc 
{
    [tableView release];
    [dbResult release];
    [super dealloc];
}


@end

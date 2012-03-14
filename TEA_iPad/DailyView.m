//
//  SummaryView.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "DailyView.h"
#import "CalendarDataClass.h"
#import "CalendarDataController.h"
#import <QuartzCore/QuartzCore.h>
#import "LibraryView.h"
#import "TEA_iPadAppDelegate.h"
#import "HWView.h"
#import "LocalDatabase.h"
#import "CustomCalendarCell.h"


@implementation DailyView

@synthesize tableView, selectedDayEvents, dbResult, selectedRow, controller, newEntryPopover, uncompletedTask;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setHidden:NO];
        selectedRow = -1;
        // Initialization code
        if(!tableView)
        {
            tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
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
            
            [self.tableView reloadData];
        }
        else
            [self.tableView reloadData];
    }
    return self;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    
    NSString *dateString;
    
    if ([self.dbResult count]>0) {
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [df dateFromString:[[dbResult objectAtIndex:0] valueForKey:@"valid_date_time"]];
        [df setDateFormat:@"dd MMMM yyyy"];
        dateString = [df stringFromDate:date];
    }
    else
    {
        [df setDateFormat:@"dd MMMM yyyy"];
        dateString = [df stringFromDate:[NSDate date]];
    }
    
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    
	[myLabel setTextColor:[UIColor darkGrayColor]];
	[myLabel setOpaque:NO];
    [myLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
	[myLabel setBackgroundColor:[UIColor lightGrayColor]];
    
    myLabel.text = [NSString stringWithFormat:@"    %@ %@", dateString, NSLocalizedString(@"DailyTitle", NULL)];
	
	return [myLabel autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)ptableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    CustomCalendarCell *tableViewCell = [ptableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (tableViewCell == nil) {
        tableViewCell = [[[CustomCalendarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *validDate = [df dateFromString:[[dbResult objectAtIndex:indexPath.row] objectForKey:@"valid_date_time"]];
    
    [df setDateFormat:@"dd-MM-yyyy"];
    NSString *strFromVldt = [df stringFromDate:validDate];
    NSString *strName = [[dbResult objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    if ([strName length] > 60) {
        strName =[NSString stringWithFormat:@"%@ ...", [strName substringToIndex:59]];
    }
    
    tableViewCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    tableViewCell.textLabel.textAlignment = UITextAlignmentLeft;
    tableViewCell.textLabel.numberOfLines=2;
    tableViewCell.textLabel.text = [NSString stringWithFormat:@"%@\r%@", strFromVldt, strName];
    tableViewCell.textLabel.backgroundColor = [UIColor clearColor];
    
    NSDateComponents *componentsValidDate = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:validDate];
    
    NSInteger year = [componentsValidDate year];
    NSInteger day = [componentsValidDate day];
    NSInteger month = [componentsValidDate month];
    
    NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:[NSDate date]];
    
    NSInteger thisYear = [componentsToday year];
    NSInteger today = [componentsToday day];
    NSInteger thisMonth = [componentsToday month];
    
    
    if ([[[dbResult objectAtIndex:indexPath.row] valueForKey:@"completed"] intValue] == 0) {
        if (year<=thisYear && month<=thisMonth) {
            if ((day <= today && month==thisMonth) || (month<thisMonth))
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
    }
    else if ([[[dbResult objectAtIndex:indexPath.row] valueForKey:@"completed"] intValue] == 1)
    {
        tableViewCell.textLabel.textColor = [UIColor blackColor];
        tableViewCell.contentView.backgroundColor = [UIColor colorWithRed:153.0/255.f green:204.0/255.f blue:51.0/255.f alpha:1.0];
    }
     
    
    [tableViewCell.infoButton addTarget:self action:@selector(showInformation:) forControlEvents:UIControlEventTouchUpInside];
    [tableViewCell.infoButton setTag:indexPath.row];    
    
    
    if ([[[dbResult objectAtIndex:indexPath.row] valueForKey:@"type"] intValue] == 2)
    {
        [tableViewCell.infoButton setHidden:NO];
        [tableViewCell.infoButton setFrame:CGRectMake(tableView.frame.size.width-35, 15, 25, 25)];
    }
    else{
        
        [tableViewCell.infoButton setHidden:YES];
    }
    
    
    return tableViewCell;
}




- (IBAction)showInformation:(id)sender
{

    
    NSLog(@"%@", [self.controller superclass]);
   
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    
    //if session is not logon state
    if (appDelegate.state != kAppStateLogon) {
        
        // Get homework name from db
        
        NSString *fileName = [[dbResult objectAtIndex:[sender tag]] valueForKey:@"image_url"];
        
        NSString *sql = [NSString stringWithFormat: @"select name from homework where file = '%@'", fileName];
        
        NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql];
        
        if (result && [result count]>0) {
            NSString *homeworkName = [[result objectAtIndex:0] valueForKey:@"name"];
            
            NSString *homeworkGuidSQL = [NSString stringWithFormat:@"select guid from homework where file = '%@'", fileName];
            NSString *homeworkGuid = [[[LocalDatabase sharedInstance] executeQuery:homeworkGuidSQL returnSimpleArray:YES] objectAtIndex:0];
            
            
            HWView *homeworkView = [[HWView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748) andZipFileName:fileName andHomeworkId:homeworkGuid];
            [homeworkView.titleOfHomework setText:homeworkName]; 
            
            [appDelegate.viewController.view addSubview:homeworkView];
            [homeworkView release];
        }
        
        
    }
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dbResult count];
}



- (void) fillEntryFields:(id)entry
{
    NewEntryView *newEntry = (NewEntryView*)entry;
    
    [newEntry.calendarTitle setText:[newEntry.currentDictionary objectForKey:@"title"]];
    [newEntry.calendarBody setText:[newEntry.currentDictionary objectForKey:@"body"]];
    [newEntry.calendarImageURL setText:[newEntry.currentDictionary objectForKey:@"image_url"]];
    
    newEntry.dateString = [newEntry.currentDictionary objectForKey:@"valid_date_time"];
    NSArray *dateStringArray = [newEntry.dateString componentsSeparatedByString:@" "];
    
    
    [newEntry.calendarDateYearTextField setText:[[[dateStringArray objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:0]];
    [newEntry.calendarDateMonthTextField setText:[[[dateStringArray objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:1]];
    [newEntry.calendarDateDayTextField setText:[[[dateStringArray objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:2]];
    [newEntry.calendarDateHourTextField setText:@"00"];//[[[dateStringArray objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:0]];
    [newEntry.calendarDateMinuteTextField setText:@"00"]; //[[[dateStringArray objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    dateStringArray = [[newEntry.currentDictionary objectForKey:@"alarm_date_time"] componentsSeparatedByString:@" "];
    
    [newEntry.calendarAlarmYearTextField setText:[[[dateStringArray objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:0]];
    [newEntry.calendarAlarmMonthTextField setText:[[[dateStringArray objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:1]];
    [newEntry.calendarAlarmDayTextField setText:[[[dateStringArray objectAtIndex:0] componentsSeparatedByString:@"-"] objectAtIndex:2]];
    [newEntry.calendarAlarmHourTextField setText:@"00"];//[[[dateStringArray objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:0]];
    [newEntry.calendarAlarmMinuteTextField setText:@"00"];//[[[dateStringArray objectAtIndex:1] componentsSeparatedByString:@":"] objectAtIndex:1]];
    
    newEntry.editedEntryGuid = [newEntry.currentDictionary objectForKey:@"id"];
    newEntry.calendarCompleatedState.on = [[newEntry.currentDictionary objectForKey:@"completed"] intValue];
    
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;

    NewEntryView *newEntry = [[[NewEntryView alloc] initWithNibName:@"NewEntryView" bundle:nil] autorelease];
    newEntry.controller = self.controller;
    self.controller.newEntryPopover = [[[UIPopoverController alloc] initWithContentViewController:newEntry] autorelease];
    newEntry.popup = self.controller.newEntryPopover;
    self.controller.newEntryPopover.popoverContentSize = newEntry.view.frame.size;
    
    UITableViewCell *tempCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.controller.newEntryPopover presentPopoverFromRect:tempCell.frame inView:self.controller.dailyView.tableView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
    newEntry.currentDictionary = [dbResult objectAtIndex:indexPath.row];
    
    if ([[newEntry.currentDictionary objectForKey:@"type"] intValue] != 1) 
    {
        [[newEntry addButton] setHidden:YES];
        [[newEntry calendarAlarmDayTextField] setEnabled:NO]; 
        [[newEntry calendarAlarmYearTextField] setEnabled:NO]; 
        [[newEntry calendarAlarmHourTextField] setEnabled:NO]; 
        [[newEntry calendarAlarmMonthTextField] setEnabled:NO]; 
        [[newEntry calendarAlarmMinuteTextField] setEnabled:NO]; 
        [[newEntry calendarDateDayTextField] setEnabled:NO]; 
        [[newEntry calendarDateYearTextField] setEnabled:NO]; 
        [[newEntry calendarDateHourTextField] setEnabled:NO]; 
        [[newEntry calendarDateMinuteTextField] setEnabled:NO]; 
        [[newEntry calendarDateMonthTextField] setEnabled:NO];
        [[newEntry calendarTitle] setEnabled:NO]; 
        [[newEntry calendarBody] setEditable:NO]; 
        [[newEntry calendarImageURL] setEnabled:NO];
        [[newEntry calendarCompleatedState] setEnabled:NO];
        [[newEntry deleteButton] setHidden:YES];
    }
    
    [self fillEntryFields:newEntry];
  
}


- (void) displaySelectedDayEvents
{
    NSDate *date1;
    NSDate *date2;
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    date2 = [df dateFromString:selectedDayEvents];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *dataDict in [CalendarDataClass sharedInstance].calendarEntity) {
        date1 = [df dateFromString:[NSString stringWithFormat:@"%@", [dataDict objectForKey:@"valid_date_time"]]];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date1];
        NSInteger day = [components day];
        NSInteger month = [components month]; 
        NSInteger year = [components year];
        
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date2];
        NSInteger today = [components day];
        NSInteger thisMonth = [components month]; 
        NSInteger thisYear = [components year];
        
        
        if (day==today && month == thisMonth && year == thisYear) {
            [array addObject:dataDict];
        }
    }
    
    self.dbResult = array;
    [self.tableView reloadData];
    
}


- (void)dealloc 
{
    [selectedDayEvents release];
    [tableView release];
    [dbResult release];
    
    [super dealloc];
}

@end

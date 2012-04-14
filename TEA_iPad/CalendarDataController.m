//
//  CalendarDataController.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 12/29/11.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "CalendarDataController.h"
#import "WeeklyView.h"
#import "DailyView.h"
#import "TEA_iPadAppDelegate.h"
#import "LocalDatabase.h"
#import "NewEntryView.h"
#import "DWDatabase.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivityIndicator.h"
#import "ConfigurationManager.h"


enum calendarEntryType {
    cEntryTypeSystem   = 0,
    cEntryTypeUser     = 1,
    cEntryTypeHomework = 2
    };


@implementation CalendarDataController
@synthesize calendarView, calendarData, weeklyView, dailyView, addEntry, newEntryPopover;
@synthesize containerVeiw, deleteEntry, editEntry, bgImageView, currentEntry, remoteProtocolURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.remoteProtocolURL = [ConfigurationManager getConfigurationValueForKey:@"ProtocolRemoteURL"];
    }
    return self;
}


- (void) displayDailyEvents
{
    
    NSDate *date1;
    NSDate *date2;
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    if (dailyView.selectedDayEvents) {
        [df setDateFormat:@"yyyy-MM-dd"];
        date2 = [df dateFromString:dailyView.selectedDayEvents];
    }
    else
        date2 = [NSDate date];
   
    
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
        
    dailyView.dbResult = array;
    [dailyView.tableView reloadData];
    

 
}
- (void) displayWeeklyEvents
{
    
    TEA_iPadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    int count = [appDelegate.notificationArray count];
    while ([appDelegate.notificationArray count]>0) {
        
        NSDictionary *notificationDictionary = [appDelegate.notificationArray objectAtIndex:0];
        
        NSString *msgGuid = [notificationDictionary valueForKey:@"guid"];
        NSString *msgName = [notificationDictionary valueForKey:@"title"];
        NSString *summary = [notificationDictionary valueForKey:@"summary"];
        NSString *msgDate = [notificationDictionary valueForKey:@"date"];
        NSString *msgValidDate = [notificationDictionary valueForKey:@"valid_date"];
        NSString *alarmDate = [notificationDictionary valueForKey:@"alarm_date"];
        NSString *file_URL = [notificationDictionary valueForKey:@"file_url"];
        int repeated = [[notificationDictionary valueForKey:@"repeated"] intValue];
        int completed = [[notificationDictionary valueForKey:@"completed"] intValue];
        int alarmState = [[notificationDictionary valueForKey:@"alarm_state"] intValue];
        NSString *homework_ref_id = [notificationDictionary valueForKey:@"related_hw"];
        int type = [[notificationDictionary valueForKey:@"type"] intValue];
        
        
        
   
        if (!msgName) {
            msgName = @"";
        }
        if (!summary) {
            summary = @"";
        }
        if (!file_URL) {
            file_URL = @"";
        }
            
        NSMutableDictionary *dataDict = [[[NSMutableDictionary alloc] init] autorelease];
        [dataDict setObject:msgGuid forKey:@"guid"];
        [dataDict setObject:msgName forKey:@"title"];
        [dataDict setObject:summary forKey:@"body"];
        [dataDict setObject:msgDate forKey:@"date"];
        [dataDict setObject:msgValidDate forKey:@"validDate"];
        [dataDict setObject:alarmDate forKey:@"alarmDate"];
        [dataDict setObject:file_URL forKey:@"imageURL"];
        [dataDict setObject:[NSString stringWithFormat:@"%d", type] forKey:@"type"];
        [dataDict setObject:homework_ref_id forKey:@"homework_ref_id"];
        [dataDict setObject:[NSString stringWithFormat:@"%d", repeated] forKey:@"repeat"];
        [dataDict setObject:[NSString stringWithFormat:@"%d", completed] forKey:@"completed"];
        [dataDict setObject:[NSString stringWithFormat:@"%d", alarmState] forKey:@"alarmState"];
            
            
        [[CalendarDataClass sharedInstance] insertEventToCalendar:dataDict];

        [[CalendarDataClass sharedInstance] reloadEntity];

        count--;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
        [appDelegate.notificationArray removeObjectAtIndex:0];
        NSString *updateString = [NSString stringWithFormat:@"update receivedNotifications set is_read = 1 where guid = '%@' and student_device_id = '%@'", msgGuid, [appDelegate getDeviceUniqueIdentifier]];
        
        
        [DWDatabase getResultFromURL:[NSURL URLWithString:remoteProtocolURL] withSQL:updateString];
    
        
    }
    
   
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    
    NSString *stringOfDate = [NSString stringWithFormat:@"%@", [NSDate date]];
    
    NSDate *todayDate = [df dateFromString:stringOfDate];
    stringOfDate = [NSString stringWithFormat:@"%@", todayDate];
    
//    NSString *sqlString = [NSString stringWithFormat:@"select substr(valid_date_time, 1, 10) as date, count(*) as count, title ||'...  and ' || (count(*) - 1) || ' more' as title from calendar where valid_date_time > '%@' group by substr(valid_date_time, 1, 10)", [stringOfDate substringWithRange:NSMakeRange(0, 10)]];
    
    NSString *sqlString = [NSString stringWithFormat:@"select substr(valid_date_time, 1, 10) as date, count(*) as count, title ||'...  and ' || (count(*) - 1) || ' more' as title from calendar where (completed = 0 and valid_date_time < '%@' and type = %d) or  valid_date_time >= '%@' group by substr(valid_date_time, 1, 10);", [stringOfDate substringWithRange:NSMakeRange(0, 10)], cEntryTypeHomework, [stringOfDate substringWithRange:NSMakeRange(0, 10)]];
    
    NSMutableArray *weeklyDisplayArray = [[LocalDatabase sharedInstance] executeQuery:sqlString];
    
        
    NSString *updateSQL = [NSString stringWithFormat:@"update calendar set completed = 1 where completed = 0 and valid_date_time < '%@' and type = %d", [stringOfDate substringWithRange:NSMakeRange(0, 10)], cEntryTypeSystem];
    [[LocalDatabase sharedInstance] executeQuery:updateSQL];
    [[CalendarDataClass sharedInstance] reloadEntity];
    
    updateSQL = [NSString stringWithFormat:@"update notification set completed = 1 where completed = 0 and valid_date < '%@' and type = %d", [stringOfDate substringWithRange:NSMakeRange(0, 10)], cEntryTypeSystem];
    [DWDatabase getResultFromURL:[NSURL URLWithString:remoteProtocolURL] withSQL:updateSQL];
    
    weeklyView.dbResult = weeklyDisplayArray;
    [weeklyView.tableView reloadData];
    [self displayDailyEvents];
//    [dailyView.tableView reloadData];
}


- (void) setHiddenComponents:(BOOL)hidden
{
    
    [containerVeiw setHidden:hidden];
    if (!hidden) {
        dailyView.selectedDayEvents = nil;
        [self checkUnreadNotification];
    }
}


- (id)init {
    self = [super init];
    if (self) {
//        [self viewDidLoad];
        containerVeiw = [[UIView alloc] initWithFrame:CGRectMake(110, 0, 910, 748)];
        [self.view addSubview:containerVeiw];

    }
    return self;
}


- (void)dealloc 
{   
    
    [currentEntry release];
    [newEntryPopover release];
    
    [addEntry release];
    [deleteEntry release];
    [editEntry release];
    
    [containerVeiw release];
    [bgImageView release];
    
    [calendarData release];
    [calendarView release];
    [dailyView release];
    [weeklyView release];

    
    [super dealloc];
    
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{   
    
    [super viewDidLoad];
//    containerVeiw = [[UIView alloc] initWithFrame:CGRectMake(110, 0, 910, 748)];
    
    UIImageView *calendarBgImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 900, 715)] autorelease];
    [calendarBgImage setImage:[UIImage imageNamed:@"CalendarBG.png"]];
    [containerVeiw addSubview:calendarBgImage];
    [containerVeiw setHidden:NO];

//    self.view = containerVeiw;
//    [self.view addSubview:containerVeiw];

    
    calendarView = [[CalendarView alloc] initWithFrame:CGRectMake(493, 80, 395, 190)];
    [[calendarView layer] setCornerRadius:10];
    [[calendarView layer] setBorderWidth:0.8];
    [[calendarView layer] setBorderColor:[[UIColor grayColor] CGColor]];
//    [calendarView setBackgroundColor:[UIColor grayColor]];
    [calendarView setHidden:NO];
    calendarView.controller = self;
    calendarView.calendarComponent.controller = self;
    [containerVeiw addSubview:calendarView];
    
    
    weeklyView = [[WeeklyView alloc] initWithFrame:CGRectMake(493, 281, 395, 450)];
    [weeklyView setHidden:NO];
    weeklyView.controller = self;
    [self.view addSubview:weeklyView];
    [containerVeiw addSubview:weeklyView];    
    
    
    dailyView = [[DailyView alloc] initWithFrame:CGRectMake(8, 40, 460, 619)];
    [dailyView setHidden:NO];
    dailyView.controller = self;
    [containerVeiw addSubview:dailyView];
    
    weeklyView.selectedDailyView = dailyView;
    
    addEntry = [[UIButton alloc] initWithFrame:CGRectMake(335, 702, 138, 30)];
    [addEntry setBackgroundColor:[UIColor whiteColor]];
    [[addEntry layer] setCornerRadius:10];
    [[addEntry layer] setBorderWidth:0.8];
    [[addEntry layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [addEntry setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addEntry setTitle:NSLocalizedString(@"AddCalendar", NULL) forState:UIControlStateNormal];
    [addEntry addTarget:self action:@selector(addNewEntryToLists:) forControlEvents:UIControlEventTouchUpInside];
    [containerVeiw addSubview:addEntry];
    
    
//*********************************************************************************
    
    deleteEntry = [[UIButton alloc] initWithFrame:CGRectMake(220, 702, 110, 30)];
    [deleteEntry setBackgroundColor:[UIColor whiteColor]];
    [[deleteEntry layer] setCornerRadius:10];
    [[deleteEntry layer] setBorderWidth:0.8];
    [[deleteEntry layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [deleteEntry setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [deleteEntry setTitle:NSLocalizedString(@"DeleteCalendar", NULL) forState:UIControlStateNormal];
    [deleteEntry addTarget:self action:@selector(deleteEntryFromLists:) forControlEvents:UIControlEventTouchUpInside];
    [deleteEntry setHidden:YES];
    [containerVeiw addSubview:deleteEntry];
    
    
    
    editEntry = [[UIButton alloc] initWithFrame:CGRectMake(110, 702, 102, 30)];
    [editEntry setBackgroundColor:[UIColor whiteColor]];
    [[editEntry layer] setCornerRadius:10];
    [[editEntry layer] setBorderWidth:0.8];
    [[editEntry layer] setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [editEntry setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editEntry setTitle:NSLocalizedString(@"EditCalendar", NULL) forState:UIControlStateNormal];
    [editEntry addTarget:self action:@selector(editEntryInLists:) forControlEvents:UIControlEventTouchUpInside];
    [editEntry setHidden:YES];
    [containerVeiw addSubview:editEntry];
    
//*********************************************************************************
    

    
    calendarView.weeklyView = weeklyView;
    calendarView.dailyView = dailyView;
    calendarView.calendarComponent.dailyView = dailyView;
    

}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (IBAction)addNewEntryToLists:(id)sender
{
   
    NewEntryView *newEntry = [[[NewEntryView alloc] initWithNibName:@"NewEntryView" bundle:nil] autorelease];
    newEntry.controller = self;
    self.newEntryPopover = [[[UIPopoverController alloc] initWithContentViewController:newEntry] autorelease];
    newEntry.popup = self.newEntryPopover;
    self.newEntryPopover.popoverContentSize = newEntry.view.frame.size;
    [self.newEntryPopover presentPopoverFromRect:((UIButton*)sender).frame inView:self.containerVeiw permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
    [newEntry.calendarTitle becomeFirstResponder];
    [newEntry.deleteButton setHidden:YES];
    

}





- (void) checkUnreadNotification
{
    
    TEA_iPadAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
 
    NSString *selectSQL = [NSString stringWithFormat:@"select * from receivedNotifications where student_device_id = '%@' and (deleted = 1 or is_read <> 1);", [appDelegate getDeviceUniqueIdentifier]];
    NSString *protocolURL = [ConfigurationManager getConfigurationValueForKey:@"ProtocolRemoteURL"];
    NSArray *array = [[DWDatabase getResultFromURL:[NSURL URLWithString:protocolURL] withSQL:selectSQL]retain];
        
    for (NSDictionary *arrayObject in array) {
        
        if ([[arrayObject objectForKey:@"deleted"] intValue] == 0) {
            NSString *selectNotifications = [NSString stringWithFormat:@"select * from notification where guid = '%@'", [arrayObject valueForKey:@"guid"]];
            
            NSArray *result = [[DWDatabase getResultFromURL:[NSURL URLWithString:protocolURL] withSQL:selectNotifications]retain];
            
            if (result && [result count]>0) {
                [appDelegate.notificationArray addObject:[result objectAtIndex:0]];
            }
            [result release];
        }
        else if ([[arrayObject objectForKey:@"deleted"] intValue] == 1) {
            NSString *deleteNotificationFromCalendar = [NSString stringWithFormat:@"delete from calendar where id = '%@'", [arrayObject valueForKey:@"guid"]];
            [[LocalDatabase sharedInstance] executeQuery:deleteNotificationFromCalendar];
        }


    }

    [array release];    
    [[CalendarDataClass sharedInstance] reloadEntity];
    [self displayWeeklyEvents];
    [self displayDailyEvents];
    
   // [activity.indicator stopAnimating];
}




@end

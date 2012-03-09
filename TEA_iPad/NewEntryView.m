//
//  NewEntryView.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 20.02.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "NewEntryView.h"
#import "LocalDatabase.h"
#import "CalendarDataClass.h"
#import "WeeklyView.h"
#import "DailyView.h"
#import "DWDatabase.h"

@implementation NewEntryView
@synthesize deleteButton;

@synthesize calendarAlarmDayTextField;
@synthesize calendarAlarmMonthTextField;
@synthesize calendarAlarmYearTextField;
@synthesize calendarAlarmHourTextField;
@synthesize calendarAlarmMinuteTextField;
@synthesize calendarAlarmState;
@synthesize repeatAlarmSwitch;
@synthesize calendarCompleatedState;
@synthesize calendarCompletedLabel;
@synthesize calendarDateDayTextField;
@synthesize calendarDateMonthTextField;
@synthesize calendarDateYearTextField;
@synthesize calendarDateHourTextField;
@synthesize calendarDateMinuteTextField;

@synthesize calendarGuid;
@synthesize calendarTitle;
@synthesize calendarBody;
@synthesize calendarImageURL;
@synthesize popup;
@synthesize addButton;

@synthesize controller, editedEntryGuid, dateString, currentDictionary;


int viewScrollSize = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //set date fields
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    // Generate new date for the first day of given date's month
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSWeekOfMonthCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:[NSDate date]];
    
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSInteger day =  [components day];
    /*
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
     */
    
    [calendarDateYearTextField setText:[NSString stringWithFormat:@"%d", year]];
    [calendarDateMonthTextField setText:[NSString stringWithFormat:@"%d", month]];
    [calendarDateDayTextField setText:[NSString stringWithFormat:@"%d", day]];
    [calendarDateHourTextField setText:@"00"];//[NSString stringWithFormat:@"%d", hour]];
    [calendarDateMinuteTextField setText:@"00"]; //[NSString stringWithFormat:@"%d", minute]];    
        
    [calendarAlarmYearTextField setText:[NSString stringWithFormat:@"%d", year]]; 
    [calendarAlarmMonthTextField setText:[NSString stringWithFormat:@"%d", month]];
    [calendarAlarmDayTextField setText:[NSString stringWithFormat:@"%d", day]];
    [calendarAlarmHourTextField setText:@"00"];//[NSString stringWithFormat:@"%d", hour]];
    [calendarAlarmMinuteTextField setText:@"00"];//[NSString stringWithFormat:@"%d", minute]];
    
    [calendarGuid setText:[LocalDatabase stringWithUUID]];
    
    calendarAlarmMinuteTextField.delegate = self;
    calendarAlarmHourTextField.delegate = self;
    calendarAlarmDayTextField.delegate = self;
    calendarAlarmMonthTextField.delegate = self;
    calendarAlarmYearTextField.delegate = self;
    calendarDateDayTextField.delegate = self;
    calendarDateHourTextField.delegate = self;
    calendarDateMinuteTextField.delegate = self;
    calendarDateMonthTextField.delegate = self;
    calendarBody.delegate = self;
    calendarImageURL.delegate = self;
    
}

- (void)viewDidUnload
{
    [calendarGuid release];
    calendarGuid = nil;
    [self setCalendarGuid:nil];
    [self setCalendarTitle:nil];
    [self setCalendarBody:nil];
    [self setCalendarImageURL:nil];
    [self setCalendarImageURL:nil];
    [self setCalendarDateDayTextField:nil];
    [self setCalendarDateMonthTextField:nil];
    [self setCalendarDateYearTextField:nil];
    [self setCalendarAlarmDayTextField:nil];
    [self setCalendarAlarmMonthTextField:nil];
    [self setCalendarAlarmYearTextField:nil];
    [self setCalendarAlarmHourTextField:nil];
    [self setCalendarAlarmMinuteTextField:nil];
    [self setCalendarDateHourTextField:nil];
    [self setCalendarDateMinuteTextField:nil];
    [self setCalendarAlarmState:nil];
    [self setRepeatAlarmSwitch:nil];
    [self setAddButton:nil];
    [self setCalendarCompleatedState:nil];
    [self setCalendarCompletedLabel:nil];
    [self setDeleteButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [popup release];
    [calendarGuid release];
    [calendarTitle release];
    [calendarBody release];
    [calendarImageURL release];
    [calendarImageURL release];
    [calendarDateDayTextField release];
    [calendarDateMonthTextField release];
    [calendarDateYearTextField release];
    [calendarAlarmDayTextField release];
    [calendarAlarmMonthTextField release];
    [calendarAlarmYearTextField release];
    [calendarAlarmHourTextField release];
    [calendarAlarmMinuteTextField release];
    [calendarDateHourTextField release];
    [calendarDateMinuteTextField release];
    [calendarAlarmState release];
    [repeatAlarmSwitch release];
    [addButton release];
    [calendarCompleatedState release];
    [calendarCompletedLabel release];
    [deleteButton release];
    [super dealloc];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect rect = [[self view] frame];
    int diff = textField.frame.origin.y - 500;
    
    if(diff > 0)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        rect.origin.y -= diff; 
        [[self view] setFrame: rect];
        [UIView commitAnimations];
        
        viewScrollSize = diff;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(viewScrollSize > 0)
    {
        CGRect rect = [[self view] frame];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        rect.origin.y += viewScrollSize; 
        [[self view] setFrame: rect];
        [UIView commitAnimations];
        
        viewScrollSize = 0;
    }

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect rect = [[self view] frame];
    int diff = textView.frame.origin.y - 500;
    
    if(diff > 0)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        rect.origin.y -= diff; 
        [[self view] setFrame: rect];
        [UIView commitAnimations];
        
        viewScrollSize = diff;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect rect = [[self view] frame];
    int diff = textView.frame.origin.y - 500;
    
    if(diff > 0)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        rect.origin.y -= diff; 
        [[self view] setFrame: rect];
        [UIView commitAnimations];
        
        viewScrollSize = diff;
    }
}


- (BOOL) validateEntry:(NSString*)initialDate withValidDate:(NSString*)validDateString withAlarmDate:(NSString*)alarmDateString
{
    if (!calendarTitle.text || [calendarTitle.text isEqualToString:@""]) {
        return NO;
    }
    
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [df setDateFormat:@"yyyy-MM-dd 00:00"];
    NSDate *valiDate = [df dateFromString:validDateString];
    NSDate *alarmDate = [df dateFromString:alarmDateString];
    
    NSDate *initDate = [df dateFromString:initialDate];
   
    NSComparisonResult result; 
    result = [initDate compare:valiDate]; // comparing two dates
    
    
    if(result==NSOrderedAscending || result==NSOrderedSame)
        NSLog(@"Date is valid...");
    else if(result==NSOrderedDescending)
        return NO;

    
    
/*    result = [initDate compare:alarmDate]; // comparing two dates
    if(result==NSOrderedAscending || result==NSOrderedSame)
         NSLog(@"Alarm Date is valid...");
    else if(result==NSOrderedDescending)
        return NO;
 */   
    
    return YES;
}



- (IBAction)addNewEntryButtonClicked:(id)sender 
{
    
    if (!editedEntryGuid) {
        editedEntryGuid = [LocalDatabase stringWithUUID];
    }
    
    
    NSString *dayString = calendarDateDayTextField.text;
    NSString *monthString = calendarDateMonthTextField.text;
    NSString *minuteString = calendarDateMinuteTextField.text;
    NSString *hourString = calendarDateHourTextField.text;
    
    
    if ([monthString intValue] < 10 && [monthString length]==1) {
        monthString = [NSString stringWithFormat:@"0%@", monthString];
    }
    if ([dayString intValue]<10 && [dayString length]==1) {
        dayString = [NSString stringWithFormat:@"0%@", dayString];
    }
    if ([minuteString intValue] < 10 && [minuteString length]==1) {
        minuteString = [NSString stringWithFormat:@"0%@", minuteString];
    }
    if ([hourString intValue]<10 && [hourString length]==1) {
        hourString = [NSString stringWithFormat:@"0%@", hourString];
    }
    NSString *validDateString = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", calendarDateYearTextField.text, monthString, dayString, hourString, minuteString];
    
    
    monthString = calendarAlarmMonthTextField.text;
    dayString = calendarAlarmDayTextField.text;
    minuteString = calendarAlarmMinuteTextField.text;
    hourString = calendarDateHourTextField.text;
    
    
    if ([monthString intValue] < 10 && [monthString length]==1) {
        monthString = [NSString stringWithFormat:@"0%@", monthString];
    }
    if ([dayString intValue]<10 && [dayString length]==1) {
        dayString = [NSString stringWithFormat:@"0%@", dayString];
    }
    
    if ([hourString intValue] < 10 && [hourString length]==1) {
        hourString = [NSString stringWithFormat:@"0%@", hourString];
    }
    if ([minuteString intValue]<10 && [minuteString length]==1) {
        minuteString = [NSString stringWithFormat:@"0%@", minuteString];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    

    if (!dateString) {
        dateString = [NSString stringWithFormat:@"%@", [df stringFromDate:[NSDate date]]];
    }
    [df release];
    
    NSString *alarmDateString = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", calendarAlarmYearTextField.text, monthString, dayString, hourString, minuteString];
    
        
    
    if([self validateEntry:dateString withValidDate:validDateString withAlarmDate:alarmDateString]) {
    
        NSMutableDictionary *dataDict = [[[NSMutableDictionary alloc] init] autorelease];
        [dataDict setObject:editedEntryGuid forKey:@"guid"];
        [dataDict setObject:calendarTitle.text forKey:@"title"];
        [dataDict setObject:calendarBody.text forKey:@"body"];
        [dataDict setObject:dateString forKey:@"date"];
        [dataDict setObject:validDateString forKey:@"validDate"];
        [dataDict setObject:alarmDateString forKey:@"alarmDate"];
    //    [dataDict setObject:[NSNumber numberWithInt:repeatAlarmSwitch.on] forKey:@"repeat"];
        [dataDict setObject:[NSString stringWithFormat:@"%d", calendarCompleatedState.on] forKey:@"completed"];
        [dataDict setObject:@"0" forKey:@"repeat"];
        [dataDict setObject:@"0" forKey:@"alarmState"];
        [dataDict setObject:@" " forKey:@"imageURL"];
        [dataDict setObject:@"1" forKey:@"type"];
        [dataDict setObject:@"0" forKey:@"homework_ref_id"];

        
        [[CalendarDataClass sharedInstance] insertEventToCalendar:dataDict];
        [[CalendarDataClass sharedInstance] reloadEntity];
        
//        [self.controller displayDailyEvents];
        [self.controller displayWeeklyEvents];
        
        [[CalendarDataClass sharedInstance] insertEventToRemoteDatabase:dataDict];
        
        NSLog(@"add button clicked");
        [popup dismissPopoverAnimated:YES];
        
        [self.controller.calendarView.calendarComponent drawCalendarForDate:[NSDate date]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Caution", NULL) message:NSLocalizedString(@"Add Entry", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", NULL) otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *entryGuid = [self.currentDictionary objectForKey:@"id"];
        
        NSString *deleteLocalSQL = [NSString stringWithFormat:@"delete from calendar where id = '%@' and type = '1'", entryGuid];
        [[LocalDatabase sharedInstance] executeQuery:deleteLocalSQL];
        
        NSString *deleteRemoteSQL = [NSString stringWithFormat:@"delete from receivedNotifications where guid = '%@'", entryGuid];
        [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:deleteRemoteSQL];
        
        deleteRemoteSQL = [NSString stringWithFormat:@"delete from notification where guid = '%@'", entryGuid];
        [DWDatabase getResultFromURL:[NSURL URLWithString:@"http://www.dualware.com/Service/EU/protocol.php"] withSQL:deleteRemoteSQL];
        
        [[CalendarDataClass sharedInstance] reloadEntity];
        [self.controller displayWeeklyEvents];
    }
    else if (buttonIndex == 0)
    {
        NSLog(@"Cancel Button clicked...");
    }
}
- (IBAction)deleteEntryFromLists:(id)sender 
{
    
    NSLog(@"dict - %@", [self.currentDictionary description]);
    if ([[self.currentDictionary valueForKey:@"type"] intValue] == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Caution", NULL) message:NSLocalizedString(@"Delete Entry", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", NULL) otherButtonTitles:NSLocalizedString(@"Yes", NULL), nil];
        [alert show];
        [alert release];
        
    }
    else if ([[self.currentDictionary valueForKey:@"type"] intValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Caution", NULL) message:NSLocalizedString(@"System Entry", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", NULL) otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

}
 

@end

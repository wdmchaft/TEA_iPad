//
//  NewEntryView.h
//  TEA_iPad
//
//  Created by Ertan Şinik on 20.02.2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarDataController.h"


@interface NewEntryView : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
    UIPopoverController *popup;
    CalendarDataController *controller;
    
    NSString *editedEntryGuid;
    NSString *dateString;
    
    NSDictionary *currentDictionary;
    
    

}

@property (retain, nonatomic) NSDictionary *currentDictionary;


@property (retain, nonatomic) NSString *editedEntryGuid;
@property (retain, nonatomic) NSString *dateString;

@property (assign, nonatomic) CalendarDataController *controller;


@property (retain, nonatomic) IBOutlet UILabel *calendarGuid;
@property (retain, nonatomic) IBOutlet UITextField *calendarTitle;
@property (retain, nonatomic) IBOutlet UITextView *calendarBody;

@property (retain, nonatomic) IBOutlet UITextField *calendarImageURL;

@property (retain, nonatomic) IBOutlet UIPopoverController *popup;
@property (retain, nonatomic) IBOutlet UIButton *addButton;

- (IBAction)addNewEntryButtonClicked:(id)sender;


//Date time
@property (retain, nonatomic) IBOutlet UITextField *calendarDateDayTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarDateMonthTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarDateYearTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarDateHourTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarDateMinuteTextField;


//Alarm Date and Time
@property (retain, nonatomic) IBOutlet UITextField *calendarAlarmDayTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarAlarmMonthTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarAlarmYearTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarAlarmHourTextField;
@property (retain, nonatomic) IBOutlet UITextField *calendarAlarmMinuteTextField;
@property (retain, nonatomic) IBOutlet UISwitch *calendarAlarmState;
@property (retain, nonatomic) IBOutlet UISwitch *repeatAlarmSwitch;


@property (retain, nonatomic) IBOutlet UISwitch *calendarCompleatedState;

@property (retain, nonatomic) IBOutlet UILabel *calendarCompletedLabel;

- (IBAction)deleteEntryFromLists:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *deleteButton;
@end

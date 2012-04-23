//
//  LibraryView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 10/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateView.h"
#import "NotebookWorkspace.h"
#import "Notebook.h"
#import "NumericPad.h"
#import "Sync.h"
#import "Homework.h"
#import "NotebookSync.h"
#import "SyncUploadiPadDataService.h"
#import "ActivityIndicator.h"
#import "ContentViewerInterface.h"
#import "CalendarDataController.h"

enum kSyncServiceType {
    kSyncServiceTypeiPadSync = 0,
    kSyncServiceTypeHomeworkSync = 1,
    kSyncServiceTypeNotebookSync = 2,
    kSyncServiceTypeSync = 3
    };

@class DWDrawingViewController, LectureView, MonthView, DWSearchBar;
@interface LibraryView : UIViewController <UIAccelerometerDelegate, UITextFieldDelegate> {


    
    UIPopoverController *numericPadPopover;
    
    UIButton *libraryButton;
    UIButton *notebookButton;
    UIButton *calendarButton;
    UIButton *guestEnterButton;
    
    UIScrollView *sessionNameScrollView;
    UIScrollView *monthsScrollView;
    UIScrollView *lectureNamesScrollView;
    UIScrollView *contentsScrollView;
    DateView *dateView;
    UIImageView *backgroundView;
    UIProgressView *contentProgress;
    
    //DWDrawingViewController *drawingViewController;
    NotebookWorkspace *notebookWorkspace;
    Notebook *notebook;
    BOOL compactMode;

    LectureView *selectedLecture;
    MonthView *selectedMonth;
    int selectedDate;
    UIImageView *logonGlow;
    
    UIView *blackScreen;
    Sync *syncView;
    SyncUploadiPadDataService *syncUploadiPadView;
    Homework *homeworkService;
    NotebookSync *notebookSyncService;
    
    BOOL screenClosed;

    CalendarDataController *calendarController;
    ActivityIndicator *activity;
    
    NSMutableArray *lectureViews;
    NSMutableArray *sessionList;
    NSMutableArray *sessionLibraryItems;
    NSMutableArray *swipeItems;
    
    int currentSessionListIndex;
    int currentContentsIndex;
    BOOL displayingSessionContent;

    BOOL refreshDateSkipped;

    id<ContentViewerInterface> currentContentView;
    NSString *optionalKeyword;
}

//Calendar
@property (nonatomic, assign) CalendarDataController *calendarController;
- (void) setCalendarViewHidden:(BOOL) hidden;
- (void) refreshLibraryView;
- (void) startSyncService:(int) syncServiceType;

@property (nonatomic, assign) int currentSessionListIndex;
@property (nonatomic, assign) BOOL displayingSessionContent;
@property (nonatomic, assign) id<ContentViewerInterface> currentContentView;
@property (nonatomic, assign) int currentContentsIndex;
@property (nonatomic, retain) UIButton *guestEnterButton;
@property (nonatomic, retain) IBOutlet UIProgressView *contentProgress;
@property (nonatomic, retain) UIPopoverController *numericPadPopover;
@property (nonatomic, retain) IBOutlet UIScrollView *sessionNameScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *monthsScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *lectureNamesScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *contentsScrollView;
@property (nonatomic, retain) IBOutlet DateView *dateView;
@property (nonatomic, assign) BOOL compactMode;
@property (nonatomic, assign) NotebookWorkspace *notebookWorkspace;;
@property (nonatomic, retain) Sync *syncView;
@property (nonatomic, retain) SyncUploadiPadDataService *syncUploadiPadView;

@property (nonatomic, retain) Homework *homeworkService;
@property (nonatomic, retain) NotebookSync *notebookSyncService;
@property (nonatomic, assign) Notebook *notebook;
@property (nonatomic, assign) NSMutableArray *lectureViews;

@property (nonatomic, assign) LectureView *selectedLecture;
@property (nonatomic, assign) MonthView *selectedMonth;
@property (nonatomic, assign) int selectedDate;
@property (nonatomic, retain) IBOutlet UIImageView *logonGlow;

@property (nonatomic, retain) NSMutableArray *sessionLibraryItems;
@property (nonatomic, assign) NSMutableArray *swipeItems;

@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (retain, nonatomic) IBOutlet DWSearchBar *searchTextField;
@property (nonatomic, retain) NSString *optionalKeyword;


- (void) receivedContentBytes:(NSDictionary*) userInfo ;
- (void) initLectureNames;
- (void) initSessionNames;
- (void) contentViewClosed:(id)contentView;
- (void) fillSwipeItems;

- (IBAction) libraryButtonClicked:(id) sender;
- (IBAction) notebookButtonClicked:(id) sender;
- (IBAction) calendarButtonClicked:(id) sender;
- (IBAction)searchButtonClicked:(id)sender;

- (void) setLibraryViewHidden:(BOOL) hidden;
- (void) setNotebookViewHidden:(BOOL) hidden;
- (void) setNotebookHidden:(BOOL) hidden;
- (void) selectLecture:(LectureView *) lecture;

@end

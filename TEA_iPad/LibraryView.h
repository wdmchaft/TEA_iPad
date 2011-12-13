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

@class DWDrawingViewController, LectureView, MonthView;
@interface LibraryView : UIViewController <UIAccelerometerDelegate> {
    
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
    
    NSMutableArray *lectureViews;
    
    LectureView *selectedLecture;
    MonthView *selectedMonth;
    int selectedDate;
    UIImageView *logonGlow;
    
    UIView *blackScreen;
    Sync *syncView;
    
    BOOL screenClosed;
}
@property (nonatomic, retain) UIButton *guestEnterButton;
@property (nonatomic, retain) IBOutlet UIProgressView *contentProgress;
@property (nonatomic, retain) UIPopoverController *numericPadPopover;
@property (nonatomic, retain) IBOutlet UIScrollView *sessionNameScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *monthsScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *lectureNamesScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *contentsScrollView;
@property (nonatomic, retain) IBOutlet DateView *dateView;
@property (nonatomic, assign) BOOL compactMode;
@property (nonatomic, assign) Sync *syncView;
@property (nonatomic, assign) Notebook *notebook;
@property (nonatomic, assign) NSMutableArray *lectureViews;

@property (nonatomic, assign) LectureView *selectedLecture;
@property (nonatomic, assign) MonthView *selectedMonth;
@property (nonatomic, assign) int selectedDate;
@property (nonatomic, retain) IBOutlet UIImageView *logonGlow;


@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
- (void) receivedContentBytes:(NSDictionary*) userInfo ;
- (void) initLectureNames;
- (void) initSessionNames;


- (IBAction) libraryButtonClicked:(id) sender;
- (IBAction) notebookButtonClicked:(id) sender;
- (IBAction) calendarButtonClicked:(id) sender;

- (void) setLibraryViewHidden:(BOOL) hidden;
- (void) setNotebookViewHidden:(BOOL) hidden;
- (void) setNotebookHidden:(BOOL) hidden;
- (void) selectLecture:(LectureView *) lecture;

@end

//
//  LibraryView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 10/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LibraryView.h"
#import "MonthView.h"
#import "LocalDatabase.h"
#import "LectureView.h"
#import "SessionView.h"
#import <QuartzCore/QuartzCore.h>
#import "DWDrawingViewController.h"
#import "Notebook.h"
#import "TEA_iPadAppDelegate.h"

@implementation LibraryView
@synthesize contentProgress;
@synthesize sessionNameScrollView;
@synthesize monthsScrollView;
@synthesize lectureNamesScrollView;
@synthesize contentsScrollView;
@synthesize dateView;
@synthesize backgroundView;
@synthesize compactMode;
@synthesize notebook;
@synthesize lectureViews;

@synthesize selectedLecture;
@synthesize selectedMonth;
@synthesize selectedDate;
@synthesize logonGlow;
@synthesize guestEnterButton;
@synthesize syncView;
@synthesize homeworkService;
@synthesize numericPadPopover;

- (void) refreshDate:(NSDate*)aDate
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.state != kAppStateSyncing)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
        
        int year = [components year];
        int month = [components month];
        int day = [components day];
        
        for(MonthView *monthView in [monthsScrollView subviews])
        {
            if(monthView.month == month && monthView.year == year)
            {
                [monthView touchesEnded:nil withEvent:nil];
                self.selectedMonth = monthView;
                break;
            }
        }
        
        self.selectedDate = day;
        [self.dateView selectDate:day - 1];
        
        [self initSessionNames];
    }
    

}

- (void) setLibraryViewHidden:(BOOL) hidden
{
    if(!hidden)
    {
        [self setNotebookHidden:YES];
        [self setNotebookViewHidden:YES];
        [backgroundView setImage:[UIImage imageNamed:@"LibraryBG.jpg"]];
    }
    
    [sessionNameScrollView setHidden:hidden];
    [sessionNameScrollView setHidden:hidden];
    [monthsScrollView setHidden:hidden];
    [lectureNamesScrollView setHidden:hidden];
    [contentsScrollView setHidden:hidden];
    [dateView setHidden:hidden];
    
}

- (void) setNotebookViewHidden:(BOOL) hidden
{
    if(!hidden)
    {
        [self setNotebookHidden:YES];
        [self setLibraryViewHidden:YES];
        [backgroundView setImage:[UIImage imageNamed:@"LibraryEmpty.jpg"]];
        
    }
    
    [notebookWorkspace setHidden:hidden];
    
}

- (void) setNotebookHidden:(BOOL) hidden;
{
    if(!hidden)
    {
        [self setNotebookViewHidden:YES];
        [self setLibraryViewHidden:YES];
    }
    
    if([notebook.type isEqualToString:@""] || [notebook.type isEqualToString:@"squared"])
    {
        [backgroundView setImage:[UIImage imageNamed:@"NoteBookBGSquared.jpg"]]; 
    }
    else if([notebook.type isEqualToString:@"lined"])
    {
        [backgroundView setImage:[UIImage imageNamed:@"NoteBookBGLined.jpg"]]; 
    }
    else if([notebook.type isEqualToString:@"blank"])
    {
        [backgroundView setImage:[UIImage imageNamed:@"NoteBookBGBlank.jpg"]]; 
    }

    
    [notebook setHidden:hidden];
    
    if(notebook.state == kStateOpened)
    {
        [notebook notebookClose];
    }
}



- (void) initMonthView
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit fromDate:[NSDate date]];
    
    int year = [components year];
    int month = [components month];
    
    int counter = 0;
    for(int i=year - 2; i < year + 2; i++)
    {
        for(int c=1; c <= 12; c++)
        {
            CGRect monthRect = CGRectMake( 243 * counter, 0, 243, 37);
            MonthView *monthView = [[MonthView alloc] initWithFrame:monthRect];
            monthView.month = c;
            monthView.year = i;
            [monthsScrollView addSubview:monthView];
            monthView.viewController = self;
            [monthView release];
            counter++;
            
            if(i == year && c == month)
            {
                // select current month
                self.selectedMonth = monthView;
            }
        }
    }
    
    monthsScrollView.contentSize = CGSizeMake(243 * counter, 37);
    [self.selectedMonth setSelected:YES];
}

- (void) initSessionNames
{
     
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    [comps setDay:self.selectedDate];
    [comps setMonth:self.selectedMonth.month];
    [comps setYear:self.selectedMonth.year];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:comps];
    [gregorian release];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    NSString *sql = [NSString stringWithFormat: @"select * from session where date = '%@'", dateString];
    
    
    if(selectedLecture)
    {
        NSString *lectureGuid = selectedLecture.lecture_guid;
        sql = [sql stringByAppendingFormat:@" and lecture_guid='%@'", lectureGuid];
    }
    
   // NSString *lectureGuid = 
    
    // Clean up lecture names
    for(SessionView *sessionV in contentsScrollView.subviews)
    {
        //[sessionV release];
        [sessionV removeFromSuperview];
    }
    
    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:sql];
    
    int counter = 0;
    CGRect sessionViewRect = CGRectMake(0, 0, 0, 0);
    
    for(NSDictionary *resultDict in result)
    {
        sessionViewRect = CGRectMake(0, sessionViewRect.origin.y + sessionViewRect.size.height + 20, contentsScrollView.frame.size.width, 300);
        SessionView *sessionView = [[SessionView alloc] initWithFrame:sessionViewRect];
        sessionView.libraryViewController = self;
        sessionView.sessionName = [resultDict valueForKey:@"name"];
        sessionView.sessionGuid = [resultDict valueForKey:@"session_guid"];
        
        [contentsScrollView addSubview:sessionView];
        [sessionView initSessionView];
        [sessionView release];
        counter++;
        sessionViewRect = sessionView.frame;
    }
    

    contentsScrollView.contentSize = CGSizeMake(contentsScrollView.frame.size.width, sessionViewRect.size.height + sessionViewRect.origin.y + 50);
}

- (void) initLectureNames
{
    
    // Clean up lecture names
    for(UIView *lectureV in lectureNamesScrollView.subviews)
    {
        [lectureV removeFromSuperview];
    }
    

    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery:@"select * from lecture"];
    
    int counter = 0;
    for(NSDictionary *resultDict in result)
    {
        CGRect lectureViewRect = CGRectMake(0, counter * 52, 177, 52);
        LectureView *lectureView = [[LectureView alloc] initWithFrame:lectureViewRect];
        lectureView.lectureName = [resultDict valueForKey:@"lecture_name"];
        lectureView.lecture_guid = [resultDict valueForKey:@"lecture_guid"];
        lectureView.viewController = self;
        
        [lectureNamesScrollView addSubview:lectureView];
        [lectureView release];
        
        [lectureViews addObject:lectureView];
        counter++;
    }
    lectureNamesScrollView.contentSize = CGSizeMake(177, 52 * counter);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        
    }
    return self;
}

- (void)dealloc
{
    if(notebookWorkspace)
        [notebookWorkspace release];
    
    [numericPadPopover release];
    [syncView release];
    [homeworkService release];
    [lectureViews release];
    [guestEnterButton release];
    [sessionNameScrollView release];
    [monthsScrollView release];
    [lectureNamesScrollView release];
    [contentsScrollView release];
    [contentProgress release];
    [dateView release];
    [backgroundView release];
    [logonGlow release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{

    if (acceleration.z >= 0.8 && !screenClosed)
    {
        [self.view addSubview:blackScreen];
    }
    else
    {
        [blackScreen removeFromSuperview];
        screenClosed = NO;
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:0.2];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    
    blackScreen = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [blackScreen setBackgroundColor:[UIColor blackColor]];
    
        
    
    if(!compactMode)
    {
        lectureViews = [[NSMutableArray alloc] init];
        
        libraryButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 35, 81, 91)];
        [libraryButton setImage:[UIImage imageNamed:@"LibraryIcon.png"] forState:UIControlStateNormal];
        [libraryButton addTarget:self action:@selector(libraryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:libraryButton];
        [libraryButton release];
        
        notebookButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 158, 81, 91)];
        [notebookButton setImage:[UIImage imageNamed:@"NoteBookIcon.png"] forState:UIControlStateNormal];
        [notebookButton addTarget:self action:@selector(notebookButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:notebookButton];
        [notebookButton release];
    
#ifdef HAS_GUEST_ENTER
        guestEnterButton = [[UIButton alloc] initWithFrame:CGRectMake(19, 280, 62, 71)];
        [guestEnterButton setImage:[UIImage imageNamed:@"LibraryGuestEnter.png"] forState:UIControlStateNormal];
        [guestEnterButton addTarget:self action:@selector(guestStudentEnterClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:guestEnterButton];
        [guestEnterButton release];
#endif        
        notebookWorkspace = [[NotebookWorkspace alloc] initWithFrame:CGRectMake(136, 34, 855, 706)];
        [notebookWorkspace  setHidden:YES];
        [self.view addSubview:notebookWorkspace ];
        [notebookWorkspace setBackgroundColor:[UIColor clearColor]];
        
        self.notebook = [[Notebook alloc] initWithFrame:CGRectMake(195, 58, 789, 655)];
        [self.notebook  setHidden:YES];
        [self.view addSubview:notebook ];
        [self.notebook setBackgroundColor:[UIColor clearColor]];
                
        
        [sessionNameScrollView setHidden:NO];
        
        
        
    }
    else
    {
        [sessionNameScrollView setHidden:YES];
    }
    dateView.controller = self;
    [self initMonthView];
    [self initLectureNames];
    
    blackScreen = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [blackScreen setBackgroundColor:[UIColor blackColor]];
    
    self.homeworkService = [[Homework alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [homeworkService setHidden:YES];
    homeworkService.libraryViewController = self;
    [self.view addSubview:homeworkService];
    [homeworkService requestForHomework];
    [homeworkService release];
    
    

}

- (void) selectLecture:(LectureView *) lecture
{
    for(LectureView *lectureView in lectureViews)
    {
        [lectureView selectLecture:NO];
    }
    
    [lecture selectLecture:YES];
    self.selectedLecture = lecture;
}

- (void) receivedContentBytes:(NSDictionary*) userInfo;
{
    CGFloat bytes = [[userInfo objectForKey:@"bytes"] floatValue];
    CGFloat totalBytes = [[userInfo objectForKey:@"totalBytes"] floatValue];
    
    [self.view bringSubviewToFront:contentProgress];
    [contentProgress setHidden:NO];
    CGFloat progress = (CGFloat)bytes / (CGFloat)totalBytes;
    contentProgress.progress = progress;
    [contentProgress setNeedsDisplay];
  
    NSLog(@"current progress is %f", progress); 
    
    if( fabsf(1.0 - progress) <= 0.1 )
    {
        [contentProgress setHidden:YES];
    }
}

- (void)viewDidUnload
{
    [self setSessionNameScrollView:nil];
    [self setMonthsScrollView:nil];
    [self setLectureNamesScrollView:nil];
    [self setContentsScrollView:nil];
    [self setContentProgress:nil];
    [self setDateView:nil];
    [self setBackgroundView:nil];
    [self setLogonGlow:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
        return YES;
    else
        return NO;
}

- (IBAction) libraryButtonClicked:(id) sender
{
    [self setNotebookViewHidden:YES];
    [self setLibraryViewHidden:NO];
}

- (IBAction) notebookButtonClicked:(id) sender
{
    [self setNotebookViewHidden:NO];
    [self setLibraryViewHidden:YES];
}

- (IBAction) guestStudentEnterClicked:(id) sender
{
    NumericPad *numericPad = [[[NumericPad alloc] initWithNibName:@"NumericPad" bundle:nil] autorelease];
    self.numericPadPopover = [[[UIPopoverController alloc] initWithContentViewController:numericPad] autorelease];
    numericPad.popup = self.numericPadPopover;
    self.numericPadPopover.popoverContentSize = numericPad.view.frame.size;
    [self.numericPadPopover presentPopoverFromRect:((UIButton*)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}

- (IBAction) calendarButtonClicked:(id) sender
{
    
}

@end

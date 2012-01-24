//
//  HWView.m
//  TEA_iPad
//
//  Created by Ertan Şinik on 1/12/12.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import "HWView.h"
#import "HWParser.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "TEA_iPadAppDelegate.h"
#import "LocalDatabase.h"

@implementation HWView

@synthesize answerSheetView, parser, questionImageURL, currentQuestion, timer, zipFileName, titleOfHomework, homeworkGuid, delivered;

- (int) returnCurrentQuestion
{
    return currentQuestion;
}

- (void) showQuestion:(int) questionIndex
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    questionImageURL = [[[parser.quiz objectForKey:@"questions"] objectAtIndex:questionIndex - 1] objectForKey:@"imageURL"];
    
    NSData *imageData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", documentsPath, questionImageURL]];
    //[questionView loadData:imageData MIMEType:@"image/png" textEncodingName:nil baseURL:nil];
    [questionView setImage:[UIImage imageWithData:imageData]];
    [answerSheetView selectQuestion:questionIndex];
    currentQuestion = questionIndex;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender 
{    
    return NO;
}

- (id)initWithFrame:(CGRect)frame andZipFileName:(NSString*) aZipFileName andHomeworkId:(NSString*) aHomeworkGUID
{
    self = [super initWithFrame:frame];
    if (self) {
        
       // TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
        
        self.zipFileName = aZipFileName;
        self.homeworkGuid = aHomeworkGUID;
        // extract zip file
        [self extractZipFile];
        
        
        // get file data
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSData *parsableFile = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.xml", documentsPath, [[zipFileName componentsSeparatedByString:@"."]objectAtIndex:0]]];
        
        
        // Initialization code
        currentQuestion = 1;
        parser = [[HWParser alloc] init];
        [parser parseXml:parsableFile];
                
        // Set delivered state

        
        NSString *sql = [NSString stringWithFormat:@"select delivered from homework where guid='%@'", homeworkGuid];
        delivered = [[[[[LocalDatabase sharedInstance] executeQuery:sql] objectAtIndex:0] valueForKey:@"delivered"] intValue];
        

        [self removeFromSuperview];
        
        
        backGroundView = [[UIView alloc] initWithFrame:frame];
        [backGroundView setBackgroundColor:[UIColor blackColor]];
        [backGroundView setAlpha:0.7];
        [self addSubview:backGroundView];
        
        hwView = [[[UIView alloc] initWithFrame:CGRectMake(53, 29, 918, 690)] autorelease];
        [hwView setBackgroundColor:[UIColor lightGrayColor]];
        
        titleOfHomework = [[UILabel alloc] initWithFrame:CGRectMake(145, 20, 491, 30)];
        
 //       [titleOfHomework setText:appDelegate.session.sessionLectureName];
        [titleOfHomework setTextAlignment:UITextAlignmentCenter];
        [titleOfHomework setBackgroundColor:[UIColor clearColor]];
        [titleOfHomework setFont:[UIFont fontWithName:@"Helvetica" size:24]];
        [hwView addSubview:titleOfHomework];
        
        
        UIView *questionContainerView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 138, 652, 478)];
        [questionContainerView setBackgroundColor:[UIColor whiteColor]];
        [hwView addSubview:questionContainerView];
        [questionContainerView release];
        
        /*questionView = [[UIWebView alloc] initWithFrame:CGRectMake(50, 50, 652 - 100, 478 - 100)];
        [questionView setBackgroundColor:[UIColor whiteColor]];
        [questionView setScalesPageToFit:NO];
        [questionView becomeFirstResponder];
        */
        
        questionView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 25, 652 - 100, 478 - 50)];
        [questionView setBackgroundColor:[UIColor whiteColor]];
        [questionView setContentMode:UIViewContentModeScaleAspectFit];
        [questionContainerView addSubview:questionView];
        
        prevQuestion = [[UIButton alloc] initWithFrame:CGRectMake(0, 65, 652, 72)];
        [prevQuestion setBackgroundColor:[UIColor whiteColor]];
        [prevQuestion setImage:[UIImage imageNamed:@"HWPrevQuestionButton.png"] forState:UIControlStateNormal];
        [prevQuestion addTarget:self action:@selector(prevQuestionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [hwView addSubview:prevQuestion];
        
        
        nextQuestion = [[UIButton alloc] initWithFrame:CGRectMake(0, 617, 652, 72)];
        [nextQuestion setBackgroundColor:[UIColor whiteColor]];
        [nextQuestion setImage:[UIImage imageNamed:@"HWNextQuestionButton.png"] forState:UIControlStateNormal];
        [nextQuestion addTarget:self action:@selector(nextQuestionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [hwView addSubview:nextQuestion];
        
        
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 12, 95, 43)];
        [closeButton setBackgroundColor:[[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"HWCloseButton.png"]] autorelease]];
        [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor darkGrayColor]	forState:UIControlStateNormal];
        [hwView addSubview:closeButton];
        
        finishButton = [[UIButton alloc] initWithFrame:CGRectMake(758, 12, 147, 43)];
        [finishButton setBackgroundColor:[[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"HWFinishButton.png"]] autorelease]];
        [finishButton addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [finishButton setTitle:NSLocalizedString(@"Finish", nil) forState:UIControlStateNormal];
        [finishButton setTitleColor:[UIColor whiteColor]	forState:UIControlStateNormal];
        [hwView addSubview:finishButton];
        
        if(delivered != kHomeworkDeliveredNormal)
        {
            [finishButton setHidden:YES];
        }

        answerSheetView = [HWAnswerSheet alloc];
        answerSheetView.mainView = self;
        answerSheetView.parsedDictionary = parser.quiz;
        answerSheetView.currentQuestion = currentQuestion;
        answerSheetView.homeworkGuid = homeworkGuid;
        [answerSheetView initWithFrame:CGRectMake(651, 65, 265, 625)];
        [answerSheetView setBackgroundColor:[UIColor whiteColor]];
        [hwView addSubview:answerSheetView];
         
        
        
        
        
        [self showQuestion:currentQuestion];
        
        
        // add timer
        self.timer = [[[Timer alloc] initWithFrame:CGRectMake(651, 13, 78, 43)] autorelease];
        [hwView addSubview:self.timer];
        [self.timer setCurrentSecond:0];
        [self.timer setRunForward:YES];
        [self.timer startTimer];
        [self.timer setHidden:YES];
        
        [self addSubview:hwView];
        
        
        
        
        
    }
    return self;
}

- (IBAction)prevQuestionButtonClicked:(id)sender
{
    if (currentQuestion > 1) {
        currentQuestion--;
        [self showQuestion:currentQuestion];
    }
}

- (IBAction)nextQuestionButtonClicked:(id)sender
{
    if (currentQuestion < ([[parser.quiz objectForKey:@"questions"] count])) {
        currentQuestion++;
        [self showQuestion:currentQuestion];
    }
    
}


- (IBAction)closeButtonClicked:(id)sender
{
    [self removeFromSuperview];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
    if (buttonIndex == 1)
    {
        if(delivered == kHomeworkDeliveredNormal)
        {

            
            NSString *sql = [NSString stringWithFormat:@"update homework set delivered = '-1' where guid='%@'", homeworkGuid];
            [[LocalDatabase sharedInstance] executeQuery:sql];

        }
        
        [self removeFromSuperview];
        
    }
}

- (IBAction)finishButtonClicked:(id)sender
{
    
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Caution", nil) message:NSLocalizedString(@"FinishHomeworkWarning", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil] autorelease];
    
    [alertView show];
    
    
}

- (void)dealloc {
    [homeworkGuid release];
    [titleOfHomework release];
    [zipFileName release];
    [timer release];
    [parser release];
    [hwView release];
    [questionView release];
    [prevQuestion release];
    [nextQuestion release];
    [closeButton release];
    [answerSheetView release];
    [backGroundView release];
    [super dealloc];
}


- (void) extractZipFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    /*    NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:documentsPath];
     NSString *fileName = [dirContents ];
     */  
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsPath, zipFileName];
    
    ZipFile *zippedFile = [[[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip] autorelease];
    [zippedFile goToFirstFileInZip];
    
    BOOL continueReading = YES;
    while (continueReading) {
        
        // Get file info
        FileInZipInfo *info = [zippedFile getCurrentFileInZipInfo];
        
        // Read data into buffer
        ZipReadStream *stream = [zippedFile readCurrentFileInZip];
        NSMutableData *data2 = [[NSMutableData alloc] initWithLength:info.length];
        [stream readDataWithBuffer:data2];
        
        // Save data to file
        NSString *writePath = [documentsPath stringByAppendingPathComponent:info.name];
        NSError *error = nil;
        [data2 writeToFile:writePath options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"Error unzipping file: %@", [error localizedDescription]);
        }
        
        // Cleanup
        [stream finishedReading];
        [data2 release];
        
        // Check if we should continue reading
        continueReading = [zippedFile goToNextFileInZip];
    }
    
    [zippedFile close];
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

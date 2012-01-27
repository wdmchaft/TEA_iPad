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

@synthesize answerSheetView, parser, questionImageURL, currentQuestion, timer, zipFileName, titleOfHomework, homeworkGuid, delivered, questionTimer;

- (int) getCurrentQuestionTimer
{
    int timers;
    if ([self.questionTimer currentMinute] != 0) {
        timers = [self.questionTimer currentMinute]*60 + [self.questionTimer currentSecond];
    }
    else
        timers = [self.questionTimer currentSecond];
    
    return timers;
    
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
        
//***********************************************************************        
        self.questionTimer = [[[Timer alloc] initWithFrame:CGRectMake(0, 0, 78, 43)] autorelease];
        [questionContainerView addSubview:self.questionTimer];
        
        
        NSString *selectHomeworkAnswer = [NSString stringWithFormat:@"select time from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [NSString stringWithFormat:@"%d", 1]];
        
        NSArray *rows = [[LocalDatabase sharedInstance] executeQuery:selectHomeworkAnswer];
        
        
        if (![rows isEqual:[NSNull null]] && ([rows count]>0)) {
            
            if (delivered != -1) {
                [self.questionTimer setCurrentSecond:[[[rows objectAtIndex:0] valueForKey:@"time"] intValue]];
                [self.questionTimer setRunForward:YES];
                [self.questionTimer startTimer];
            }
            else
            {
                [self.questionTimer setCurrentSecond:[[[rows objectAtIndex:0] valueForKey:@"time"] intValue]];
            }
            //            [self.timer setHidden:NO]
        }
        else{
            [self.questionTimer setCurrentSecond:0];
            [self.questionTimer setRunForward:YES];
            [self.questionTimer startTimer];
            
        }
        [self.questionTimer setHidden:YES];
        
//***********************************************************************
        
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
        
//***********************************************************************        
        // add timer
        self.timer = [[[Timer alloc] initWithFrame:CGRectMake(651, 13, 78, 43)] autorelease];
        [hwView addSubview:self.timer];
        
        NSString *selectSql = [NSString stringWithFormat:@"select total_time from homework where guid = '%@'", homeworkGuid];
        
        NSDictionary *dictionary = [[[LocalDatabase sharedInstance] executeQuery:selectSql] objectAtIndex:0];
        
        if (delivered == 0) {
            [self.timer setCurrentSecond:[[dictionary objectForKey:@"total_time"]intValue]];
            [self.timer setRunForward:YES];
            [self.timer startTimer];
            //            [self.timer setHidden:NO]
        }
        else{
            [self.timer setCurrentSecond:[[dictionary objectForKey:@"total_time"]intValue]];
        }
        
//***********************************************************************
        
        
        [self addSubview:hwView];
        
    }
    return self;
}

- (IBAction)prevQuestionButtonClicked:(id)sender
{
//***********************************************************************    
//***********************************************************************    
    int timers = [self.questionTimer currentSecond];
    NSLog(@"%d", timers);
    
    if ([self.questionTimer currentMinute] != 0) {
        timers = [self.questionTimer currentMinute]*60 + [self.questionTimer currentSecond];
    }
    else
        timers = [self.questionTimer currentSecond];
    
    
    NSDictionary *dataDict = [[parser.quiz objectForKey:@"questions"] objectAtIndex:currentQuestion-1];
    
    NSString *selectHWans = [NSString stringWithFormat:@"select * from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
    NSArray *allHWansTable = [[LocalDatabase sharedInstance] executeQuery:selectHWans];
    
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
    [[LocalDatabase sharedInstance] executeQuery:deleteSql];
    
    
    NSString *updateSql;
    if ([allHWansTable count]>0 && ![allHWansTable isEqual:[NSNull null]]) {
        updateSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, answer, correct_answer, selected_option, time) values ('%@', '%@', '%@', '%@', '%@', '%d')", homeworkGuid, [dataDict objectForKey:@"number"], [[allHWansTable objectAtIndex:0] objectForKey:@"answer"], [dataDict  objectForKey:@"correctAnswer"], [[[allHWansTable objectAtIndex:0] objectForKey:@"selected_option"] intValue], timers];
    }
    else {
        updateSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, correct_answer, time) values ('%@', '%@', '@%', '%d')", homeworkGuid, [dataDict objectForKey:@"number"], [dataDict  objectForKey:@"correctAnswer"], timers];
    }
    
    [[LocalDatabase sharedInstance] executeQuery:updateSql];
    if (currentQuestion > 1) {
        currentQuestion--;
        
        
        NSLog(@"%@", [parser.quiz description]);
        
        
        
        NSString *select = [NSString stringWithFormat:@"select time from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
        
        allHWansTable = [[LocalDatabase sharedInstance] executeQuery:select];
        int questionTimers=0;
        
        if ([allHWansTable count]>0 && ![allHWansTable isEqual:[NSNull null]]) {
            questionTimers = [[dataDict objectForKey:@"time"] intValue];
        }
        
        [self.questionTimer setCurrentSecond:questionTimers];
        [self showQuestion:currentQuestion];
    }
    
    
//***********************************************************************    
//***********************************************************************

}

- (IBAction)nextQuestionButtonClicked:(id)sender
{
//***********************************************************************
//***********************************************************************    
    int timers = [self.questionTimer currentSecond];
    NSLog(@"%d", timers);
    
    if ([self.questionTimer currentMinute] != 0) {
        timers = [self.questionTimer currentMinute]*60 + [self.questionTimer currentSecond];
    }
    else
        timers = [self.questionTimer currentSecond];
    
    
    NSDictionary *dataDict = [[self.parser.quiz objectForKey:@"questions"] objectAtIndex:currentQuestion-1];
    
    NSString *selectHWans = [NSString stringWithFormat:@"select * from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
    NSArray *allHWansTable = [[LocalDatabase sharedInstance] executeQuery:selectHWans];
    
    
    NSString *deleteSql = [NSString stringWithFormat:@"delete from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
    [[LocalDatabase sharedInstance] executeQuery:deleteSql];
    
    
    NSString *updateSql;
    if ([allHWansTable count]>0 && ![allHWansTable isEqual:[NSNull null]]) {
        updateSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, answer, correct_answer, selected_option, time) values ('%@', '%@', '%@', '%@', '%@', '%d')", homeworkGuid, [dataDict objectForKey:@"number"], [[allHWansTable objectAtIndex:0] objectForKey:@"answer"], [dataDict objectForKey:@"correctAnswer"], [[allHWansTable objectAtIndex:0] objectForKey:@"selected_option"], timers];
    }
    else {
        updateSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, correct_answer, time) values ('%@', '%@','%@', '%d')", homeworkGuid, [dataDict objectForKey:@"number"], [dataDict objectForKey:@"correctAnswer"], timers];
    }
    
    [[LocalDatabase sharedInstance] executeQuery:updateSql];    
    
    if (currentQuestion < ([[parser.quiz objectForKey:@"questions"] count])) {
        currentQuestion++;
        
        NSString *select = [NSString stringWithFormat:@"select time from homework_answer where homework = '%@' and question = '%d'", homeworkGuid, [dataDict objectForKey:@"number"]];
        
        allHWansTable = [[LocalDatabase sharedInstance] executeQuery:select];
        int questionTimers=0;
        
        if ([allHWansTable count]>0 && ![allHWansTable isEqual:[NSNull null]]) {
            questionTimers = [[[allHWansTable objectAtIndex:0] objectForKey:@"time"] intValue];
        }
        
        [self.questionTimer setCurrentSecond:questionTimers];
        [self showQuestion:currentQuestion];
    }
    
//***********************************************************************
//***********************************************************************
    
}


- (IBAction)closeButtonClicked:(id)sender
{
//***********************************************************************
//***********************************************************************
    int total_timers;// = [self.timer currentSecond];
    int question_timers;// = [self.questionTimer currentSecond];
    
    if (delivered == 0) {

        if ([self.timer currentMinute] != 0) {
            total_timers = [self.timer currentMinute]*60 + [self.timer currentSecond];
        }
        else
            total_timers = [self.timer currentSecond];
        
        
        if ([self.questionTimer currentMinute] != 0) {
            question_timers = [self.questionTimer currentMinute]*60 + [self.questionTimer currentSecond];
        }
        else
            question_timers = [self.questionTimer currentSecond];
        
        
        NSDictionary *dataDict = [[self.parser.quiz objectForKey:@"questions"] objectAtIndex:currentQuestion-1];
        
        NSString *updateHomework = [NSString stringWithFormat:@"update homework set total_time = '%d' where guid = '%@'", total_timers, homeworkGuid];    
        
        [[LocalDatabase sharedInstance] executeQuery:updateHomework];
        
        
        NSString *selectHWans = [NSString stringWithFormat:@"select * from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
        NSArray *allHWansTable = [[LocalDatabase sharedInstance] executeQuery:selectHWans];
        
        
        NSString *deleteSql = [NSString stringWithFormat:@"delete from homework_answer where homework = '%@' and question = '%@'", homeworkGuid, [dataDict objectForKey:@"number"]];
        [[LocalDatabase sharedInstance] executeQuery:deleteSql];
        
        
        
        
        NSString *updateSql;
        if ([allHWansTable count]>0 && ![allHWansTable isEqual:[NSNull null]]) {
            updateSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, answer, correct_answer, time) values ('%@', '%@', '%@', '%@', '%d')", homeworkGuid, [dataDict objectForKey:@"number"], [[allHWansTable objectAtIndex:0] objectForKey:@"answer"], [[allHWansTable objectAtIndex:0] objectForKey:@"correct_answer"], question_timers];
        }
        else {
            updateSql = [NSString stringWithFormat:@"insert into homework_answer (homework, question, correct_answer, time) values ('%@', '%@','%@', '%d')", homeworkGuid, [dataDict objectForKey:@"number"], [dataDict objectForKey:@"correctAnswer"], question_timers];
            
        }
        
        
        [[LocalDatabase sharedInstance] executeQuery:updateSql];
    }
//***********************************************************************
//***********************************************************************    
    
    [self removeFromSuperview];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
    if (buttonIndex == 1)
    {
        if(delivered == kHomeworkDeliveredNormal)
        {
            int timers = [self.timer currentSecond];
            NSLog(@"%d", timers);
            
            if ([self.timer currentMinute] != 0) {
                timers = [self.timer currentMinute]*60 + [self.timer currentSecond];
            }
            else
                timers = [self.timer currentSecond];
            
            NSString *sql = [NSString stringWithFormat:@"update homework set delivered = '-1', total_time = '%d' where guid='%@'", timers, homeworkGuid];
            
            
            [[LocalDatabase sharedInstance] executeQuery:sql];
            
            [finishButton setHidden:YES];
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

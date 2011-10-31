//
//  Quiz.m
//  TEA_iPad
//
//  Created by Oguz Demir on 22/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "Quiz.h"
#import "TEA_iPadAppDelegate.h"
#import "LibraryQuizItem.h"
#import "LocalDatabase.h"
#import "BonjourService.h"

@implementation Quiz
@synthesize timerLabel;
@synthesize quizImage;
@synthesize answerA;
@synthesize answerB;
@synthesize answerC;
@synthesize answerD;
@synthesize answerE;
@synthesize timerView;
@synthesize solveTime;
@synthesize bgView;
@synthesize timerControl;
@synthesize displayMode;
@synthesize guid;
@synthesize correctAnswer;
@synthesize image;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) //ok
    {
        TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
        BonjourMessage *solutionMessage = [[[BonjourMessage alloc] init] autorelease];
        solutionMessage.messageType = kMessageTypeQuizAnswer;
        
        int time = solveTime - timerControl.currentSecond;
        
        NSMutableDictionary *userData = [[[NSMutableDictionary alloc] init] autorelease];
        [userData setValue:self.guid forKey:@"guid"];
        [userData setValue:[NSNumber numberWithInt:currentAnswer] forKey:@"answer"];
        [userData setValue:[NSNumber numberWithInt:time] forKey:@"solutionTime"];
        solutionMessage.userData = userData;
        [appDelegate.bonjourBrowser sendBonjourMessageToAllClients:solutionMessage];
        
        [appDelegate.viewController dismissModalViewControllerAnimated:YES];
    }
}

- (void) sendSolution
{
    
    int asciiCode = 97;
    NSString *alertString = [NSString stringWithFormat:@"Cevabınızı '%c' olarak seçtiniz. Devam etmek istiyor musunuz?", asciiCode + currentAnswer]; 
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Dikkat" message:alertString delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles: @"Gönder", nil];
    
    [alertView show];
    
    
}

- (void) timeIsOver
{
    
    if(!displayMode)
    {
        currentAnswer = -1;
        [self sendSolution];
    }
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate.viewController dismissModalViewControllerAnimated:YES];
    
    [timerControl stopTimer];
    [timerControl release];
    timerControl = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}




- (void)dealloc
{
    [image dealloc];
    [guid release];
    [timerLabel release];
    [quizImage release];
    [answerA release];
    [answerB release];
    [answerC release];
    [answerD release];
    [answerE release];
    [timerView release];
    [bgView release];
    [timerControl release];
    [super dealloc];
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
    [bgView setOpaque:NO];
    [bgView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view  setOpaque:NO];

    timerControl.currentSecond = solveTime;
    timerControl.target = self;
    timerControl.selectorMethod = @selector(timeIsOver);
    [timerControl startTimer];
    
    [quizImage setImage:image];
    
}

- (void) updateCorrectAnswer
{
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db openDatabase];
    
    NSString *sql = [NSString stringWithFormat:@"update library set quizCorrectAnswer = '%d' where guid = '%@'", self.correctAnswer, self.guid];
    [db executeQuery:sql];
    
    [db closeDatabase];
    [db release];
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    if(timerControl)
    {
        [timerControl stopTimer];
        [timerControl release];
        timerControl = nil;
    }
    
    // Save quiz item 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *quizName = [[LocalDatabase stringWithUUID] stringByAppendingString:@".qz"]; 
    NSString *quizImageName = [[LocalDatabase stringWithUUID] stringByAppendingString:@".png"]; 
    NSString *quizPath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], quizName];
    NSString *quizImagePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], quizImageName];
    
    
    LibraryQuizItem *quizItem = [[LibraryQuizItem alloc] init];
    quizItem.name = @"Alıştırma";
    quizItem.path = quizPath;
    quizItem.quizType = 0;
    quizItem.quizReference = 113;
    quizItem.quizExpType =  1;
    quizItem.quizImagePath = quizImagePath;
    quizItem.guid = guid;
    quizItem.quizAnswer = currentAnswer;
    // save image
    [UIImageJPEGRepresentation(quizImage.image, 1.0) writeToFile:quizImagePath atomically:YES];
    [quizItem saveLibraryItem];
    [quizItem release];

}

- (void)viewDidUnload
{
    
    
    [self setTimerLabel:nil];
    [self setQuizImage:nil];
    [self setAnswerA:nil];
    [self setAnswerB:nil];
    [self setAnswerC:nil];
    [self setAnswerD:nil];
    [self setAnswerE:nil];
    [self setTimerView:nil];
    [self setBgView:nil];
    [self setTimerControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (IBAction)answerAClicked:(id)sender 
{
    if(!displayMode)
    {
        currentAnswer = 0;
        [self sendSolution];
    }
}

- (IBAction)answerBClicked:(id)sender 
{
    if(!displayMode)
    {
        currentAnswer = 1;
        [self sendSolution];
    }
}

- (IBAction)answerCClicked:(id)sender 
{
    if(!displayMode)
    {
        currentAnswer = 2;
        [self sendSolution];
    }
}

- (IBAction)answerDClicked:(id)sender 
{
    if(!displayMode)
    {
        currentAnswer = 3;
        [self sendSolution];
    }
}

- (IBAction)answerEClicked:(id)sender 
{
    if(!displayMode)
    {
        currentAnswer = 4;
        [self sendSolution];
    }
}

@end

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
#import "CustomAlert.h"

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
@synthesize lockImage;
@synthesize optionCount;
@synthesize quizExpType;

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
        //[appDelegate.bonjourBrowser sendBonjourMessage:solutionMessage toClient:<#(BonjourClient *)#>
        
        [appDelegate.viewController dismissModalViewControllerAnimated:YES];
    }
    else if(buttonIndex == 0 ) //ok
    {
        displayingAlert = NO;
        
        if(quizFinished)
        {
            // Send empty answer
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            BonjourMessage *solutionMessage = [[[BonjourMessage alloc] init] autorelease];
            solutionMessage.messageType = kMessageTypeQuizAnswer;
            
            int time = solveTime - timerControl.currentSecond;
            
            NSMutableDictionary *userData = [[[NSMutableDictionary alloc] init] autorelease];
            [userData setValue:self.guid forKey:@"guid"];
            [userData setValue:[NSNumber numberWithInt:-1] forKey:@"answer"];
            [userData setValue:[NSNumber numberWithInt:time] forKey:@"solutionTime"];
            solutionMessage.userData = userData;
            [appDelegate.bonjourBrowser sendBonjourMessageToAllClients:solutionMessage];
            
            [appDelegate.viewController dismissModalViewControllerAnimated:YES];
        }
        
    }
}

- (UIColor*) getColorNamed:(NSString*) colorName
{
    if ([colorName isEqualToString:@"Red"]) 
        return [UIColor redColor];
    else if ([colorName isEqualToString:@"Green"]) 
        return [UIColor greenColor];
    else if ([colorName isEqualToString:@"Blue"]) 
        return [UIColor blueColor];
    else if ([colorName isEqualToString:@"White"]) 
        return [UIColor whiteColor];
    else if ([colorName isEqualToString:@"Black"]) 
        return [UIColor blackColor];
    else if ([colorName isEqualToString:@"Yellow"]) 
        return [UIColor yellowColor];
    else if ([colorName isEqualToString:@"Cyan"]) 
        return [UIColor cyanColor];
    else if ([colorName isEqualToString:@"Purple"]) 
        return [UIColor purpleColor];
    else
        return  nil;
}

- (void) sendSolution
{
    
    if(currentAnswer == -1) // empty answer
    {
        if(!displayingAlert)
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
    else
    {
        displayingAlert = YES;
        TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

        int asciiCode = 97; // ascii code of a
        NSString *alertString = [NSString stringWithFormat:NSLocalizedString(@"Answer Send Message", NULL), asciiCode + currentAnswer];   
        NSString *cancel = NSLocalizedString(@"Cancel", NULL);
        NSString *send = NSLocalizedString(@"Send", NULL);
        NSString *caution = NSLocalizedString(@"Caution", NULL);
        
        if(appDelegate.session.quizPromptTitle)
            alertString = appDelegate.session.quizPromptTitle;
        
        if(appDelegate.session.quizPromptCancelTitle)
            cancel = appDelegate.session.quizPromptCancelTitle;
        
        if(appDelegate.session.quizPromptOKTitle)
            send = appDelegate.session.quizPromptOKTitle;
        
        
        
        if([self getColorNamed:appDelegate.session.quizPromptBGColor] && [self getColorNamed:appDelegate.session.quizPromptTextColor])
        {
            CustomAlert *alertView = [[[CustomAlert alloc] initWithTitle:caution message:alertString delegate:self cancelButtonTitle:cancel otherButtonTitles: send, nil] autorelease];
            [alertView setBackgroundColor:[self getColorNamed:appDelegate.session.quizPromptBGColor] withStrokeColor:[self getColorNamed:appDelegate.session.quizPromptTextColor]];
            [alertView show];
        }
        else {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:caution message:alertString delegate:self cancelButtonTitle:cancel otherButtonTitles: send, nil] autorelease];
            [alertView show];
        }
        
        //[alertView setBackgroundColor:<#(UIColor *)#> withStrokeColor:<#(UIColor *)#>]
        
        
    }
    
}


- (void) lockQuizOptions:(BOOL) locked
{
    [lockImage setHidden:!locked];
}



- (void) pauseTimer
{
    timerControl.paused = YES;
}

- (void) continueTimer
{
    quizFinished = NO;
   // displayingAlert = NO;
    
    timerControl.paused = NO;
    [self lockQuizOptions:NO];
}

- (void) finishQuiz
{
    quizFinished = YES;
    
    
    
    if(!displayingAlert)
    {
        if(!displayMode)
        {
            currentAnswer = -1;
            [self sendSolution];
        }
        
        TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
        [appDelegate.viewController dismissModalViewControllerAnimated:YES];
        appDelegate.currentQuizWindow = nil;
        [timerControl stopTimer];
        [timerControl release];
        timerControl = nil;
    }
    
}

- (void) timeIsOver
{
    quizFinished = YES;
    [self lockQuizOptions:YES];
    
    /*
    if(!displayMode)
    {
        currentAnswer = -1;
        [self sendSolution];
    }
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    [appDelegate.viewController dismissModalViewControllerAnimated:YES];
    
    [timerControl stopTimer];
    [timerControl release];
    timerControl = nil;*/
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      //  currentAnswer = -1;
        quizFinished = NO;
        displayingAlert = NO;
    }
    return self;
}




- (void)dealloc
{
    [image release];
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
    [lockImage release];
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
    
   // [quizImage setImage:image];
    
    NSData *imageData = UIImagePNGRepresentation(image); 
    [quizImage loadData:imageData MIMEType:@"image/png" textEncodingName:nil baseURL:nil];
    [quizImage setScalesPageToFit:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(optionCount == 2)
    {
        [answerA setHidden:NO];
        [answerB setHidden:NO];
        [answerC setHidden:YES];
        [answerD setHidden:YES];
        [answerE setHidden:YES];
  
        [answerA setFrame:CGRectMake(202, 513, 56, 56)];
        [answerB setFrame:CGRectMake(283, 513, 56, 56)];
        
    }
    else if(optionCount == 3)
    {
        [answerA setHidden:NO];
        [answerB setHidden:NO];
        [answerC setHidden:NO];
        [answerD setHidden:YES];
        [answerE setHidden:YES];
        
        [answerA setFrame:CGRectMake(160, 513, 56, 56)];
        [answerB setFrame:CGRectMake(243, 513, 56, 56)];
        [answerC setFrame:CGRectMake(324, 513, 56, 56)];

    }
    else if(optionCount == 4)
    {
        [answerA setHidden:NO];
        [answerB setHidden:NO];
        [answerC setHidden:NO];
        [answerD setHidden:NO];
        [answerE setHidden:YES];
        
        [answerA setFrame:CGRectMake(119, 513, 56, 56)];
        [answerB setFrame:CGRectMake(202, 513, 56, 56)];
        [answerC setFrame:CGRectMake(285, 513, 56, 56)];
        [answerD setFrame:CGRectMake(366, 513, 56, 56)];
    }
    else if(optionCount == 5)
    {
        [answerA setHidden:NO];
        [answerB setHidden:NO];
        [answerC setHidden:NO];
        [answerD setHidden:NO];
        [answerE setHidden:NO];
        
        [answerA setFrame:CGRectMake(77,  513, 56, 56)];
        [answerB setFrame:CGRectMake(160, 513, 56, 56)];
        [answerC setFrame:CGRectMake(243, 513, 56, 56)];
        [answerD setFrame:CGRectMake(324, 513, 56, 56)];
        [answerE setFrame:CGRectMake(405, 513, 56, 56)];
    }
    
}

- (void) updateCorrectAnswer
{

    
    NSString *sql = [NSString stringWithFormat:@"update library set quizCorrectAnswer = '%d' where guid = '%@'", self.correctAnswer, self.guid];
    [[LocalDatabase sharedInstance] executeQuery:sql];

}

- (void) saveQuizItem
{
    // Save quiz item 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *quizName = [self.guid stringByAppendingString:@".qz"]; 
    NSString *quizImageName = [self.guid stringByAppendingString:@".png"]; 
    NSString *quizPath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], quizName];
    NSString *quizImagePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], quizImageName];
    
    
    LibraryQuizItem *quizItem = [[LibraryQuizItem alloc] init];
    quizItem.name = @"Alıştırma";
    quizItem.path = quizPath;
    quizItem.quizReference = 113;
    quizItem.quizExpType =  1;
    quizItem.quizImagePath = quizImageName;
    quizItem.guid = guid;
    quizItem.quizAnswer = currentAnswer;
    quizItem.quizExpType = quizExpType;
    quizItem.quizOptCount = optionCount;
    
    // save image
    NSData *jpegImageData = UIImageJPEGRepresentation(image, 1.0);
    
    if([jpegImageData writeToFile:quizImagePath atomically:YES])
    {
        [quizItem saveLibraryItem];
    }
    
    [quizItem release];
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    if(timerControl)
    {
        [timerControl stopTimer];
        [timerControl release];
        timerControl = nil;
    }
    
    [self saveQuizItem];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    appDelegate.currentQuizWindow = nil;

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
    [self setLockImage:nil];
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

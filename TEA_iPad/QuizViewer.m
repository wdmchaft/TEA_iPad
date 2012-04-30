//
//  QuizViewer.m
//  TEA_iPad
//
//  Created by Oguz Demir on 7/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "QuizViewer.h"
#import <QuartzCore/QuartzCore.h>
#import "TEA_iPadAppDelegate.h"
#import "DeviceLog.h"

@implementation QuizViewer
@synthesize answerA;
@synthesize answerB;
@synthesize answerC;
@synthesize answerD;
@synthesize answerE;
@synthesize guid;
@synthesize answer;
@synthesize correctAnswer;
@synthesize quizImage;
@synthesize quizImageView;
@synthesize optionCount;

@synthesize activeTime, currentTime;

- (void) setupView
{
    switch (answer) 
    {
        case 0: [answerA setImage:[UIImage imageNamed:@"option_a_wrong.png"] forState:UIControlStateNormal]; break;
        case 1: [answerB setImage:[UIImage imageNamed:@"option_b_wrong.png"] forState:UIControlStateNormal]; break;
        case 2: [answerC setImage:[UIImage imageNamed:@"option_c_wrong.png"] forState:UIControlStateNormal]; break;
        case 3: [answerD setImage:[UIImage imageNamed:@"option_d_wrong.png"] forState:UIControlStateNormal]; break;
        case 4: [answerE setImage:[UIImage imageNamed:@"option_e_wrong.png"] forState:UIControlStateNormal]; break;
        default:
            [answerA setImage:[UIImage imageNamed:@"option_a_wrong.png"] forState:UIControlStateNormal]; 
            [answerB setImage:[UIImage imageNamed:@"option_b_wrong.png"] forState:UIControlStateNormal]; 
            [answerC setImage:[UIImage imageNamed:@"option_c_wrong.png"] forState:UIControlStateNormal]; 
            [answerD setImage:[UIImage imageNamed:@"option_d_wrong.png"] forState:UIControlStateNormal]; 
            [answerE setImage:[UIImage imageNamed:@"option_e_wrong.png"] forState:UIControlStateNormal]; 
            break;
    }
    
    switch (correctAnswer) 
    {
        case 0: [answerA setImage:[UIImage imageNamed:@"option_a_correct.png"] forState:UIControlStateNormal]; break;
        case 1: [answerB setImage:[UIImage imageNamed:@"option_b_correct.png"] forState:UIControlStateNormal]; break;
        case 2: [answerC setImage:[UIImage imageNamed:@"option_c_correct.png"] forState:UIControlStateNormal]; break;
        case 3: [answerD setImage:[UIImage imageNamed:@"option_d_correct.png"] forState:UIControlStateNormal]; break;
        case 4: [answerE setImage:[UIImage imageNamed:@"option_e_correct.png"] forState:UIControlStateNormal]; break;
    }
    
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

- (UIImage *) captureImage
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

- (void) closeFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self.view removeFromSuperview];

    if(contentSetFlag)
        ((TEA_iPadAppDelegate*) [[UIApplication sharedApplication]delegate]).viewController.displayingSessionContent = NO;

    [((TEA_iPadAppDelegate*) [[UIApplication sharedApplication]delegate]).viewController contentViewClosed:self];
}


- (void) closeContentViewWithDirection:(ContentViewOpenDirection)direction
{
    [self closeContentViewWithDirection:direction dontSetDisplayingContent:YES];
}


- (void) closeContentViewWithDirection:(ContentViewOpenDirection)direction dontSetDisplayingContent:(BOOL)setFlag
{
    //getting view active time
    activeTime = (long)[[NSDate date] timeIntervalSinceDate:currentTime];

    //update duration of view 
    [DeviceLog updateDurationTime:activeTime withGuid:self.guid withDate:currentTime];
    
    contentSetFlag = setFlag;

    CGRect closeRect;
    if(direction == kContentViewOpenDirectionToLeft)
    {
        closeRect = CGRectMake(-self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionToRight)
    {
        closeRect = CGRectMake(self.view.frame.size.width * 2, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionNormal)
    {
        closeRect = self.view.frame;
    }
    

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(closeFinished:finished:context:)];
    
    self.view.frame = closeRect;
    
    [UIView commitAnimations];

    
}



- (IBAction)showAnswersButtonClicked:(id)sender
{
    NSLog(@"showAnswersButtonClicked");
   
    [hideAnswerImageView setHidden:YES];
    [showAnswersButton removeFromSuperview];
    
    [UIView transitionWithView:hideAnswerImageView 
                      duration:0.4 
                       options:UIViewAnimationOptionTransitionCurlUp 
                    animations:^ { hideAnswerImageView.alpha = 0.5; } 
                    completion:^ (BOOL finish) { [hideAnswerImageView removeFromSuperview]; }];
    

}

- (void) loadContentView:(UIView *)view withDirection :(ContentViewOpenDirection)direction
{
    
    TEA_iPadAppDelegate *appDelegete = (TEA_iPadAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (appDelegete.state != kAppStateLogon)
    {
        hideAnswerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(237, 555, 541, 94)];
        [hideAnswerImageView setImage:[UIImage imageNamed:@"QuestionCover.png"]];
        [hideAnswerImageView setContentMode:UIViewContentModeScaleAspectFit];
        [view addSubview:hideAnswerImageView];
        showAnswersButton = [[UIButton alloc] initWithFrame:CGRectMake(712, 596, 50, 50)];
        [showAnswersButton setBackgroundColor:[UIColor clearColor]];
        [showAnswersButton addTarget:self action:@selector(showAnswersButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:showAnswersButton];
        
    }
    else 
    {
        CGRect initialRect;
        if(direction == kContentViewOpenDirectionToLeft)
        {
            initialRect = CGRectMake(view.frame.size.width * 2, 0, view.frame.size.width, view.frame.size.height);
        }
        else if(direction == kContentViewOpenDirectionToRight)
        {
            initialRect = CGRectMake(- view.frame.size.width * 2, 0, view.frame.size.width, view.frame.size.height);
        }
        else if(direction == kContentViewOpenDirectionNormal)
        {
            initialRect = view.frame;
        }
        view.frame = initialRect;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        view.frame = CGRectMake(0, 0, 1024, 768);
        
        [UIView commitAnimations];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {

        
        //set duration started time
        self.currentTime = [NSDate date];
        
        
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        UIView *bg = [[UIView alloc] initWithFrame:self.view.frame];
        [bg setBackgroundColor:[UIColor blackColor]];
        [bg setAlpha:0.5];
        [self.view insertSubview:bg atIndex:0];

        
    }
    return self;
}

- (void)dealloc
{
    
    [currentTime release];
    
    if (hideAnswerImageView) {
        [hideAnswerImageView release]; 
    }
    
    if (showAnswersButton) {
        [showAnswersButton release];
    }
    
    
    [answerA release];
    [answerB release];
    [answerC release];
    [answerD release];
    [answerE release];
    [quizImage release];
    [quizImageView release];
    [super dealloc];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeContentViewWithDirection:kContentViewOpenDirectionNormal];
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
    [quizImage setScalesPageToFit:YES];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.view.frame];
    [bg setBackgroundColor:[UIColor blackColor]];
    [bg setAlpha:0.5];
    [self.view insertSubview:bg atIndex:0];
    
    [bg release];
}

- (void)viewDidUnload
{
    [self setAnswerA:nil];
    [self setAnswerB:nil];
    [self setAnswerC:nil];
    [self setAnswerD:nil];
    [self setAnswerE:nil];
    [self setQuizImage:nil];
    [self setQuizImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end

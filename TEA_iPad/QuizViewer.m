//
//  QuizViewer.m
//  TEA_iPad
//
//  Created by Oguz Demir on 7/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "QuizViewer.h"
#import <QuartzCore/QuartzCore.h>

@implementation QuizViewer
@synthesize answerA;
@synthesize answerB;
@synthesize answerC;
@synthesize answerD;
@synthesize answerE;

@synthesize answer;
@synthesize correctAnswer;
@synthesize quizImage;


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
}

- (UIImage *) captureImage
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        UIView *bg = [[UIView alloc] initWithFrame:self.view.frame];
        [bg setBackgroundColor:[UIColor blackColor]];
        [bg setAlpha:0.5];
        [self.view insertSubview:bg atIndex:0];
        
        [bg release];
    }
    return self;
}

- (void)dealloc
{
    [answerA release];
    [answerB release];
    [answerC release];
    [answerD release];
    [answerE release];
    [quizImage release];
    [super dealloc];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view removeFromSuperview];
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
}

- (void)viewDidUnload
{
    [self setAnswerA:nil];
    [self setAnswerB:nil];
    [self setAnswerC:nil];
    [self setAnswerD:nil];
    [self setAnswerE:nil];
    [self setQuizImage:nil];
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

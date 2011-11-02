//
//  NumericPad.m
//  TEA_iPad
//
//  Created by Oguz Demir on 31/10/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "NumericPad.h"
#import "TEA_iPadAppDelegate.h"

@implementation NumericPad
@synthesize textField, popup;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void) loginGuestStudent
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.guestEnterNumber = [textField.text intValue];
    [appDelegate restartBonjourBrowser];
    
    [popup dismissPopoverAnimated:YES];
}

- (IBAction) buttonClicked:(UIButton*)sender
{
    int buttonTag = sender.tag;
    
    if(buttonTag >= kButton0 && buttonTag <= kButton9)
    {
        textField.text = [textField.text stringByAppendingFormat:@"%d", buttonTag];
    }
    else if(buttonTag == kButtonDelete && [textField.text length] > 0)
    {
        textField.text = [textField.text substringToIndex:[textField.text length] - 1];
    }
    else if(buttonTag == kButtonOK && [textField.text length] > 0)
    {
        [self loginGuestStudent];
    }
}

- (void)dealloc {
    [popup release];
    [textField release];
    [super dealloc];
}
@end

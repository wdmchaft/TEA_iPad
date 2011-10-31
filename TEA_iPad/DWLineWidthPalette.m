//
//  DWLineWidthPalette.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWLineWidthPalette.h"


@implementation DWLineWidthPalette
@synthesize slider;
@synthesize lineWidthView, drawingViewController, popover;;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [lineWidthView release];
    [slider release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat lineWidth = drawingViewController.drawingLayer.currentTool.drawingItem.lineWidth.lineWidth;
    lineWidthView.lineWidth = lineWidth;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setLineWidthView:nil];
    [self setSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)sliderValueChanged:(UISlider*)sender 
{
    CGFloat sliderValue = [sender value];
    lineWidthView.lineWidth = sliderValue;
    
    DWLineWidth *lineWidth = [[DWLineWidth alloc] init];
    lineWidth.lineWidth = sliderValue;
    
    drawingViewController.drawingLayer.currentTool.drawingItem.lineWidth = lineWidth;
    [lineWidth release];
}
@end

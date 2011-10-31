//
//  DWColorPalette.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWColorPalette.h"


@implementation DWColorPalette
@synthesize colorPalette, drawingViewController, popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        colorPalette = [[NSMutableArray alloc] initWithCapacity:16];
        
        
        CGFloat halftone = 132.0 / 255.0;
        
        [colorPalette addObject:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:halftone green:0 blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:0 green:halftone blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:halftone green:halftone blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:0 green:0 blue:halftone alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:halftone green:0 blue:halftone alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:0 green:halftone blue:halftone alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:halftone green:halftone blue:halftone alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:198.0/255.0 green:198.0/255.0  blue:198.0/255.0  alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:0 green:1 blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:1 green:1 blue:0 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:1 green:0 blue:1 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:0 green:1 blue:1 alpha:1]];
        [colorPalette addObject:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


- (void) chooseColorWithTag:(int) tag
{
    
    UIColor *chosenColor = (UIColor*) [colorPalette objectAtIndex:tag];
    
    DWColor *color = [[DWColor alloc] init];
    
    [color setRedColorValue:CGColorGetComponents([chosenColor CGColor])[0]];
    [color setGreenColorValue:CGColorGetComponents([chosenColor CGColor])[1]];
    [color setBlueColorValue:CGColorGetComponents([chosenColor CGColor])[2]];
    [color setAlphaColorValue:CGColorGetComponents([chosenColor CGColor])[3]];

    
    drawingViewController.drawingLayer.currentTool.drawingItem.lineColor = color;
    [color release];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (IBAction)colorClicked:(UIButton*)sender 
{
    [self chooseColorWithTag:sender.tag];
    [popover dismissPopoverAnimated:YES];
}
@end

//
//  DWLineWidthPalette.h
//  TEA_iPad
//
//  Created by Oguz Demir on 17/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWLineWithPaletteLineWidthView.h"
#import "DWDrawingViewController.h"

@interface DWLineWidthPalette : UIViewController {
    
    DWLineWithPaletteLineWidthView *lineWidthView;
    DWDrawingViewController *drawingViewController;
    UIPopoverController *popover;
    UISlider *slider;
}

@property (nonatomic, retain) IBOutlet DWLineWithPaletteLineWidthView *lineWidthView;
@property (nonatomic, assign) DWDrawingViewController *drawingViewController;
@property (nonatomic, assign) UIPopoverController *popover;
@property (nonatomic, retain) IBOutlet UISlider *slider;


- (IBAction)sliderValueChanged:(id)sender;

@end

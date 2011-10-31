//
//  DWColorPalette.h
//  TEA_iPad
//
//  Created by Oguz Demir on 17/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDrawingViewController.h"

@interface DWColorPalette : UIViewController 
{
    NSMutableArray *colorPalette;
    DWDrawingViewController *drawingViewController;
    UIPopoverController *popover;
}

@property (nonatomic, assign) NSMutableArray *colorPalette;
@property (nonatomic, assign) DWDrawingViewController *drawingViewController;
@property (nonatomic, assign) UIPopoverController *popover;

- (IBAction)colorClicked:(id)sender;

@end

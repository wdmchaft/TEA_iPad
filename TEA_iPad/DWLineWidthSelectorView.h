//
//  DWLineWidthSelectorView.h
//  TEA_iPad
//
//  Created by GURKAN CALIK on 8/7/11.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <QuartzCore/QuartzCore.h>

#import "DWDrawingView.h"


@interface DWLineWidthSelectorView : UIView {
    UISlider *lineWidthSelector;
    UIButton *lineWidthDemoArea;
    DWDrawingView *drawingArea;
}

@property (nonatomic,assign) DWDrawingView *drawingArea;

@property (nonatomic, retain) IBOutlet  UISlider *lineWidthSelector;
@property (nonatomic, retain) IBOutlet  UIButton *lineWidthDemoArea;

- (IBAction)lineWidthSelectorValueChanged:(id)sender;

- (void) setDrawingArea:(DWDrawingView*) pDrawingArea;


@end

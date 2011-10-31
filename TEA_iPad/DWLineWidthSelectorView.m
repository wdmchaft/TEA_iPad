//
//  DWLineWidthSelectorView.m
//  TEA_iPad
//
//  Created by GURKAN CALIK on 8/7/11.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWLineWidthSelectorView.h"


@implementation DWLineWidthSelectorView

@synthesize lineWidthSelector;
@synthesize lineWidthDemoArea;

@synthesize drawingArea;

- (id)initWithFrame:(CGRect)frame
{
            self = [super initWithFrame:frame];
            if (self) {
                       
                        self.layer.cornerRadius = 30;
                        self.layer.borderColor = [UIColor grayColor].CGColor;
                        self.layer.borderWidth = 3;
                        //colorPalette.layer.opacity = 0.2;
                        self.layer.shadowColor = [UIColor blackColor].CGColor;
                        self.layer.shadowOpacity = 1.0;
                        self.layer.shadowRadius = 5.0;
                        self.layer.shadowOffset = CGSizeMake(0, 3);
                        self.clipsToBounds = NO;
                        
                        lineWidthSelector =[[UISlider alloc] initWithFrame:CGRectMake(-60 , 90, 170, 30)];
                        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
                        lineWidthSelector.transform = trans;
                        [lineWidthSelector setMaximumValue:5.0];
                        [lineWidthSelector setMinimumValue:0.5];
                        [lineWidthSelector setValue:1 animated:YES];
                        
                        [lineWidthSelector addTarget:self action:@selector(lineWidthSelectorValueChanged)  forControlEvents:UIControlEventValueChanged];        
                
                        
                        lineWidthDemoArea =[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
                        [lineWidthDemoArea setFrame:CGRectMake(45, 80, 40, 40 )];
                        //[colorRed setFrame:CGRectMake(20, 20, 80, 40 )];
                        
                        [self addSubview:lineWidthSelector];
                        [self addSubview:lineWidthDemoArea];
                
                
                        
                    }
            return self;
        }

/*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    - (void)drawRect:(CGRect)rect
    {
        // Drawing code
    }
    */
/*
-(void)lineWidthSelectorValueChanged
{
    drawingArea.lineWidth = lineWidthSelector.value;
 
}
*/
-(void)setDrawingArea:(DWDrawingView*)pDrawingArea
{
    drawingArea = pDrawingArea;
}

- (void)dealloc
{
    [drawingArea release];
            [lineWidthDemoArea release];
            [lineWidthSelector release];
            [super dealloc];
        }

@end
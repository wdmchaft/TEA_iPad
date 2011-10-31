//
//  NotebookPage.h
//  TEA_iPad
//
//  Created by Oguz Demir on 18/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDrawingViewController.h"

@interface NotebookPage : NSObject 
{
    UIImage *image;
    DWDrawingViewController *drawingViewController;
    
    BOOL edited;
}

@property (nonatomic, assign) BOOL edited;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) DWDrawingViewController *drawingViewController;

- (NSString*) getXML;

@end

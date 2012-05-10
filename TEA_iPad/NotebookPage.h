//
//  NotebookPage.h
//  TEA_iPad
//
//  Created by Oguz Demir on 18/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDrawingViewController.h"

@class Notebook;
@interface NotebookPage : NSObject 
{
    Notebook *notebook;
    UIImage *image;
    //DWDrawingViewController *drawingViewController;
    NSMutableArray *pageObjects;
    
    BOOL edited;
    int notebookPage;
}

@property (nonatomic, assign) int notebookPage;

@property (nonatomic, assign) Notebook *notebook;
@property (nonatomic, assign) BOOL edited;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) NSMutableArray *pageObjects;
//@property (nonatomic, retain) DWDrawingViewController *drawingViewController;

- (NSString*) getXML;

@end

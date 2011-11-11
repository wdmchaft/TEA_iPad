//
//  Notebook.h
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDrawingViewController.h"
#import "NotebookPage.h"

enum kNotebookState {
    kStateClosed = 0,
    kStateEdited = 1,
    kStateSaved = 2,
    kStateOpened = 3
    };

@interface Notebook : UIView 
{

    //DWDrawingViewController *drawingViewController;
    
    NSString *version;
    NSString *name;
    NSString *type;
    NSString *guid;
    NSString *lectureGuid;
    NSString *creationDate;
    NSString *path;
    NSString *points;
    NSString *coverColor;
    
    int state;
    int currentPageIndex;
    int totalPageCount;
    int lastOpenedPage;
    
    NSMutableArray *pages;
    
    id pageChangeTarget;
    SEL pageChangeSelector;
}

- (void) initNotebook;
- (NSString*) getInitialXMLString;

- (void) notebookOpen:(NSString*)guid;
- (void) notebookClose;
- (void) notebookShowPage:(int) pPageIndex;
- (void) notebookAddPageAfterPage:(int) aPageIndex;
- (void) notebookAddPageAfterPage:(int) aPageIndex withImage:(UIImage*) pImage;
- (void) setPageChangeSelector:(SEL) aSelector andTarget:(id) aTarget;

@property (nonatomic, assign) int state;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSString *lectureGuid;
@property (nonatomic, retain) NSString *creationDate;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *points;
@property (nonatomic, retain) NSString *coverColor;
@property (nonatomic, retain) NSMutableArray *pages;
@property (nonatomic, assign) int currentPageIndex;
@property (nonatomic, assign) int lastOpenedPage;

- (IBAction) prevPageClicked:(id) sender;
- (IBAction) nextPageClicked:(id) sender;

@end

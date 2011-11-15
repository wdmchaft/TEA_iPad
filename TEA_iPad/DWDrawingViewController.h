//
//  DWDrawingViewController.h
//  TEA_iPad
//
//  Created by Oguz Demir on 14/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDrawingView.h"
#import "DWRectangle.h"
#import "DWOval.h"
#import "DWPen.h"
#import "DWLine.h"
#import "DWDrawingItemTyping.h"
#import "DWDrawingItemWebClip.h"
#import "DWObjectView.h"

@interface DWDrawingViewController : UIViewController {
    UIButton *toolPen;
    UIButton *toolRect;
    UIButton *toolLine;
    UIButton *toolOval;
    UIButton *colorButton;
    UIButton *LineWidthSelectorButton;
    UIButton *recordButton;
    UILabel *pageLabel;
    UIButton *toolSelect;

    
    Boolean ibSelectMode;
    UISwitch *toolSelectionChanger;
    
    NSString *audioFileName;

    DWDrawingView *drawingLayer;
    DWObjectView *objectLayer;
    
    id target;
    SEL prevPageAction;
    SEL nextPageAction;
    SEL pageEdited;
    
    int currentPage;
}


@property (nonatomic, retain) IBOutlet DWDrawingView *drawingLayer;
@property (nonatomic, retain) IBOutlet DWObjectView *objectLayer;
@property (nonatomic, retain) IBOutlet UIButton *toolPen;
@property (nonatomic, retain) IBOutlet UIButton *toolRect;
@property (nonatomic, retain) IBOutlet UIButton *toolLine;
@property (nonatomic, retain) IBOutlet UIButton *toolOval;
@property (nonatomic, retain) IBOutlet UIButton *colorButton;
@property (nonatomic, retain) IBOutlet UIButton *LineWidthSelectorButton;
@property (nonatomic, retain) IBOutlet UIButton *toolSelect;
@property (nonatomic, retain) IBOutlet UISwitch *toolSelectionChanger;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel;

@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) SEL pageEdited;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL prevPageAction;
@property (nonatomic, assign) SEL nextPageAction;
@property (retain, nonatomic) IBOutlet UISwitch *editModeSwitch;

- (IBAction)editModeOnOffChanged:(id)sender;

- (IBAction)toolPenClicked:(id)sender;
- (IBAction)toolRectClicked:(id)sender;
- (IBAction)toolLineClicked:(id)sender;
- (IBAction)toolOvalClicked:(id)sender;
- (IBAction)toolTypeClicked:(id)sender;
- (IBAction)toolEraserClicked:(id)sender;
- (IBAction)recordAudioButtonClicked:(id)sender;
- (IBAction)colorButtonClicked:(id)sender;
- (IBAction)lineWidthSelectorButtonClicked:(id)sender;
- (IBAction)clearAll:(id)sender;
- (IBAction)toolSelect:(id)sender;
- (IBAction)toolSelectionChangerChanged:(id)sender;
- (IBAction)toolWebClipClicked:(id)sender;
- (IBAction)toolPrevPageClicked:(id)sender;
- (IBAction)toolNextPageClicked:(id)sender;
- (IBAction)toolLibraryClipClicked:(id)sender;

- (void) showingPage:(NSDictionary *) aUserInfo;

@end

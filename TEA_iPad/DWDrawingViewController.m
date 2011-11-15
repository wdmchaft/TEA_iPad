//
//  DWDrawingViewController.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//
#import "TEA_iPadAppDelegate.h"
#import "DWDrawingViewController.h"
#import "BonjourService.h"
#import "LibraryView.h"
#import "DWViewItemText.h"
#import "LocalDatabase.h"
#import "DWColorPalette.h"
#import "DWLineWidthPalette.h"
#import "DWViewItemWebClip.h"
#import "DWViewItemSound.h"
#import "DWViewItemLlibraryItemClip.h"
#import "Notebook.h"

@implementation DWDrawingViewController
@synthesize drawingLayer;
@synthesize objectLayer;

@synthesize toolPen, currentPage, pageEdited;
@synthesize toolSelect;
//@synthesize colorBlack;
@synthesize toolRect;
@synthesize toolLine;
@synthesize toolOval;
@synthesize colorButton;
@synthesize LineWidthSelectorButton;

@synthesize target;
@synthesize prevPageAction;
@synthesize nextPageAction;
@synthesize editModeSwitch;

@synthesize toolSelectionChanger;
@synthesize recordButton;
@synthesize pageLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}



#pragma mark - View lifecycle

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[pageLabel setText:[NSString stringWithFormat:@"s %d", currentPage]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    audioFileName = [[[LocalDatabase stringWithUUID] stringByAppendingString:@".caf"] retain];
    drawingLayer.drawingViewController = self;
    objectLayer.drawingViewController = self;
}

- (void)viewDidUnload
{
    [self setToolRect:nil];
    [toolSelect release];
    toolSelect = nil;
    [self setToolSelect:nil];
    [toolLine release];
    toolLine = nil;
    [self setToolLine:nil];
    [self setToolOval:nil];
    [self setToolPen:nil];
    [self setColorButton:nil];
    [self setLineWidthSelectorButton:nil];
    [self setToolSelectionChanger:nil];
    [self setRecordButton:nil];
    [self setObjectLayer:nil];
    [self setPageLabel:nil];
    [self setEditModeSwitch:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [audioFileName release];
    [toolRect release];
    [toolSelect release];
    [toolLine release];
    [toolLine release];
    [toolOval release];
    [toolPen release];


    [colorButton release];
    [LineWidthSelectorButton release];
    [toolSelectionChanger release];
    [recordButton release];
    if(drawingLayer)
    {
        [drawingLayer release];
    }
    [objectLayer release];
    [pageLabel release];
    
    [editModeSwitch release];
    [super dealloc];
}



- (NSString*) getAudioFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], audioFileName];
    
    return audioFilePath;
}

- (BOOL) isAudioFileAvailable
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], audioFileName];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
}





- (IBAction)lineWidthSelectorButtonClicked:(id)sender 
{
    
     
    DWLineWidthPalette *lineWidthPalette = [[DWLineWidthPalette alloc] initWithNibName:@"DWLineWidthPalette" bundle:nil];
    lineWidthPalette.drawingViewController = self;
  
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:lineWidthPalette];
    lineWidthPalette.popover = popover;
    popover.popoverContentSize = lineWidthPalette.view.frame.size;
    [popover presentPopoverFromRect:LineWidthSelectorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}

- (IBAction)widthSelectorValueChanged:(id)sender 
{

}


- (IBAction)clearAll:(id)sender 
{

}

- (IBAction)sendToBlackBoardClicked:(id)sender {
    UIImage *image = [drawingLayer screenImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"length of jpg %d", [imageData length]);
    
    if(imageData != nil)
    {
        TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
        
        BonjourMessage *imageMessage = [[[BonjourMessage alloc] init] autorelease];
        imageMessage.messageType = kMessageTypeQuizImage;
        
        NSMutableDictionary *userData = [[[NSMutableDictionary alloc] init] autorelease];
        [userData setValue:[LocalDatabase stringWithUUID] forKey:@"guid"];
        [userData setValue:@"Görsel" forKey:@"name"];
        [userData setValue:imageData forKey:@"image"];
        [userData setValue:@"png" forKey:@"extension"];
        imageMessage.userData = userData;
        
        [appDelegate.bonjourBrowser sendBonjourMessageToAllClients:imageMessage];
        
    }
}


#pragma mark - Tool Events

- (IBAction)editModeOnOffChanged:(id)sender 
{
    UISwitch *switchControl = (UISwitch*) sender;
    
    if(switchControl.on)
    {
        [self.view  bringSubviewToFront:objectLayer];
        [objectLayer setAllSelected:YES];
    }
    else
    {
        [self.view  bringSubviewToFront:drawingLayer];
        [objectLayer setAllSelected:NO];
    }
}

- (IBAction)toolPenClicked:(id)sender {
    drawingLayer.currentTool = drawingLayer.penTool;
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}

- (IBAction)toolRectClicked:(id)sender
{
    drawingLayer.currentTool = drawingLayer.rectangleTool;
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}




- (IBAction)toolEraserClicked:(id)sender 
{
    drawingLayer.currentTool = drawingLayer.eraserTool;
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}

- (IBAction)toolLineClicked:(id)sender 
{
    drawingLayer.currentTool = drawingLayer.lineTool;
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}


- (IBAction)toolOvalClicked:(id)sender {
    drawingLayer.currentTool = drawingLayer.ovalTool;
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}


- (IBAction)colorButtonClicked:(id)sender 
{
    
    DWColorPalette *colorPalette = [[DWColorPalette alloc] initWithNibName:@"DWColorPalette" bundle:nil];
    colorPalette.drawingViewController = self;
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:colorPalette];
    colorPalette.popover = popover;
    popover.popoverContentSize = colorPalette.view.frame.size;
    [popover presentPopoverFromRect:colorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}

- (IBAction)toolSelect:(id)sender {

}

- (IBAction)toolSelectionChangerChanged:(id)sender 
{

}

- (IBAction)toolPrevPageClicked:(id)sender
{
    [target performSelector:prevPageAction];
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}

- (IBAction)toolNextPageClicked:(id)sender
{
    [target performSelector:nextPageAction];
    [editModeSwitch setOn:NO];
    [self editModeOnOffChanged:editModeSwitch];
}

- (IBAction)toolLibraryClipClicked:(id)sender 
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.viewController.notebook.state == kStateOpened)
    {
        DWViewItemLlibraryItemClip *viewItemWebClip = [[DWViewItemLlibraryItemClip alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        
        int pageIndex = appDelegate.viewController.notebook.currentPageIndex - 1;
        NotebookPage *page = (NotebookPage*) [appDelegate.viewController.notebook.pages objectAtIndex:pageIndex];
        [page.pageObjects addObject:viewItemWebClip];
        [appDelegate.viewController.notebook notebookAddViewItem:[page.pageObjects count] - 1];
        
        viewItemWebClip.container = self.objectLayer;
        [viewItemWebClip release];
        
        [editModeSwitch setOn:YES];
        [self editModeOnOffChanged:editModeSwitch];
    }
}

- (IBAction)toolWebClipClicked:(id)sender 
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.viewController.notebook.state == kStateOpened)
    {
        DWViewItemWebClip *viewItemWebClip = [[DWViewItemWebClip alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        int pageIndex = appDelegate.viewController.notebook.currentPageIndex - 1;
        NotebookPage *page = (NotebookPage*) [appDelegate.viewController.notebook.pages objectAtIndex:pageIndex];
        [page.pageObjects addObject:viewItemWebClip];
        [appDelegate.viewController.notebook notebookAddViewItem:[page.pageObjects count] - 1];
        [viewItemWebClip release];
        
        [editModeSwitch setOn:YES];
        [self editModeOnOffChanged:editModeSwitch];
    }
    
    
}

- (IBAction)toolTypeClicked:(id)sender
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.viewController.notebook.state == kStateOpened)
    {
        DWViewItemText *viewItemText = [[DWViewItemText alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        int pageIndex = appDelegate.viewController.notebook.currentPageIndex - 1;
        NotebookPage *page = (NotebookPage*) [appDelegate.viewController.notebook.pages objectAtIndex:pageIndex];
        [page.pageObjects addObject:viewItemText];
        [appDelegate.viewController.notebook notebookAddViewItem:[page.pageObjects count] - 1];
        [viewItemText release];
        
        [editModeSwitch setOn:YES];
        [self editModeOnOffChanged:editModeSwitch];
    }
    
    
}

- (IBAction)recordAudioButtonClicked:(id)sender
{
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.state == kAppStateIdle && appDelegate.viewController.notebook.state == kStateOpened)
    {
        DWViewItemSound *viewItemSound = [[DWViewItemSound alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        int pageIndex = appDelegate.viewController.notebook.currentPageIndex - 1;
        NotebookPage *page = (NotebookPage*) [appDelegate.viewController.notebook.pages objectAtIndex:pageIndex];
        [page.pageObjects addObject:viewItemSound];
        [appDelegate.viewController.notebook notebookAddViewItem:[page.pageObjects count] - 1];
        
        
        [viewItemSound release];
        
        [editModeSwitch setOn:YES];
        [self editModeOnOffChanged:editModeSwitch];
    }
    
   
}

- (void) showingPage:(NSDictionary *) aUserInfo;
{
/*    //[aUserInfo retain];
    //int pageNumber = [[aUserInfo valueForKey:@"pageNumber"] intValue];
  //  int totalPageCount = [[aUserInfo objectForKey:@"totalPageCount"] intValue];
  //  NSLog(@"total page count %d", totalPageCount);
  //  NSString *pageString = [NSString stringWithFormat:@"%d / %d", pageNumber, totalPageCount];
    NSString *value = [[aUserInfo objectForKey:@"totalPageCount"] retain];
    pageLabel.text = value;
   //pageLabel.text = [aUserInfo objectForKey:@"totalPageCount"];
    NSLog(@"data is %@", value);
    //[aUserInfo release];*/
}

@end

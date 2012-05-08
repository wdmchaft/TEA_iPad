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
@synthesize colorPopover, lineWidthPopover;

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
@synthesize notebookName;

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
    [self setNotebookName:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc {
    [colorPopover release];
    [lineWidthPopover release];
    
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
    [notebookName release];
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
    
     
    DWLineWidthPalette *lineWidthPalette = [[[DWLineWidthPalette alloc] initWithNibName:@"DWLineWidthPalette" bundle:nil] autorelease];
    lineWidthPalette.drawingViewController = self;
  
    self.lineWidthPopover = [[[UIPopoverController alloc] initWithContentViewController:lineWidthPalette] autorelease];
    lineWidthPalette.popover = self.lineWidthPopover;
    self.lineWidthPopover.popoverContentSize = lineWidthPalette.view.frame.size;
    [self.lineWidthPopover presentPopoverFromRect:LineWidthSelectorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}

- (IBAction)widthSelectorValueChanged:(id)sender 
{

}


- (IBAction)clearAll:(id)sender 
{

}

- (IBAction)sendToBlackBoardClicked:(id)sender {
    UIImage *image1 = [drawingLayer screenImage];
    UIImage *image2 = [objectLayer screenImage];
    
    
    // merge two images into one image
    // capture image context ref
    UIGraphicsBeginImageContext(image2.size);
    
    //Draw images onto the context
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height) blendMode:kCGBlendModeMultiply alpha:1.0]; 
    
    // assign context to new UIImage
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    
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
    
    DWColorPalette *colorPalette = [[[DWColorPalette alloc] initWithNibName:@"DWColorPalette" bundle:nil] autorelease];
    colorPalette.drawingViewController = self;
    self.colorPopover = [[[UIPopoverController alloc] initWithContentViewController:colorPalette] autorelease];
    colorPalette.popover = self.colorPopover;
    self.colorPopover.popoverContentSize = colorPalette.view.frame.size;
    [self.colorPopover presentPopoverFromRect:colorButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
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
        
        if (!viewItemWebClip.htmlString) {
            [viewItemWebClip release];
            return;
        }
        
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

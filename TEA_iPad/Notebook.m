//
//  Notebook.m
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "Notebook.h"
#import "LocalDatabase.h"
#import "DWViewItem.h"

@implementation Notebook


@synthesize version;
@synthesize name;
@synthesize type;
@synthesize guid;
@synthesize lectureGuid;
@synthesize creationDate;
@synthesize path;
@synthesize points;
@synthesize coverColor;
@synthesize state;
@synthesize pages;
@synthesize currentPageIndex;
@synthesize lastOpenedPage;
@synthesize drawingViewController;

-(void) initNotebook
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    self.version = @"1.0";;
    self.creationDate = dateString;
    self.points = @"";
    self.coverColor = @"";
    self.path = @"";
    
    [dateFormatter release];
    
    
        
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.drawingViewController = [[[DWDrawingViewController alloc] initWithNibName:@"DWDrawingViewController" bundle:nil] autorelease];
        [self.drawingViewController.view setFrame:[self bounds]];
        [self.drawingViewController.view  setHidden:NO];
        [self.drawingViewController.view  setBackgroundColor:[UIColor clearColor]];
        
        self.drawingViewController.target = self;
        self.drawingViewController.prevPageAction = @selector(prevPageClicked:);
        self.drawingViewController.nextPageAction = @selector(nextPageClicked:);
        self.drawingViewController.pageEdited = @selector(pageEdited:);
        self.drawingViewController.drawingLayer.contextImage = nil;
        
        [self setPageChangeSelector:@selector(showingPage:) andTarget:drawingViewController];
        
        self.drawingViewController.pageLabel.text = @"";
        self.drawingViewController.pageLabel.text = [NSString stringWithFormat:@"%d / %d", currentPageIndex, [pages count]];   
        
        [self addSubview:self.drawingViewController.view];

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

- (NSString*) getInitialXMLString
{
    NSString *initalXMLFilePath = [[NSBundle mainBundle] pathForResource:@"notebook" ofType:@"xml"];
    NSString *initialXMLString = [NSString stringWithContentsOfFile:initalXMLFilePath encoding:NSUTF8StringEncoding error:nil];
    
    initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%guid%" withString:self.guid];
    initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%version%" withString:@"1.0"];
    initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%name%" withString:self.name];
    initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%type%" withString:self.type];
    initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%lectureGuid%" withString:self.lectureGuid];
    initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%lastOpenedPage%" withString:[NSString stringWithFormat:@"%d", currentPageIndex]];
    
    //initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"%creationDate%" withString:self.creationDate];

    int counter = 0;
    if(pages && [pages count] > 0)
    {
        NotebookPage *currentPage = [pages objectAtIndex:currentPageIndex - 1];
        if(currentPage.edited)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *pagePath = [NSString stringWithFormat:@"%@/page%d_%@.png",  [paths objectAtIndex:0], currentPageIndex - 1, self.guid];
            
            NSData *imageData = UIImagePNGRepresentation(drawingViewController.drawingLayer.contextImage);
            [imageData writeToFile:pagePath atomically:YES];
            currentPage.edited = NO;
        }
        
        for(NotebookPage *page in pages)
        {

            counter ++;
            
            NSString *pageXML = [page getXML];
            pageXML = [NSString stringWithFormat:pageXML, [NSString stringWithFormat:@"/page%d_%@.png", counter, self.guid]];
            pageXML = [pageXML stringByAppendingString:@"\n<!--pages-->"];
            initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"<!--pages-->" withString:pageXML];
        }
        
    }
    
    
    return initialXMLString;
}

- (void) notebookClose
{
    
    // save notebook
    
    
    NSString *notebookXML = [self getInitialXMLString];
    NSData *data = [notebookXML dataUsingEncoding:NSUTF8StringEncoding];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/notebook_%@.xml",  [paths objectAtIndex:0], self.guid];
    [data writeToFile:[NSString stringWithFormat:filePath, self.guid] atomically:YES];
    
    [self notebookCleanViewItems];
    
    [pages release];
    pages = nil;

    
    for(UIView *view in [self subviews])
    {
        //[view removeFromSuperview];
    }
    
    state = kStateClosed;
    currentPageIndex = 0;
}

- (void) notebookOpen:(NSString*)guid
{
    
    // load notebook
    if(!pages)
    {
        pages = [[NSMutableArray alloc] init];
    }
    
    if([self.pages count] <=0)
    {
        [self notebookAddPageAfterPage:0];
    }
    if(lastOpenedPage == 0)
        lastOpenedPage = 1;
    
    
    
    
    [self notebookShowPage:lastOpenedPage];

    state = kStateOpened;
}

- (void)dealloc
{
    if(pages)
    {
        [pages release];
    }
    
    [drawingViewController release];
    [version release];
    [name release];
    [type release];
    [guid release];
    [lectureGuid release];
    [creationDate release];
    [path release];
    [points release];
    [coverColor release];
    
    [super dealloc];
}

- (IBAction) prevPageClicked:(id) sender
{
    if(currentPageIndex > 1)
    {
        [self notebookCleanViewItems];
        [self notebookShowPage:currentPageIndex - 1];
    }
}

- (IBAction) pageEdited:(id) sender
{
    NotebookPage *currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    currentPage.edited = YES;
}

- (IBAction) nextPageClicked:(id) sender
{
    [self notebookCleanViewItems];
    
    if(currentPageIndex < [pages count])
    {
        [self notebookShowPage:currentPageIndex + 1];
    }
    else
    {
        [self notebookAddPageAfterPage:0];
    }
}

- (void) notebookShowPage:(int) pPageIndex 
{
    NSLog(@"hoooop");
    NotebookPage *currentPage = nil;
    if( currentPageIndex > 0 )
    {
        currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
        
        if(currentPage.edited)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *pagePath = [NSString stringWithFormat:@"%@/page%d_%@.png",  [paths objectAtIndex:0], currentPageIndex - 1, self.guid];
            
            NSData *imageData = UIImagePNGRepresentation(drawingViewController.drawingLayer.contextImage);
            [imageData writeToFile:pagePath atomically:YES];
            currentPage.edited = NO;
            currentPage.image = [UIImage imageWithData:imageData];
        }

    }
    
    NSLog(@"removing page %d", currentPageIndex);
    currentPageIndex = pPageIndex;
    
    NSLog(@"current page index %d", currentPageIndex);
    
    currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    
    drawingViewController.drawingLayer.contextImage = currentPage.image;
    drawingViewController.pageLabel.text = [NSString stringWithFormat:@"%d / %d", currentPageIndex, [pages count]];    
    [drawingViewController.drawingLayer setNeedsDisplay];
    
    int counter = 0;
    for(DWViewItem *viewItem in currentPage.pageObjects)
    {
        [self notebookAddViewItem:counter];
        counter++;
    }
        
}

- (void) notebookAddViewItem:(int) viewItemIndex
{
    NotebookPage *currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    DWViewItem *viewItem = (DWViewItem*) [currentPage.pageObjects objectAtIndex:viewItemIndex];
    [drawingViewController.objectLayer addViewItem:viewItem];
}


- (void) notebookRemoveViewItem:(DWViewItem*) viewItem
{
    NotebookPage *currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    [viewItem removeFromSuperview];
    [currentPage.pageObjects removeObject:viewItem];
    
}



- (void) notebookCleanViewItems
{
    NotebookPage *currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    for(UIView *view in currentPage.pageObjects)
    {
        [view removeFromSuperview];
    }
}

- (void) notebookAddPageAfterPage:(int) aPageIndex withImage:(UIImage*) pImage
{
    NotebookPage *page = [[[NotebookPage alloc] init] autorelease];
    page.image = pImage;
    
    [pages addObject:page];

}

- (void) notebookAddPageAfterPage:(int) aPageIndex
{
    NotebookPage *page = [[[NotebookPage alloc] init] autorelease];
    

    page.image = nil;
    [pages addObject:page];
    totalPageCount++;
    [self notebookShowPage:[pages count]];
}

- (void) setPageChangeSelector:(SEL) aSelector andTarget:(id) aTarget
{
    pageChangeTarget = aTarget;
    pageChangeSelector = aSelector;
}

@end

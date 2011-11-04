//
//  Notebook.m
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "Notebook.h"
#import "LocalDatabase.h"

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
    if (self) {
        // Initialization code
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
    for(NotebookPage *page in pages)
    {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pagePath = [NSString stringWithFormat:@"%@/page%d_%@.png",  [paths objectAtIndex:0], counter, self.guid];
        
        NSData *imageData = UIImagePNGRepresentation(page.drawingViewController.drawingLayer.contextImage);
        [imageData writeToFile:pagePath atomically:YES];
        counter ++;
        
        NSString *pageXML = [page getXML];
        pageXML = [NSString stringWithFormat:pageXML, [NSString stringWithFormat:@"/page%d_%@.png", counter, self.guid]];
        pageXML = [pageXML stringByAppendingString:@"\n<!--pages-->"];
        initialXMLString = [initialXMLString stringByReplacingOccurrencesOfString:@"<!--pages-->" withString:pageXML];
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
    
    NotebookPage *currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    currentPage.drawingViewController.view = nil;
    
    [pages release];
    pages = nil;
    
    for(UIView *view in [self subviews])
    {
        [view removeFromSuperview];
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
        [self notebookShowPage:currentPageIndex - 1];
    }
}

- (IBAction) nextPageClicked:(id) sender
{
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
            // save page;
        }
        
        [currentPage.drawingViewController.view removeFromSuperview];
    }
    
    NSLog(@"removing page %d", currentPageIndex);
    currentPageIndex = pPageIndex;
    
    NSLog(@"current page index %d", currentPageIndex);
    
    currentPage = (NotebookPage*) [pages objectAtIndex:currentPageIndex - 1];
    
    
    currentPage.drawingViewController.pageLabel.text = @"";
    currentPage.drawingViewController.pageLabel.text = [NSString stringWithFormat:@"%d / %d", currentPageIndex, [pages count]];    
    [self addSubview:currentPage.drawingViewController.view];
    
    
   /* NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    NSString *string = [NSString stringWithFormat:@"s %d", currentPageIndex];
    [userData setValue:string forKey:@"totalPageCount"];
  
    [pageChangeTarget performSelectorOnMainThread:pageChangeSelector withObject:userData waitUntilDone:YES];
    [userData release];*/
    
}

- (void) notebookAddPageAfterPage:(int) aPageIndex withImage:(UIImage*) pImage
{
    NotebookPage *page = [[[NotebookPage alloc] init] autorelease];
    
    DWDrawingViewController *drawingViewController = [[[DWDrawingViewController alloc] initWithNibName:@"DWDrawingViewController" bundle:nil] autorelease];
    [drawingViewController.view setFrame:[self bounds]];
    [drawingViewController.view  setHidden:NO];
    [drawingViewController.view  setBackgroundColor:[UIColor clearColor]];
    
    drawingViewController.target = self;
    drawingViewController.prevPageAction = @selector(prevPageClicked:);
    drawingViewController.nextPageAction = @selector(nextPageClicked:);
    drawingViewController.drawingLayer.contextImage = [pImage retain];
    page.drawingViewController = drawingViewController;
   // [self setPageChangeSelector:@selector(showingPage:) andTarget:drawingViewController];
    
    [pages addObject:page];

    [self notebookShowPage:[pages count]];
}

- (void) notebookAddPageAfterPage:(int) aPageIndex
{
    NotebookPage *page = [[[NotebookPage alloc] init] autorelease];
    
    DWDrawingViewController *drawingViewController = [[[DWDrawingViewController alloc] initWithNibName:@"DWDrawingViewController" bundle:nil] autorelease];
    [drawingViewController.view setFrame:[self bounds]];
    [drawingViewController.view  setHidden:NO];
    [drawingViewController.view  setBackgroundColor:[UIColor clearColor]];
    
    drawingViewController.target = self;
    drawingViewController.prevPageAction = @selector(prevPageClicked:);
    drawingViewController.nextPageAction = @selector(nextPageClicked:);
    //drawingViewController.drawingLayer.contextImage = page.image;
    page.drawingViewController = drawingViewController;

    
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

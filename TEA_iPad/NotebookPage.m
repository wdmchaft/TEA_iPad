//
//  NotebookPage.m
//  TEA_iPad
//
//  Created by Oguz Demir on 18/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookPage.h"
#import "Notebook.h"
#import "DWViewItemLlibraryItemClip.h"
#import "LocalDatabase.h"

@implementation NotebookPage
@synthesize image, edited, notebook, pageObjects; //drawingViewController
@synthesize notebookPage;


- (id)init {
    self = [super init];
    if (self) {
        pageObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {

    [pageObjects release];
    [image release];
    [super dealloc];
}

- (void) savePageObjectsToDatabase:(NSString*)pageXML withCurrentPage:(int)pageIndex
{

    NSString *srcPosition = [[pageXML componentsSeparatedByString:@"src=\""] objectAtIndex:1];
    
    // get src value
    NSArray *srcPositionArray = [srcPosition componentsSeparatedByString:@"\""];
    NSString *srcValue = [srcPositionArray objectAtIndex:0];
    
    
    // find filename in src value
    NSArray *stringComponents = [srcValue componentsSeparatedByString:@"/"];
    NSString *fileName = [[[stringComponents objectAtIndex:[stringComponents count]-1 ] componentsSeparatedByString:@"."] objectAtIndex:0];
    
    
    //insert library item object to notebook_library table
    NSString *insertSQL = [NSString stringWithFormat:@"insert into notebook_library ('notebook_guid', 'library_item_guid', 'notebook_page_number') values ('%@','%@','%d')", notebook.guid, fileName, pageIndex];
    [[LocalDatabase sharedInstance] executeQuery:insertSQL];
 
}

- (NSString*) getXML
{
    NSString *xml = @"<page image=\"%@\">";
   
    for(DWViewItem *item in pageObjects)
    {
        xml = [xml stringByAppendingString:[item getXML]];
        
        if ([item isKindOfClass:[DWViewItemLlibraryItemClip class]]) {
            [self savePageObjectsToDatabase:[(DWViewItemLlibraryItemClip*)item htmlString] withCurrentPage:self.notebookPage];
        }
         
    }
    
    xml = [xml stringByAppendingString:@"</page>"];
    
    return xml;
}

@end

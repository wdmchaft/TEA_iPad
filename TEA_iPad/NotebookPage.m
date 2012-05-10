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

- (NSString*) getXML
{
    NSString *xml = @"<page image=\"%@\">";
   
    for(DWViewItem *item in pageObjects)
    {
        xml = [xml stringByAppendingString:[item getXML]];
        
        if ([item isKindOfClass:[DWViewItemLlibraryItemClip class]]) {
            
            NSString *insertSQL = [NSString stringWithFormat:@"insert into notebook_library ('notebook_guid', 'library_item_guid', 'notebook_page_number') values ('%@','%@','%d')", notebook.guid, item.guid, self.notebookPage];
            
            [[LocalDatabase sharedInstance] executeQuery:insertSQL];
        }
         
    }
    
    xml = [xml stringByAppendingString:@"</page>"];
    
    return xml;
}

@end

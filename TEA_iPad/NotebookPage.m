//
//  NotebookPage.m
//  TEA_iPad
//
//  Created by Oguz Demir on 18/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookPage.h"
#import "Notebook.h"

@implementation NotebookPage
@synthesize image, edited, notebook, pageObjects; //drawingViewController

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
    }
    
    xml = [xml stringByAppendingString:@"</page>"];
    
    return xml;
}

@end

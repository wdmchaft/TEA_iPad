//
//  NotebookPage.m
//  TEA_iPad
//
//  Created by Oguz Demir on 18/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookPage.h"


@implementation NotebookPage
@synthesize image, drawingViewController, edited;


- (void)dealloc {
    if(drawingViewController)
    {
        //[drawingViewController release];
    }
    //
    [image release];
    [super dealloc];
}

- (NSString*) getXML
{
    NSString *xml = @"<page image=\"%@\">";
    
    DWObjectView *objectLayer = drawingViewController.objectLayer;
    
    for(DWViewItem *item in objectLayer.viewItems)
    {
        xml = [xml stringByAppendingString:[item getXML]];
    }
    
    xml = [xml stringByAppendingString:@"</page>"];
    
    return xml;
}

@end

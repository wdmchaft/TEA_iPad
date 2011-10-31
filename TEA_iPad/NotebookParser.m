//
//  NotebookParser.m
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookParser.h"
#import "NotebookPage.h"
#import "DWViewItemText.h"
#import "DWDrawingViewController.h"
#import "DWViewItemSound.h"
#import "DWViewItemWebClip.h"
#import "DWViewItemLlibraryItemClip.h"

@implementation NotebookParser
@synthesize notebook;

- (Notebook*) getNotebookWithXMLString:(NSString*) pXml
{
    NSData *xmlData = [pXml dataUsingEncoding:NSUTF8StringEncoding];
    pageCount = 0;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
    
	return [notebook autorelease];
}

- (void) getNotebookWithXMLData:(NSData*) pXmlData
{
    NSData *xmlData = pXmlData;
    pageCount = 0;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
    
    self.notebook.currentPageIndex = 0;
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentElement isEqualToString:@"textviewitem"])
    {
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        int lastIndex = [page.drawingViewController.objectLayer.viewItems count] - 1;
        DWViewItemText *viewItemText = (DWViewItemText*) [page.drawingViewController.objectLayer.viewItems objectAtIndex:lastIndex];
        
        UITextView *textView = (UITextView*) viewItemText.viewObject;
        textView.text = [textView.text stringByAppendingString: string];
        [viewItemText resized];
    }
}

- (void) parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    if ([currentElement isEqualToString:@"webclipitem"])
    {
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        int lastIndex = [page.drawingViewController.objectLayer.viewItems count] - 1;
        DWViewItemWebClip *viewItemWebClip = (DWViewItemWebClip*) [page.drawingViewController.objectLayer.viewItems objectAtIndex:lastIndex];
        
        NSString *htmlString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        viewItemWebClip.htmlString = htmlString;
        [htmlString release];
        [viewItemWebClip resized];
    }
    if ([currentElement isEqualToString:@"libraryitem"])
    {
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        int lastIndex = [page.drawingViewController.objectLayer.viewItems count] - 1;
        DWViewItemLlibraryItemClip *viewItemLibraryClip = (DWViewItemLlibraryItemClip*) [page.drawingViewController.objectLayer.viewItems objectAtIndex:lastIndex];
        
        NSString *htmlString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
        viewItemLibraryClip.htmlString = htmlString;
        [htmlString release];
        [viewItemLibraryClip resized];
    }
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    
    currentElement = elementName;
	
	if([elementName isEqualToString:@"notebook"])
	{
        notebook.pages = [[[NSMutableArray alloc] init] autorelease];
        notebook.name = [attributeDict valueForKey:@"name"];
        notebook.guid = [attributeDict valueForKey:@"guid"];
        notebook.version = [attributeDict valueForKey:@"version"];
        notebook.type = [attributeDict valueForKey:@"type"];
        notebook.lectureGuid = [attributeDict valueForKey:@"lectureGuid"];
        
    }
    else if([elementName isEqualToString:@"page"])
	{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pagePath = [NSString stringWithFormat:@"%@/page%d_%@.png",[paths objectAtIndex:0] ,pageCount, notebook.guid];
        UIImage *image = [UIImage imageWithContentsOfFile:pagePath];
        [notebook notebookAddPageAfterPage:0 withImage:image];
        pageCount++;
    }
    else if([elementName isEqualToString:@"textviewitem"])
    {
        DWViewItemText *textItem = [[DWViewItemText alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        UITextView *textView = (UITextView*) textItem.viewObject;
        textView.text = @"";
        
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        [page.drawingViewController.objectLayer addViewItem:textItem];
        textItem.selected = NO;
        [textItem release];
        
        textItem.frame = [textItem getPositionByString:[attributeDict valueForKey:@"position"]];
    }
    else if([elementName isEqualToString:@"sounditem"])
    {
        DWViewItemSound *soundItem = [[DWViewItemSound alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        soundItem.soundItemName.text = @"";
        
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        [page.drawingViewController.objectLayer addViewItem:soundItem];
        soundItem.selected = NO;
        [soundItem release];
        
        soundItem.frame = [soundItem getPositionByString:[attributeDict valueForKey:@"position"]];
        soundItem.audioFilePath = [attributeDict valueForKey:@"path"];
        soundItem.state = kPlayerStateIdle;
        [soundItem setupActionButton];
        [soundItem resized];
    }
    else if([elementName isEqualToString:@"webclipitem"])
    {
        DWViewItemWebClip *webClipItem = [[DWViewItemWebClip alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        [page.drawingViewController.objectLayer addViewItem:webClipItem];
        webClipItem.selected = NO;
        [webClipItem release];
        
        webClipItem.frame = [webClipItem getPositionByString:[attributeDict valueForKey:@"position"]];

    }
    else if([elementName isEqualToString:@"libraryitem"])
    {
        DWViewItemLlibraryItemClip *libraryItemClip = [[DWViewItemLlibraryItemClip alloc] initWithFrame:CGRectMake(150, 15, 200, 200)];
        
        NotebookPage *page = (NotebookPage *) [notebook.pages objectAtIndex:notebook.currentPageIndex -1];
        [page.drawingViewController.objectLayer addViewItem:libraryItemClip];
        libraryItemClip.selected = NO;
        [libraryItemClip release];
        
        libraryItemClip.frame = [libraryItemClip getPositionByString:[attributeDict valueForKey:@"position"]];
        
    }
            
            
            
	
}

// "<sounditem path=\"%@\" position=\"%@\"></sounditem>"
// @"<webclipitem position=\"%@\"><![CDATA[%@]]></webclipitem>"

@end

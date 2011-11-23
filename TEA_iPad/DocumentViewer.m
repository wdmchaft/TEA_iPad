//
//  DocumentViewer.m
//  TEA_iPad
//
//  Created by Oguz Demir on 21/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DocumentViewer.h"
#import "LibraryDocumentItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation DocumentViewer
@synthesize webView;
@synthesize libraryItem;

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}

-(id) initWithLibraryItem:(LibraryDocumentItem*) libraryDocumentItem
{
    self = [super initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.libraryItem = libraryDocumentItem;
    
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UIView *bg = [[UIView alloc] initWithFrame:self.frame];
        [bg setBackgroundColor:[UIColor blackColor]];
        [bg setAlpha:0.5];
        [self addSubview:bg];
        [bg release];
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(75, 79, 880, 580)];

        
        [self addSubview: webView];
        
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:libraryItem.path]]];
        [webView setScalesPageToFit:YES];
    }
    
    return self;
}



- (void)dealloc
{
    [libraryItem release];
    [webView release];
    [super dealloc];
}

@end

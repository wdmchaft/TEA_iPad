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
#import "TEA_iPadAppDelegate.h"

@implementation DocumentViewer
@synthesize webView;
@synthesize libraryItem;



- (void) closeFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self removeFromSuperview];
    if(contentSetFlag)
        ((TEA_iPadAppDelegate*) [[UIApplication sharedApplication]delegate]).viewController.displayingSessionContent = NO;

    [((TEA_iPadAppDelegate*) [[UIApplication sharedApplication]delegate]).viewController contentViewClosed:self];
}

- (void) closeContentViewWithDirection:(ContentViewOpenDirection)direction
{
    [self closeContentViewWithDirection:direction dontSetDisplayingContent:YES];
}


- (void) closeContentViewWithDirection:(ContentViewOpenDirection)direction dontSetDisplayingContent:(BOOL)setFlag
{
    contentSetFlag = setFlag;
    CGRect closeRect;
    if(direction == kContentViewOpenDirectionToLeft)
    {
        closeRect = CGRectMake(-self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionToRight)
    {
        closeRect = CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionNormal)
    {
        closeRect = self.frame;
    }
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDidStopSelector:@selector(closeFinished:finished:context:)];
    
    self.frame = closeRect;
    
    [UIView commitAnimations];
    
    
}

- (void) loadContentView:(UIView *)view withDirection :(ContentViewOpenDirection)direction
{
    CGRect initialRect;
    if(direction == kContentViewOpenDirectionToLeft)
    {
        initialRect = CGRectMake(view.frame.size.width * 2, 0, view.frame.size.width, view.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionToRight)
    {
        initialRect = CGRectMake(- view.frame.size.width * 2, 0, view.frame.size.width, view.frame.size.height);
    }
    else if(direction == kContentViewOpenDirectionNormal)
    {
        initialRect = view.frame;
    }
    view.frame = initialRect;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    view.frame = CGRectMake(0, 0, 1024, 768);
    
    [UIView commitAnimations];
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeContentViewWithDirection:kContentViewOpenDirectionNormal];
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

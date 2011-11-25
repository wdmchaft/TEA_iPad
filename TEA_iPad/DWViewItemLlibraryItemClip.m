//
//  DWViewItemText.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWViewItemLlibraryItemClip.h"
#import <QuartzCore/QuartzCore.h>
#import "TEA_iPadAppDelegate.h"
#import "QuizViewer.h"
#import "LocalDatabase.h"

@implementation DWViewItemLlibraryItemClip
@synthesize htmlString;

- (void) initViewItem
{
    [super initViewItem];
    
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

    webField = [[UIWebView alloc] initWithFrame:CGRectNull];
    [self addSubview:webField];
     
    
    
    if(appDelegate.selectedItemView)
    {
        if([appDelegate.selectedItemView.type isEqualToString:@"video"] || [appDelegate.selectedItemView.type isEqualToString:@"audio"]  )
        {
            NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"htm"];

            NSString *libraryItemPath = [appDelegate.selectedItemView getFullPathForFile:appDelegate.selectedItemView.path];
            NSString *tmpHTMLString = [NSString stringWithFormat:[NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil], libraryItemPath];

            self.htmlString = [tmpHTMLString retain] ;

            [webField loadHTMLString:tmpHTMLString baseURL:nil];
        }
        else if([appDelegate.selectedItemView.type isEqualToString:@"image"])
        {
            NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"htm"];
            NSString *tmpHTMLString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
            NSString *libraryItemPath = [appDelegate.selectedItemView getFullPathForFile:appDelegate.selectedItemView.path];
            tmpHTMLString = [NSString stringWithFormat:tmpHTMLString, libraryItemPath];
            
            self.htmlString = [tmpHTMLString retain];
            
            NSData *data = [tmpHTMLString dataUsingEncoding:NSUTF8StringEncoding];
            [webField loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
        }
        else if([appDelegate.selectedItemView.type isEqualToString:@"quiz"])
        {
            
            QuizViewer *quiz = [[QuizViewer alloc] initWithNibName:@"QuizViewerForScreenCapture" bundle:nil];
            NSString *libraryItemPath = [appDelegate.selectedItemView getFullPathForFile:appDelegate.selectedItemView.quizImagePath];
            
            NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:libraryItemPath]); 
            [quiz.quizImage loadData:imageData MIMEType:@"image/png" textEncodingName:nil baseURL:nil];
            [quiz.quizImageView setImage:[UIImage imageWithContentsOfFile:libraryItemPath]];
            [quiz.quizImage setHidden:YES];
            [quiz.quizImageView setHidden:NO];
            
            quiz.correctAnswer = appDelegate.selectedItemView.correctAnswer;
            quiz.answer = appDelegate.selectedItemView.answer;
            [quiz setupView];

            /* Save quiz image */
            NSData *data = UIImageJPEGRepresentation([quiz captureImage], 1.0);
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imageName = [[LocalDatabase stringWithUUID] stringByAppendingString:@".jpg"]; 
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], imageName];
            [data writeToFile:imagePath atomically:YES];

            NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"htm"];
            NSString *tmpHTMLString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
            tmpHTMLString = [NSString stringWithFormat:tmpHTMLString, imagePath];
            
            self.htmlString = [tmpHTMLString retain];
            
            data = [tmpHTMLString dataUsingEncoding:NSUTF8StringEncoding];
            [webField loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
            
            [quiz release];
        }
        
     }
   
    [webField setBackgroundColor:[UIColor clearColor]];
     webField.scalesPageToFit = YES;
    viewObject = webField;
    [self sendSubviewToBack:viewObject];
    [webField release];
    
    [self resized];
}

- (void) setHtmlString:(NSString *)aHtmlString
{
    htmlString = [aHtmlString retain];
    [webField loadHTMLString:htmlString baseURL:nil];
    [webField setBackgroundColor:[UIColor clearColor]];
}

- (NSString *) getXML
{
    if(htmlString && [htmlString length] > 0)
    {
        return [NSString stringWithFormat:@"<libraryitem position=\"%@\"><![CDATA[%@]]></libraryitem>", [self getPosition], htmlString];
    }
    
    return nil;

}


- (void)dealloc {
    if(htmlString)
        [htmlString release];
    [super dealloc];
}

@end

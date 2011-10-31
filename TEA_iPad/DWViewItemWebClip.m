//
//  DWViewItemText.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWViewItemWebClip.h"
#import <QuartzCore/QuartzCore.h>

@implementation DWViewItemWebClip
@synthesize htmlString;

- (void) initViewItem
{
    [super initViewItem];
    
    webField = [[UIWebView alloc] initWithFrame:CGRectNull];
   
    [self addSubview:webField];
    //[webField loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wwww.google.com"]]];
     
    NSData *value = [[UIPasteboard generalPasteboard] valueForPasteboardType:@"Apple Web Archive pasteboard type" ] ;
    htmlString = [NSString alloc];
   
    if(value)
    {
        NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:value options:NSPropertyListImmutable format:nil error:nil];
        
        NSData *html = [[dict valueForKey:@"WebMainResource"] valueForKey:@"WebResourceData"];
        htmlString = [htmlString initWithData:html encoding:NSUTF8StringEncoding];
        
        [webField loadHTMLString:htmlString baseURL:nil];
        // self.text = htmlCopyValue;
        //  webField.delegate = self;
    }
    
    
    [webField setBackgroundColor:[UIColor clearColor]];
    //[htmlCopyValue release];
    //  [textField setHidden:YES];

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
     
    NSString *xml = [NSString stringWithFormat:@"<webclipitem position=\"%@\"><![CDATA[%@]]></webclipitem>", [self getPosition], htmlString];
    return xml;
}

- (void)dealloc {
    if(htmlString)
        [htmlString release];
    [super dealloc];
}

@end

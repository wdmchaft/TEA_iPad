//
//  DWViewItemText.m
//  TEA_iPad
//
//  Created by Oguz Demir on 14/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWViewItemText.h"


@implementation DWViewItemText

- (void) initViewItem
{
    [super initViewItem];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectNull];
    [textView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:textView];
    [textView setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    textView.text = @"Yeni metin alanı...";
    [textView release];
    
    viewObject = textView;

    [self sendSubviewToBack:viewObject];
    [self resized];
}

- (NSString *) getXML
{
    UITextView *textView = (UITextView *) viewObject;
    NSString *xml = [NSString stringWithFormat:@"<textviewitem position=\"%@\">%@</textviewitem>", [self getPosition], textView.text];
    return xml;
}

@end

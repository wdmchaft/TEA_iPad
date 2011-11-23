//
//  LocationServiceMessageView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import "LocationServiceMessageView.h"

@implementation LocationServiceMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self setBackgroundColor:[UIColor blackColor]];
        
        messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setEditable:NO];
        [self addSubview:messageLabel];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [messageLabel release];
    [super dealloc];
}

- (void) setMessage:(NSString*) message
{
    messageLabel.text = message;
}

@end

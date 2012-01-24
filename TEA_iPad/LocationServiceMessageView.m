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
        
/*        
        messageLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setEditable:NO];
        [self addSubview:messageLabel];
*/        
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [imageView setImage:[UIImage imageNamed:@"LocationBG.jpg"]];
        [self addSubview:imageView];
        
        
        
        errorMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(100, 480, 824, 25)] autorelease];
        [self addSubview:errorMessageLabel];
        
        locationMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 510, 1024, 25)] autorelease];
        [locationMessageLabel setTextColor:[UIColor whiteColor]];
        [locationMessageLabel setBackgroundColor:[UIColor clearColor]];
        [locationMessageLabel setTextAlignment:UITextAlignmentCenter];
        [locationMessageLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        
        [self addSubview:locationMessageLabel]; 
        
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
    
    [errorMessageLabel setBackgroundColor:[UIColor clearColor]];
    [errorMessageLabel setTextAlignment:UITextAlignmentCenter];
    [errorMessageLabel setTextColor:[UIColor whiteColor]];
    errorMessageLabel.text = message;
}


- (void) setMessageLocationLabelAsync:(NSString *) aMessage
{
    [locationMessageLabel setBackgroundColor:[UIColor clearColor]];
    [locationMessageLabel setTextAlignment:UITextAlignmentCenter];
    [locationMessageLabel setTextColor:[UIColor whiteColor]];
    [locationMessageLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    locationMessageLabel.text = aMessage;
}

- (void) setMessageLocationLabel:(NSString *) message
{
    [self performSelectorInBackground:@selector(setMessageLocationLabelAsync:) withObject:message];
}

@end

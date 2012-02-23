//
//  DateView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 10/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DateView.h"
#import "LibraryView.h"

@implementation DateView
@synthesize controller;

- (void) selectDate:(int) aSelectedDate
{
    [selection setHidden:NO];
    selection.frame = CGRectMake(aSelectedDate * 23, 0, 23, 37);
}

- (void) markDate:(int) aSelectedDate
{
    
    
    UIView *mark = [[UIView alloc] initWithFrame:CGRectMake(((aSelectedDate - 1) * 23) + 3, 22, 17, 3)];
    [mark setBackgroundColor:[UIColor orangeColor]];
    [mark setAlpha:0.8];
    mark.tag = 100;
    [self insertSubview:mark belowSubview:numbers];
    [mark release];
}

- (void) initDateView
{
    UIImage *numbersImage = [UIImage imageNamed:@"LibraryDays.png"];
    UIImage *selectionImage = [UIImage imageNamed:@"LibraryDateSelection.png"];
    
    selection = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, selectionImage.size.width, selectionImage.size.height)];
    numbers = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, numbersImage.size.width, numbersImage.size.height)];
    
    [selection setImage:selectionImage];
    [numbers setImage:numbersImage];
    
    [selection setHidden:YES];
    [self addSubview:selection];
    [self addSubview:numbers];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:YES];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] objectAtIndex:0];
    CGPoint touchPos = [touch locationInView:self];
    
    int selectedDate = (touchPos.x / 23) ;

    [self selectDate:selectedDate];
    
    [controller setSelectedDate:selectedDate + 1];
    [controller initSessionNames];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDateView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initDateView];
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

- (void)dealloc
{
    [selection release];
    [numbers release];
    [super dealloc];
}

@end

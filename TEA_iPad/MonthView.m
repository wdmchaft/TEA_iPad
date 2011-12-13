//
//  MonthView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 10/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "MonthView.h"
#import "LibraryView.h"

@implementation MonthView

@synthesize month, year, selected, viewController;

- (NSString *) monthString
{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
    NSString *monthName = [[df monthSymbols] objectAtIndex:month - 1];
    
    
    /*
    switch (month) {
        case 1:  return @"Ocak"; break;
        case 2:  return @"Şubat"; break;
        case 3:  return @"Mart"; break;
        case 4:  return @"Nisan"; break;
        case 5:  return @"Mayıs"; break;
        case 6:  return @"Haziran"; break;
        case 7:  return @"Temmuz"; break;
        case 8:  return @"Ağustos"; break;
        case 9:  return @"Eylül"; break;
        case 10: return @"Ekim"; break;
        case 11: return @"Kasım"; break;
        case 12: return @"Aralık"; break;
    }
    
    return @"";*/
    return monthName;
}

- (void) setSelected:(BOOL)pSelected
{
    selected = pSelected;
    
    if(selected)
    {
        [self setAlpha:1.0];
        UIScrollView *container = (UIScrollView*) [self superview];
        [container setContentOffset:CGPointMake(self.frame.origin.x - self.frame.size.width, 0) animated:YES];
        
    }
    else
    {
        [self setAlpha:0.3];
    }
}

-(void) initMonthView
{
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTextColor:[UIColor whiteColor]];
    [self setFont:[UIFont fontWithName:@"Helvetica" size:18]]; 
    [self setTextAlignment:UITextAlignmentCenter];
    
    [self setUserInteractionEnabled:YES];
    [self setSelected:NO];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMonthView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMonthView];
    }
    return self;
}

-(void) setMonth:(int)pMonth
{
    month = pMonth;
    if(month > 0 && year > 0)
    {
        [self setText:[NSString stringWithFormat:@"%@, %d", [self monthString], year]];
    }
}

-(void) setYear:(int)pYear
{
    year = pYear;
    if(month > 0 && year > 0)
    {
        [self setText:[NSString stringWithFormat:@"%@, %d", [self monthString], year]];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [viewController.selectedMonth setSelected:NO];
    viewController.selectedMonth = self;
    [self setSelected:YES];
    
    [viewController initSessionNames];
  //  [container ]
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
    [super dealloc];
}

@end

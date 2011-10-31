//
//  Timer.m
//  TEA_iPad
//
//  Created by Oguz Demir on 26/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "Timer.h"


@implementation Timer
@synthesize currentMinute, currentSecond, target, selectorMethod;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) thick
{
    if(currentSecond == 0)
    {
        if (currentMinute == 0)
        {
            [self stopTimer];
            if(target && selectorMethod)
            {
                [target performSelector:selectorMethod];
            }
        }
        else
        {
            currentMinute = currentMinute - 1;
            currentSecond = 59;
        }
    }
    else
    {
        currentSecond = currentSecond - 1;
    }
    
    [self setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        currentSecond = 0;
        currentMinute = 0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillRect(context, rect);
    
    int firstDigit = currentSecond % 10;
    int secondDigit = currentSecond / 10;
    int thirdDigit = currentMinute % 10;
    int fourthDigit = currentMinute / 10;
    
    CGFloat x = (rect.size.width - ((13 * 4) + 8)) / 2;
    CGFloat y = (rect.size.height - 20) / 2;
    
    /* draw fourth digit */
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, - rect.size.height);
    
    CGImageRef imageRef = [[UIImage imageNamed:[NSString stringWithFormat: @"%d.png", fourthDigit]] CGImage];
    CGRect imageRect = CGRectMake(x, y, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextDrawImage(context, imageRect, imageRef);
    
    /* draw third digit */
    imageRef = [[UIImage imageNamed:[NSString stringWithFormat: @"%d.png", thirdDigit]] CGImage];
    imageRect = CGRectMake(x + 13, y, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextDrawImage(context, imageRect, imageRef);
    
    /* draw double point */
    imageRef = [[UIImage imageNamed: @"double_point.png"] CGImage];
    imageRect = CGRectMake(x + (13 * 2), y, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextDrawImage(context, imageRect, imageRef);
    
    /* draw second digit */
    imageRef = [[UIImage imageNamed:[NSString stringWithFormat: @"%d.png", secondDigit]] CGImage];
    imageRect = CGRectMake(x + (13 * 2) + 8, y, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextDrawImage(context, imageRect, imageRef);
    
    /* draw first digit */
    imageRef = [[UIImage imageNamed:[NSString stringWithFormat: @"%d.png", firstDigit]] CGImage];
    imageRect = CGRectMake(x + (13 * 3) + 8, y, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGContextDrawImage(context, imageRect, imageRef);
}

- (void) startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(thick) userInfo:nil repeats:YES];
    [timer fire];
}

- (void) stopTimer
{
    [timer invalidate];
    timer = nil;
}

- (void)dealloc
{
    self.target = nil;
    self.selectorMethod = nil;
    [self stopTimer];
    [super dealloc];
}

@end

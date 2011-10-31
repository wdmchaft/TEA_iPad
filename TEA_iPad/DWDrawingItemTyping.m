//
//  DWDrawingItemRectangle.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingItemTyping.h"
#import "DWDrawingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DWDrawingItemTyping
@synthesize text, textColor;

int diffX,diffY;

- (id)init {
    self = [super init];
    if (self) 
    {
       self.text = @"Learn Why You'll Love to Develop with Apple Technologies Read about our powerful, yet easy to use tools and technologies that allow you to turn your concepts into reality";
        
        selectable = YES;
    }
    return self;
}

- (void) displayTextView
{
    if(textFieldImage)
    {
        [textFieldImage release];
        textFieldImage = nil;
    }
    if(!textField )
    {
        textField = [[UITextView alloc] initWithFrame:CGRectNull];
        [drawingView addSubview:textField];
        
        //     textField.text = text;
        textField.delegate = self;
        
        [textField setBackgroundColor:[UIColor clearColor]];
        //  [textField setHidden:YES];
        
    }
    
    
    textField.text = text;
    
    
    CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
    CGPoint lastPos = [[points objectAtIndex:1 ] CGPointValue];
    CGRect textFieldRect = CGRectMake(startPos.x + 10, startPos.y + 10, lastPos.x - startPos.x - 20, lastPos.y - startPos.y - 20);
    textField.frame = textFieldRect;
    
    [textField setHidden:NO];
}

- (void) resizeDidBegin
{
    NSLog(@"resize begin");
    [super resizeDidBegin];
  //  [textField setHidden:NO];
    
    if(textFieldImage)
    {
        [textFieldImage release];
        textFieldImage = nil;
    }
}

- (void) resizeDidEnd
{
    [super resizeDidEnd];
    
    NSLog(@"resize end");
    if(textFieldImage)
    {
        [textFieldImage release];
        textFieldImage = nil;
    }
    
    UIGraphicsBeginImageContext(textField.bounds.size);
    [textField.layer renderInContext:UIGraphicsGetCurrentContext()];
    textFieldImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
    UIGraphicsEndImageContext();
    [textField setHidden:YES];
    [self.drawingView setNeedsDisplay];
}

/*
- (void) resizeDidEnd
{
    [super resizeDidEnd];
    NSLog(@"ending resize");
}

*/



- (void) didDraw
{
   // if(ibSelected && ibResize)
    if([points count] >= 2 && ibResize)
    {
        [self displayTextView];
    }
}

- (void)dealloc {
    
    if(textField)
    {
        [textField release];
    }
    [textColor release];
    [text release];
    [super dealloc];
}


- (void) textFieldDidEndEditing:(UITextField *)pTextField
{
    self.text = pTextField.text;
    
    if(textFieldImage)
    {
        [textFieldImage release];
        textFieldImage = nil;
    }
    
    UIGraphicsBeginImageContext(pTextField.bounds.size);
    [pTextField.layer renderInContext:UIGraphicsGetCurrentContext()];
    textFieldImage = [UIGraphicsGetImageFromCurrentImageContext() retain];
    UIGraphicsEndImageContext(); 
   
    [pTextField setHidden:YES];
    [drawingView setNeedsDisplay];
}


- (void) editingDidBegin
{
    NSLog(@"edit mode");
    
    [super editingDidBegin];
    [self displayTextView];
    [drawingView setNeedsDisplay];
}

-(void)drawIntoContext:(CGContextRef)pContext
{
    CGContextRotateCTM (pContext, rotationValue *  M_PI/180);
    if(!ibDeleted && [points count]==2)
    {
        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGPoint lastPos = [[points objectAtIndex:1 ] CGPointValue];
        
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], [lineColor alphaColorValue]);
        
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);

        CGContextAddRect(pContext,CGRectMake( startPos.x, startPos.y, lastPos.x - startPos.x , lastPos.y - startPos.y)); 
        CGContextStrokePath(pContext);
        
        
        if(textFieldImage)
        {
            CGContextSaveGState(pContext);
            UIImage *image = textFieldImage    ;
            CGRect imageRect = CGRectMake(startPos.x + 10, -startPos.y - 10, image.size.width, image.size.height);       
            
            CGContextTranslateCTM(pContext, 0, image.size.height);
            CGContextScaleCTM(pContext, 1.0, -1.0);
            
            CGContextDrawImage(pContext, imageRect, image.CGImage);
            CGContextRestoreGState(pContext);
        
        }
    }
    
    if(ibSelected)
    {

        CGPoint startPos = [[points objectAtIndex:0 ] CGPointValue];
        CGPoint lastPos = [[points objectAtIndex:1 ] CGPointValue];
        
        CGContextSetRGBStrokeColor(pContext, [lineColor redColorValue],[lineColor greenColorValue], [lineColor blueColorValue], 0.7);
        
        CGContextSetLineWidth(pContext, lineWidth.lineWidth);
        
        CGFloat dash1[] = {5.0, 2.0};
        CGContextSetLineDash(pContext, 0.0, dash1, 2);
        
        CGContextAddRect(pContext,CGRectMake( startPos.x-10, startPos.y-10, (lastPos.x - startPos.x ) + 20 , (lastPos.y - startPos.y )+ 20)); 
        CGContextStrokePath(pContext);
        
        
        int pictHeight = 32;
        int pictWidth = 32;
        int fSpace = 10;
        
        int x1,x2,y1,y2;
        
        x1 = startPos.x;
        x2 = (lastPos.x - startPos.x ) ;
        y1 = startPos.y;
        y2 = (lastPos.y - startPos.y ) ;
        
        [constPropImage drawInRect:CGRectMake(x1 - (fSpace + pictWidth / 2) , y1 - ( fSpace  + pictHeight / 2) , pictWidth , pictHeight)];
        [constPropImage drawInRect:CGRectMake(x1 + x2 + ( fSpace - pictWidth / 2 ) , y1 - ( fSpace + pictHeight / 2 ) , pictWidth, pictHeight)];
        [constPropImage drawInRect:CGRectMake(x1 - (fSpace + pictWidth / 2) , y1 + y2 + ( fSpace  - pictHeight / 2) , pictWidth, pictHeight)];
        [constPropImage drawInRect:CGRectMake(x1 + x2 + (fSpace - pictWidth / 2) , y1 + y2 + ( fSpace  - pictHeight / 2) , pictWidth, pictHeight)];
        
        [resizeImage drawInRect:CGRectMake(x1 - (fSpace + pictWidth / 2) , y1 + (y2 / 2 ) - (pictHeight / 2 ) , pictWidth , pictHeight)];
        [resizeImage drawInRect:CGRectMake(x1 + x2 + ( fSpace - pictWidth / 2 ) , y1 + (y2 / 2 ) - (pictHeight / 2 ) , pictWidth, pictHeight)];
        [resizeImage drawInRect:CGRectMake(x1 + ( ( x2 / 2 ) - (pictWidth / 2) ) , y1 - ( fSpace  + pictHeight / 2) , pictWidth, pictHeight)];
        [resizeImage drawInRect:CGRectMake(x1 + ( ( x2 / 2 ) - (pictWidth / 2) ) , y1 + y2 + ( fSpace  - pictHeight / 2) , pictWidth, pictHeight)];
        
    }
    
    [self didDraw];
}

-(Boolean)checkCollision:(CGPoint) pFromPoint
{
    CGPoint startPos = [[self.points objectAtIndex:0 ] CGPointValue];
    CGPoint lastPos = [[self.points objectAtIndex:1 ] CGPointValue];
    if(CGRectContainsPoint(CGRectMake( startPos.x, startPos.y,  lastPos.x - startPos.x , lastPos.y - startPos.y),pFromPoint)){
        return TRUE;
    }
    return FALSE;
    
}

-(Boolean)checkResizeCollision:(CGPoint) pFromPoint
{
    CGPoint startPos = [[self.points objectAtIndex:0 ] CGPointValue];
    CGPoint lastPos = [[self.points objectAtIndex:1 ] CGPointValue];
    int pictHeight = 32;
    int pictWidth = 32;
    int fSpace = 10;
    
    int x1,x2,y1,y2;
    
    x1 = startPos.x;
    x2 = (lastPos.x - startPos.x ) ;
    y1 = startPos.y;
    y2 = (lastPos.y - startPos.y ) ;
    
    if(CGRectContainsPoint(CGRectMake(x1 - (fSpace + pictWidth / 2) , y1 - ( fSpace  + pictHeight / 2) , pictWidth , pictHeight),pFromPoint)){
        resizePoint = 1;
        return TRUE;
    }else if(CGRectContainsPoint(CGRectMake(x1 + x2 + ( fSpace - pictWidth / 2 ) , y1 - ( fSpace + pictHeight / 2 ) , pictWidth, pictHeight),pFromPoint)){
        resizePoint = 3;
        return TRUE;
    }else if(CGRectContainsPoint(CGRectMake(x1 - (fSpace + pictWidth / 2) , y1 + y2 + ( fSpace  - pictHeight / 2) , pictWidth, pictHeight),pFromPoint)){
        resizePoint = 6;
        return TRUE;
    }else if(CGRectContainsPoint(CGRectMake(x1 + x2 + (fSpace - pictWidth / 2) , y1 + y2 + ( fSpace  - pictHeight / 2) , pictWidth, pictHeight),pFromPoint)){
        resizePoint = 8;
        return TRUE;
    }if(CGRectContainsPoint(CGRectMake(x1 - (fSpace + pictWidth / 2) , y1 + (y2 / 2 ) - (pictHeight / 2 ) , pictWidth , pictHeight),pFromPoint)){
        resizePoint = 4;
        return TRUE;
    }else if(CGRectContainsPoint(CGRectMake(x1 + x2 + ( fSpace - pictWidth / 2 ) , y1 + (y2 / 2 ) - (pictHeight / 2 ) , pictWidth, pictHeight),pFromPoint)){
        resizePoint = 5;
        return TRUE;
    }else if(CGRectContainsPoint(CGRectMake(x1 + ( ( x2 / 2 ) - (pictWidth / 2) ) , y1 - ( fSpace  + pictHeight / 2) , pictWidth, pictHeight),pFromPoint)){
        resizePoint = 2;
        return TRUE;
    }else if(CGRectContainsPoint(CGRectMake(x1 + ( ( x2 / 2 ) - (pictWidth / 2) ) , y1 + y2 + ( fSpace  - pictHeight / 2) , pictWidth, pictHeight),pFromPoint)){
        resizePoint = 7;
        return TRUE;
    }
    resizePoint = 0;
    return FALSE;
    
}

-(Boolean)checkRotateCollision:(CGPoint) pFromPoint
{
    
    /*CGPoint startPos = [[self.points objectAtIndex:0 ] CGPointValue];
    CGPoint lastPos = [[self.points objectAtIndex:1 ] CGPointValue];
    int pictHeight = 32;
    int pictWidth = 32;
    int fSpace = 10;
    
    int x1,x2,y1,y2;
    
    x1 = startPos.x;
    x2 = (lastPos.x - startPos.x ) ;
    y1 = startPos.y;
    y2 = (lastPos.y - startPos.y ) ;
    
    if(CGRectContainsPoint(CGRectMake(x1 + ( ( x2 / 2 ) - (pictWidth / 2) ) , y1 - (fSpace * 2  + pictHeight ) , pictWidth, pictHeight),pFromPoint)){
        rotationValue = 45;
        return TRUE;
    }*/
    return FALSE;
    
}


-(void)setStartPoint:(CGPoint)pStartPoint
{
    if(!ibSelected)
    {
        [points addObject:[NSValue valueWithCGPoint:pStartPoint]];
        [points addObject:[NSValue valueWithCGPoint:pStartPoint]];
    }else{
        CGPoint startPos = [[self.points objectAtIndex:0 ] CGPointValue];
        diffX = pStartPoint.x - startPos.x;
        diffY = pStartPoint.y - startPos.y;
    }
    
}
-(void) addPoint:(CGPoint)pPoint
{
    if(!ibSelected)
    {
        [points removeObjectAtIndex:1];
        [points addObject:[NSValue valueWithCGPoint:pPoint]];
        
        
    }else{
        
        //[points removeObjectAtIndex:1];
        //[points addObject:[NSValue valueWithCGPoint:pPoint]];
        
        CGPoint startPos = [[self.points objectAtIndex:0 ] CGPointValue];
        CGPoint lastPos = [[self.points objectAtIndex:1 ] CGPointValue];
        
        //NSLog(@"point x : %@ point y : %@ ", [NSNumber numberWithInt:lastPos.x] , [NSNumber numberWithInt:lastPos.y] );
        //NSLog(@"diff x : %@ point y : %@ ", [NSNumber numberWithInt:diffX] , [NSNumber numberWithInt:diffY] );
        if (!ibResize) {
            [points removeObjectAtIndex:0];
            [points removeObjectAtIndex:0];
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x - diffX  , pPoint.y - diffY )]];
            [points addObject:[NSValue valueWithCGPoint:CGPointMake((pPoint.x-diffX) +(lastPos.x-startPos.x) , (pPoint.y-diffY) +(lastPos.y-startPos.y) )]];
        }else
        {
            if(resizePoint==1)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x , pPoint.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(lastPos.x , lastPos.y )]];
            }else if(resizePoint==2)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(startPos.x , pPoint.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(lastPos.x , lastPos.y)]];
            }else if(resizePoint==3)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(startPos.x , pPoint.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x , lastPos.y)]];
            }else if(resizePoint==4)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x , startPos.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(lastPos.x , lastPos.y)]];
            }else if(resizePoint==5)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:startPos]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x , lastPos.y)]];
            }else if(resizePoint==6)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x , startPos.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(lastPos.x , pPoint.y)]];
            }else if(resizePoint==7)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(startPos.x , startPos.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(lastPos.x , pPoint.y)]];
            }else if(resizePoint==8)
            {
                [points removeObjectAtIndex:0];
                [points removeObjectAtIndex:0];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(startPos.x , startPos.y )]];
                [points addObject:[NSValue valueWithCGPoint:CGPointMake(pPoint.x , pPoint.y)]];
            }
        }

    }
    
}

- (void) setTextFieldImage:(UIImage*) pImage
{
    textFieldImage = pImage;
}

-(DWDrawingItem *)getItemCopy
{
    DWDrawingItemTyping *itemRect = [[[DWDrawingItemTyping alloc] init]autorelease];
    itemRect.text = textField.text;
    
    [textField removeFromSuperview];
    [itemRect setTextFieldImage:textFieldImage];
    
    [itemRect lineWidth].lineWidth = lineWidth.lineWidth;
    [[itemRect lineColor] setColorWithColors:[self lineColor].redColorValue Green:[self lineColor].greenColorValue Blue:[self lineColor].blueColorValue Alpha:1];
    for (int i=0; i<[points count]; i++) {
        [itemRect.points addObject:[NSValue valueWithCGPoint:[[self.points objectAtIndex:i ] CGPointValue]]];
    }
    return itemRect;
}

- (NSString*) getTextColorXml
{
    if(textColor)
    {
        return [NSString stringWithFormat:@"{%f,%f,%f,%f}", 
                textColor.redColorValue, 
                textColor.greenColorValue, 
                textColor.blueColorValue,
                textColor.alphaColorValue];
    }
    
    return @"";
}

- (NSString*) getXML
{
    NSString *string = [NSString stringWithFormat:@"<text title=\"%@\" font=\"%@\" textColor==\"%@\" textSize=\"%f\" textStyle==\"%@\" points=\"%@\" borderColor=\"%@\" bgColor=\"%@\"/>", 
                        self.text,
                        self.font.faceName,
                        [self getTextColorXml],
                        self.font.size,
                        self.font.style,
                        [self getPoints], 
                        [self getBorderColor], 
                        [self getBgColor]];
    
    return string;
    
}

@end

//
//  DWDrawingView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "DWDrawingView.h"
#import <QuartzCore/QuartzCore.h>
#import "DWDrawingViewController.h"

@implementation DWDrawingView
@synthesize drawingItemList, currentTool, penTool, rectangleTool, lineTool, eraserTool, ovalTool, contextImage, drawingViewController;



/*@synthesize currentTool, zoomLevel,drawingContext,drawingItemList,ibSelectionMode;


@synthesize redColorValue;
@synthesize greenColorValue;
@synthesize blueColorValue;
@synthesize lineWidth;
*/

- (void) initDrawingView
{
    contextImage = [[UIImage alloc] init];
    self.drawingItemList = [[[NSMutableArray alloc] initWithCapacity:3] autorelease]; 
    
    // init tools
    penTool = [[DWPen alloc] init];
    rectangleTool = [[DWRectangle alloc] init];
    lineTool = [[DWLine alloc] init];
    eraserTool = [[DWEraser alloc] init];
    ovalTool = [[DWOval alloc] init];
    
    // set current tool
    currentTool = penTool;
    
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePanGesture:)];
   // [self addGestureRecognizer:panGesture];
    [panGesture release];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handlePinchGesture:)];
    //[self addGestureRecognizer:pinchGesture];
    [pinchGesture release];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self initDrawingView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) 
    {
        [self initDrawingView];

    }
    return self;
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender {
    CGPoint translate = [sender translationInView:self];
    
    CGRect newFrame = currentImageFrame;
    newFrame.origin.x += translate.x;
    newFrame.origin.y += translate.y;
    sender.view.frame = newFrame;
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        currentImageFrame = newFrame;
    }
}

/*
- (DWDrawingItem*) getDrawingItemAtPoint:(CGPoint) point
{
    for(int i=[drawingItemList count] -1 ;i>=0 && ibCatch == FALSE ;i--)
    {
        DWDrawingItem *drawingItem = (DWDrawingItem *)[drawingItemList objectAtIndex:i];
        if (!drawingItem.ibDeleted) 
        {
            if([drawingItem checkCollision:point])
            {
                ibCatch = TRUE;
                drawingItem.ibDeleted= TRUE;
                currentTool.drawingItem = [drawingItem getItemCopy];
                currentTool.drawingItem.ibSelected = TRUE;
                [[currentTool drawingItem] setStartPoint:point];
                
                return drawingItem;
            }
        }
    }
    
    return nil;
}
*/

- (void) willDrawFrom:(CGPoint) pFromPoint 
{
    [currentTool.drawingItem addPoint:pFromPoint];
    /*if(ibSelectionMode)
    {
        
        Boolean itemFind =FALSE;
        
        
        if ([currentTool.drawingItem checkCollision:pFromPoint] && currentTool.drawingItem.ibSelected) 
        {
            
            [[currentTool drawingItem] setStartPoint:pFromPoint];
        }
        else
        if([currentTool.drawingItem checkRotateCollision:pFromPoint] && currentTool.drawingItem.ibSelected)
        {
            currentTool.drawingItem.ibRotate = FALSE;
        }
        else
        if([currentTool.drawingItem checkResizeCollision:pFromPoint] && currentTool.drawingItem.ibSelected){
            currentTool.drawingItem.ibResize = TRUE;
        }
        else
        {
            if(ibCatch) // cancel selection.
            {
                if(![[currentTool drawingItem] checkCollision:pFromPoint] && [currentTool drawingItem].selectable)
                {
                    ibCatch =FALSE;
                    [currentTool drawingItem].ibSelected =FALSE;
                    [drawingItemList addObject:[currentTool drawingItem]];
                    self.currentTool.drawingItem = [[DWDrawingItemPen alloc] init];
                }
            }
            for(int i=[drawingItemList count] -1 ;i>=0 && ibCatch == FALSE ;i--)
            {
                DWDrawingItem *drawingItem = (DWDrawingItem *)[drawingItemList objectAtIndex:i];
                if (!drawingItem.ibDeleted) 
                {
                    if([drawingItem checkCollision:pFromPoint])
                    {
                        itemFind = TRUE;
                        ibCatch = TRUE;
                        drawingItem.ibDeleted= TRUE;
                        currentTool.drawingItem = [drawingItem getItemCopy];
                        currentTool.drawingItem.ibSelected = TRUE;
                        [[currentTool drawingItem] setStartPoint:pFromPoint];
                    }
                }
            }
            if(!itemFind && ibCatch)
            {
                ibCatch = FALSE;
                [currentTool drawingItem].ibSelected =FALSE;
                [drawingItemList addObject:[currentTool drawingItem]];
                //[[currentTool drawingItem] release];
                //currentTool.drawingItem = [[DWDrawingItemPen alloc] init];
            }
        }
    }else
    {
        currentTool.drawingItem.ibResize = YES;
        
        ibCatch = FALSE;
        [[[currentTool drawingItem] lineColor] setColorWithColors:redColorValue Green:greenColorValue Blue:blueColorValue Alpha:1.0];
        [[currentTool drawingItem] lineWidth].lineWidth = lineWidth;
    
        [[currentTool drawingItem] setStartPoint:pFromPoint];
    }  
    [self setNeedsDisplay];
     */ 
}
    
     
- (void) drawFrom:(CGPoint) pFromPoint To:(CGPoint) pToPoint 
{
    
    [currentTool.drawingItem addPoint:pToPoint];
       
    [self setNeedsDisplay];
    
}
    
- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender {
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    self.transform = CGAffineTransformMakeScale(factor, factor);
}


- (void) didDrawFrom:(CGPoint) pFromPoint To:(CGPoint) pToPoint 
{
    [currentTool.drawingItem addPoint:pToPoint];
    [self setNeedsDisplay];
    
    if(currentTool == penTool || 
       currentTool == rectangleTool ||
       currentTool == lineTool ||
       currentTool == eraserTool ||
       currentTool == ovalTool)
    {
        
        contextImage = [[[currentTool drawingItem] drawIntoImage:contextImage withRect:self.frame] retain];
        [drawingViewController.target performSelector:drawingViewController.pageEdited];
    }
    
    [currentTool resetTool];
    
    

}

- (void) longPressGestureCaptured:(UILongPressGestureRecognizer*) sender
{
    /*if([currentTool drawingItem].ibSelected)
    {
        [[currentTool drawingItem] editingDidBegin];
    }*/
    
    //[foregroundLayer getDrawingItemAtPoint:touchLocation];
  //vitam  NSLog(@"long");
}



- (void)dealloc
{
  
    NSLog(@"drawing view dealloc");
    [penTool release];
    [rectangleTool release];
    [lineTool release];
    [eraserTool release];
    [ovalTool release];
    
    [contextImage release];
    [zoomLevel release];
    [drawingItemList release];
    [super dealloc];
}

- (void) setContextImage:(UIImage *)pContextImage
{
    contextImage = [pContextImage retain];
  //  [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    
    drawingContext = UIGraphicsGetCurrentContext();

    // draw context cache image
    if(contextImage)
    {
        CGContextSaveGState(drawingContext);
        CGContextDrawImage(drawingContext, rect, [contextImage CGImage]);
        CGContextRestoreGState(drawingContext);
    }
    [[currentTool drawingItem] drawIntoContext:drawingContext];
    
    //[[currentTool drawingItem] drawIntoContext:drawingContext];
    
    
    //NSLog(@"bytes per row %lu", CGImageGetBytesPerRow([contextImage CGImage]));
    //if(contextImage)
    //{
        // UIImage *image = [UIImage imageNamed:@"QuizBg.jpg"];
        /*CGContextSaveGState(drawingContext);
        CGContextScaleCTM(drawingContext, 1, -1);
        CGContextTranslateCTM(drawingContext, 0, -rect.size.height);
        CGContextDrawImage(drawingContext, rect, [contextImage CGImage]);
        CGContextRestoreGState(drawingContext);*/
    //}
    
   /* if(!contextImage)
    {
        // contextImage = [[UIImage imageNamed:@"QuizBg.jpg"] retain];
        contextImage = [[UIImage alloc] init];
    }
    */
    
    

    
    
   // CGContextStrokePath(drawingContext);
    
    
    /*
    for(int i=0;i<[drawingItemList count];i++)
    {
        DWDrawingItem *drawItem = (DWDrawingItem *)[drawingItemList objectAtIndex:i];
        if(drawItem.ibDeleted)
        {
            
        }
        else
        {
            [drawItem drawIntoContext:drawingContext];
        }
    }
     */
    
    
    
    /*if(!([currentTool drawingItem].selectable))
    {
        //NSLog(@"bytes per row %lu", CGImageGetBytesPerRow([contextImage CGImage]));
        if(contextImage)
        {
            // UIImage *image = [UIImage imageNamed:@"QuizBg.jpg"];
            CGContextSaveGState(drawingContext);
            CGContextScaleCTM(drawingContext, 1, -1);
            CGContextTranslateCTM(drawingContext, 0, -rect.size.height);
            CGContextDrawImage(drawingContext, rect, [contextImage CGImage]);
            CGContextRestoreGState(drawingContext);
        }
        
        if(!contextImage)
        {
           // contextImage = [[UIImage imageNamed:@"QuizBg.jpg"] retain];
            contextImage = [[UIImage alloc] init];
        }

        contextImage = [[[currentTool drawingItem] drawIntoImage:contextImage withRect:self.frame] retain];
        
        // UIImage *image = [UIImage imageNamed:@"QuizBg.jpg"];
        CGContextSaveGState(drawingContext);
        CGContextDrawImage(drawingContext, rect, [contextImage CGImage]);
        CGContextRestoreGState(drawingContext);
        
    }
    else
    {
        
    }
    */
    
    
}

- (UIImage*) screenImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    
    return anImage;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    firstTouchLocation = location;
    [self willDrawFrom:firstTouchLocation];
    
    //currentTool.drawingItem.drawingView = self;
 
    NSLog(@"t b");
}
    

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self drawFrom:firstTouchLocation To:touchLocation];

}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    /*if([touch tapCount] == 2)
    {
       // [drawingViewController.editModeSwitch setOn:YES];
        [drawingViewController editModeOnOffChanged:drawingViewController.editModeSwitch];
    }
    else*/
    {
        CGPoint location = [touch locationInView:self];
        firstTouchLocation = location;
        [self didDrawFrom:firstTouchLocation To:location];
    }
    
}

/*
-(void) changeSelectionState:(Boolean)pNewSelectionState
{
    
}

- (UIImage*) screenImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    
    return anImage;
}

- (void) saveScreenToFile:(NSString *) path
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
       
    NSData *imageData = UIImagePNGRepresentation(anImage);
    if(imageData != nil)
    {
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"screen.png"];

        [imageData writeToFile:filePath atomically:YES];
    }
}

- (void) setSelectionOn
{
    if (!ibSelectionMode) {
        ibSelectionMode = TRUE;
    }
}

- (void) setSelectionOff
{
    if (ibSelectionMode) {
        ibSelectionMode = FALSE;
        if(ibCatch)
        {
            currentTool.drawingItem.ibRotate = FALSE;
            
            if(currentTool.drawingItem.ibResize)
                currentTool.drawingItem.ibResize = FALSE;
            
            ibCatch =FALSE;
            
            [currentTool drawingItem].ibSelected =FALSE;
            [drawingItemList addObject:[currentTool drawingItem]];
            
        }
    }
    [self setNeedsDisplay];
}

- (void) clearAll
{
    [drawingItemList removeAllObjects];
    [self setNeedsDisplay];
    
}
 */

@end

//
//  SessionLibraryItemView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 17/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "SessionLibraryItemView.h"
#import "MediaPlayer.h"
#import "TEA_iPadAppDelegate.h"
#import "LocalDatabase.h"
#import "DocumentViewer.h"
#import "LibraryDocumentItem.h"
#import "SessionView.h"
#import "LibraryView.h"
#import "ImageViewer.h"
#import <QuartzCore/QuartzCore.h>
#import "LocalDatabase.h"
#import "QuizViewer.h"
#import "NotebookAddView.h"
#import "HWView.h"

@implementation SessionLibraryItemView
@synthesize name, path, type, sessionView, quizImagePath, previewPath, correctAnswer, answer, guid, quizOptCount;

- (NSString *) getFullPathForFile:(NSString *) file
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsPath, file];
    
    return fullPath;
    
}


- (UIImage *) getFilePreview;
{
    if(previewPath && [previewPath length] > 0)
    {
        if(previewWebView)
        {
            [previewWebView setHidden:YES];
            [previewWebView setDelegate:nil];
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:[self getFullPathForFile:previewPath]];
        
        previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
        [previewImage setImage:image];
        [self addSubview:previewImage];
        [previewImage.layer setCornerRadius:10];
        [previewImage.layer setMasksToBounds:YES];
        [previewImage release];
        
        return  image;
    }
    else
    {
        // Get file extension
        NSArray *pathComponents = [path componentsSeparatedByString:@"."];
        NSString *extension = [pathComponents lastObject];
        
        if([extension isEqualToString:@"pdf"] || [extension isEqualToString:@"PDF"])
        {
            [self savePreviewForPDFPage];
        }
        else
        {
            if(!previewWebView)
            {
                previewWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
                [previewWebView.layer setCornerRadius:10];
                [previewWebView.layer setMasksToBounds:YES];
                [self addSubview:previewWebView];
            }
            [previewWebView setHidden:NO];
            [previewWebView setDelegate:[self retain]];
            
            [previewWebView setScalesPageToFit:YES];
            if([type isEqualToString:@"quiz"])
                [previewWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[self getFullPathForFile:quizImagePath]]]];
            else
                [previewWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[self getFullPathForFile:path]]]];

        }
    }
    
    return nil;
}

-(void) savePreviewForPDFPage
{
    CGFloat width = 60.0;
    
    // Get the page

    
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL ((CFURLRef) [NSURL fileURLWithPath:[[self getFullPathForFile:path] retain]]);
    CGPDFPageRef page = CGPDFDocumentGetPage (document, 1);
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGFloat pdfScale = width/pageRect.size.width;
    pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
    pageRect.origin = CGPointZero;
    
    
    UIGraphicsBeginImageContext(pageRect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // White BG
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    
    CGContextSaveGState(context);
    
    // ***********
    // Next 3 lines makes the rotations so that the page look in the right direction
    // ***********
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, pageRect, 0, true));
    
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    
    UIImage *thm = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(document);
    
    NSData *imageData = UIImagePNGRepresentation(thm);
    if(imageData != nil)
    {
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fileName = [[LocalDatabase stringWithUUID] stringByAppendingString:@".png"];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        
        [imageData writeToFile:filePath atomically:NO];
        

        [[LocalDatabase sharedInstance] executeQuery:[NSString stringWithFormat:@"update library set previewPath='%@' where path='%@'", fileName, path]];
        
        self.previewPath = fileName;
        
        
        
        previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
        [previewImage setImage:thm];
        [self addSubview:previewImage];
        [previewImage.layer setCornerRadius:10];
        [previewImage.layer setMasksToBounds:YES];
        [previewImage release];
        
        [self bringSubviewToFront:borderImage];
    }
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
 
    UIGraphicsBeginImageContext(webView.frame.size);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    
    NSData *imageData = [[NSData alloc] initWithData:UIImagePNGRepresentation(anImage)] ;
    if(imageData != nil)
    {
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fileName = [[LocalDatabase stringWithUUID] stringByAppendingString:@".png"];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        
        [imageData writeToFile:filePath atomically:NO];
        

        [[LocalDatabase sharedInstance] executeQuery:[NSString stringWithFormat:@"update library set previewPath='%@' where path='%@'", fileName, path]];
        
        previewPath = fileName;
        
        
       
        previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
        [previewImage setImage:anImage];
        [self addSubview:previewImage];
        [previewImage.layer setCornerRadius:10];
        [previewImage.layer setMasksToBounds:YES];
        [previewImage release];
        
        [self bringSubviewToFront:borderImage];
    }
    
    [previewWebView setHidden:YES];
    [previewWebView setDelegate:nil];
    [previewWebView release];
    previewWebView = nil;
    
    [imageData release];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) changeState:(int) pState
{
    state = pState;
    
    if(pState == kStateEditMode)
    {
        [itemName setEnabled:YES];
        [itemName becomeFirstResponder];
        [itemName selectAll:itemName];
        
        
        int yValue = self.frame.origin.y + self.superview.frame.origin.y;
        UIScrollView *scrollView = (UIScrollView*)sessionView.superview;
        [scrollView setContentOffset:CGPointMake(0, yValue) animated:YES];
    }
    else
    {
        [itemName setEnabled:NO];
    }
}

- (void) updateNameOfLibraryItem
{
    self.name = itemName.text;

    [[LocalDatabase sharedInstance] executeQuery:[NSString stringWithFormat:@"update library set name='%@' where path = '%@'", self.name, path]];

}


- (void) initLibraryItemView
{
    
    /* Add preview image */
    
    if (!([type isEqualToString:@"video"] || [type isEqualToString:@"audio"] || [type isEqualToString:@"homework"])) 
    {
        [self getFilePreview];
        
    }
    
    borderImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
    
    if(sessionView.libraryViewController.compactMode)
    {
        [borderImage setFrame:CGRectMake(0, 0, 41 , 45)];
        [previewImage setFrame:CGRectMake(0, 0, 41, 45)];
        
    }
    
    if ([type isEqualToString:@"video"]) 
    {
        [borderImage setImage:[UIImage imageNamed:@"LibraryItemVideo.png"]];
    }
    else if ([type isEqualToString:@"audio"]) 
    {
        [borderImage setImage:[UIImage imageNamed:@"LibraryItemAudio.png"]];
    }
    else if ([type isEqualToString:@"quiz"]) 
    {
        [borderImage setImage:[UIImage imageNamed:@"LibraryItemQuestion.png"]];
    }
    else if ([type isEqualToString:@"image"]) 
    {
        [borderImage setImage:[UIImage imageNamed:@"LibraryItemImage.png"]];
    }
    else if ([type isEqualToString:@"homework"]) 
    {
        [borderImage setImage:[UIImage imageNamed:@"LibraryItemQuiz.png"]];
    }
    else if ([type isEqualToString:@"document"]) 
    {
        [borderImage setImage:[UIImage imageNamed:@"LibraryItemDocument.png"]];
    }
    
    [self addSubview:borderImage];
    [borderImage release];
    
    
    if(sessionView.libraryViewController.compactMode)
    {
        itemName = [[UITextField alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 10, self.frame.size.width, 10)];
        [itemName setFont:[UIFont fontWithName:@"Helvetica" size:8]];
    }
    else
    {
        itemName = [[UITextField alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 15, self.frame.size.width, 15)];
        [itemName setFont:[UIFont fontWithName:@"Helvetica" size:11]];
    }
    
    [itemName setBackgroundColor:[UIColor clearColor]];
    [itemName setTextColor:[UIColor whiteColor]];
    [itemName setText:name];

    [itemName setTextAlignment:UITextAlignmentCenter];
    
    [self changeState:kStateNormalMode];
    
    [self addSubview:itemName];
    [itemName release];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    // add long press gesture recognizer
    UILongPressGestureRecognizer *longPresRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPresRec];
    [longPresRec release];
    
    
    
}

- (void) menuAddToNotebookClicked:(id) sender {
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.selectedItemView = self;
}

- (void) menuChangeNameClicked:(id) sender {
    [self changeState:kStateEditMode];
}

- (void) longPress:(UILongPressGestureRecognizer *) gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        
        NSString *moveToNotebook = NSLocalizedString(@"Move To Notebook", NULL);
        NSString *rename = NSLocalizedString(@"Rename", NULL);
 
        
        UIMenuItem *addToNotebookMenu = [[UIMenuItem alloc] initWithTitle:moveToNotebook action:@selector(menuAddToNotebookClicked:)];
        UIMenuItem *changeNameMenu = [[UIMenuItem alloc] initWithTitle:rename action:@selector(menuChangeNameClicked:)];
        
        
        [[gestureRecognizer view] becomeFirstResponder];
        
        [menuController setMenuItems:[NSArray arrayWithObjects:addToNotebookMenu, changeNameMenu, nil]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 10.0f, 10.0f) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        [addToNotebookMenu release];
        [changeNameMenu release];
    }
}



- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (( selector == @selector(menuAddToNotebookClicked:) || selector == @selector(menuChangeNameClicked:))) {
        return YES;
    }
    return NO;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)doneButtonPressed 
{
	[doneButtonPressed resignFirstResponder];
	return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField 
{
	
    CGRect rect = self.frame;
    int diff = textField.frame.origin.y - 220;
    
    if(diff > 0)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        rect.origin.y -= diff; 
        [self setFrame: rect];
        [UIView commitAnimations];
        
        viewScrollSize = diff;
    }
    
}



-(void)textFieldDidEndEditing:(UITextField *)textField {
	
	if(viewScrollSize > 0)
    {
        CGRect rect = self.frame;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        rect.origin.y += viewScrollSize; 
        [self setFrame: rect];
        [UIView commitAnimations];
        
        viewScrollSize = 0;
    }
    
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
 
    if(state == kStateNormalMode)
    {
        if([type isEqualToString:@"video"])
        {
            MediaPlayer *player = [[MediaPlayer alloc] initWithFrame:CGSizeMake(500, 500) andVideoPath:[self getFullPathForFile:self.path]];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:player];
            [player release];
        }
        else if([type isEqualToString:@"audio"])
        {
            MediaPlayer *player = [[MediaPlayer alloc] initWithFrame:CGSizeMake(500, 500) andVideoPath:[self getFullPathForFile:self.path]];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:player];
            [player release];
        }
        else if([type isEqualToString:@"quiz"])
        {
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            QuizViewer *quiz = [[QuizViewer alloc] initWithNibName:@"QuizViewer" bundle:nil];
            [appDelegate.viewController.view addSubview:quiz.view];
            //[quiz.quizImage setImage:[UIImage imageWithContentsOfFile:self.quizImagePath]];
            [quiz.quizImage loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[self getFullPathForFile:self.quizImagePath]]]];
            quiz.correctAnswer = self.correctAnswer;
            quiz.optionCount = self.quizOptCount;
            quiz.answer = self.answer;
            [quiz setupView];

            
        }
        else if( [type isEqualToString:@"image"])
        {
            LibraryDocumentItem *libraryDocumentItem = [[LibraryDocumentItem alloc] init];
            libraryDocumentItem.path = [self getFullPathForFile:self.path];
            libraryDocumentItem.name = self.name;
            
            DocumentViewer *documentViewer = [[DocumentViewer alloc] initWithLibraryItem:libraryDocumentItem];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:documentViewer];
            [libraryDocumentItem release];
            [documentViewer release];
            
 
        }
        else if([type isEqualToString:@"document"])
        {
            LibraryDocumentItem *libraryDocumentItem = [[LibraryDocumentItem alloc] init];
            libraryDocumentItem.path = [self getFullPathForFile:self.path];
            libraryDocumentItem.name = name;
            
            DocumentViewer *documentViewer = [[DocumentViewer alloc] initWithLibraryItem:libraryDocumentItem];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:documentViewer];
            [libraryDocumentItem release];
            [documentViewer release];
            
        }
        else if([type isEqualToString:@"homework"])
        {
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];

            //- (id)initWithFrame:(CGRect)frame andZipFileName:(NSString*) aZipFileName

            // Get homework name from db

            
            NSString *sql = [NSString stringWithFormat: @"select name from homework where file = '%@'", self.path];
            
            NSString *homeworkName = [[[[LocalDatabase sharedInstance] executeQuery:sql] objectAtIndex:0] valueForKey:@"name"] ;
  
            
            HWView *homeworkView = [[HWView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748) andZipFileName:self.path andHomeworkId:self.guid];
            [homeworkView.titleOfHomework setText:homeworkName]; 
            
            [appDelegate.viewController.view addSubview:homeworkView];
            [homeworkView release];

           /* LibraryDocumentItem *libraryDocumentItem = [[LibraryDocumentItem alloc] init];
            libraryDocumentItem.path = [self getFullPathForFile:self.path];
            libraryDocumentItem.name = name;
            
            DocumentViewer *documentViewer = [[DocumentViewer alloc] initWithLibraryItem:libraryDocumentItem];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:documentViewer];
            [libraryDocumentItem release];
            [documentViewer release];*/
            
        }
    }
    else
    {
        [self changeState:kStateNormalMode];
        [self updateNameOfLibraryItem];
    }
    
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
    if(previewWebView)
    {
        [previewWebView setDelegate:nil];
        [previewWebView release];
    }
    
    [guid release];
    [previewPath release];
    [quizImagePath release];
    [name release];
    [type release];
    [path release];
    [super dealloc];
}

@end

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

@implementation SessionLibraryItemView
@synthesize name, path, type, sessionView, quizImagePath, previewPath, correctAnswer, answer, guid;


- (UIImage *) getFilePreview;
{
    if(previewPath && [previewPath length] > 0)
    {
        if(previewWebView)
        {
            [previewWebView setHidden:YES];
            [previewWebView setDelegate:nil];
        }
        
        UIImage *image = [UIImage imageWithContentsOfFile:previewPath];
        return  image;
    }
    else
    {
        if(!previewWebView)
        {
            previewWebView = [[UIWebView alloc] initWithFrame:self.bounds];
            [self addSubview:previewWebView];
        }
        [previewWebView setHidden:NO];
        [previewWebView setDelegate:[self retain]];
        
        [previewWebView setScalesPageToFit:YES];
        if([type isEqualToString:@"quiz"])
            [previewWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:quizImagePath]]];
        else
            [previewWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
        
        
    }
    
    return nil;
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    UIGraphicsBeginImageContext(webView.frame.size);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *anImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext(); 
    
    NSData *imageData = UIImagePNGRepresentation(anImage);
    if(imageData != nil)
    {
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *fileName = [[LocalDatabase stringWithUUID] stringByAppendingString:@".png"];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
        
        [imageData writeToFile:filePath atomically:NO];
        
        LocalDatabase *db = [[LocalDatabase alloc] init];
        [db openDatabase];
        [db executeQuery:[NSString stringWithFormat:@"update library set previewPath='%@' where path='%@'", filePath, path]];
        [db closeDatabase];
        
        previewPath = filePath;
        [db release];
        
        [previewImage setImage:[self getFilePreview]];
        
    }
    
    [webView setDelegate:nil];
    
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
    }
    else
    {
        [itemName setEnabled:NO];
    }
}

- (void) updateNameOfLibraryItem
{
    self.name = itemName.text;
    LocalDatabase *db = [[LocalDatabase alloc] init];
    [db openDatabase];
    [db executeQuery:[NSString stringWithFormat:@"update library set name='%@' where path = '%@'", self.name, path]];
    [db closeDatabase];
    [db release];
}


- (void) initLibraryItemView
{
    
    /* Add preview image */
    
    if (!([type isEqualToString:@"video"] || [type isEqualToString:@"audio"])) 
    {
        previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
        [previewImage setImage:[self getFilePreview]];
        [self addSubview:previewImage];
        [previewImage.layer setCornerRadius:10];
        [previewImage.layer setMasksToBounds:YES];
        [previewImage release];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 103, 113)];
    
    if(sessionView.libraryViewController.compactMode)
    {
        [imageView setFrame:CGRectMake(0, 0, 41 , 45)];
        [previewImage setFrame:CGRectMake(0, 0, 41, 45)];
        
    }
    
    if ([type isEqualToString:@"video"]) 
    {
        [imageView setImage:[UIImage imageNamed:@"LibraryItemVideo.png"]];
    }
    else if ([type isEqualToString:@"audio"]) 
    {
        [imageView setImage:[UIImage imageNamed:@"LibraryItemAudio.png"]];
    }
    else if ([type isEqualToString:@"quiz"]) 
    {
        [imageView setImage:[UIImage imageNamed:@"LibraryItemQuestion.png"]];
    }
    else if ([type isEqualToString:@"image"]) 
    {
        [imageView setImage:[UIImage imageNamed:@"LibraryItemImage.png"]];
    }
    else if ([type isEqualToString:@"document"]) 
    {
        [imageView setImage:[UIImage imageNamed:@"LibraryItemDocument.png"]];
    }
    
    [self addSubview:imageView];
    [imageView release];
    
    
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
        
        UIMenuItem *addToNotebookMenu = [[UIMenuItem alloc] initWithTitle:@"Deftere Ekle" action:@selector(menuAddToNotebookClicked:)];
        UIMenuItem *changeNameMenu = [[UIMenuItem alloc] initWithTitle:@"İsmini Değiştir" action:@selector(menuChangeNameClicked:)];
        
        
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

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    
    
    if(state == kStateNormalMode)
    {
        if([type isEqualToString:@"video"])
        {
            MediaPlayer *player = [[MediaPlayer alloc] initWithFrame:CGSizeMake(500, 500) andVideoPath:self.path];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:player];
            [player release];
        }
        else if([type isEqualToString:@"audio"])
        {
            MediaPlayer *player = [[MediaPlayer alloc] initWithFrame:CGSizeMake(500, 500) andVideoPath:self.path];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:player];
            [player release];
        }
        else if([type isEqualToString:@"quiz"])
        {
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            QuizViewer *quiz = [[QuizViewer alloc] initWithNibName:@"QuizViewer" bundle:nil];
            [appDelegate.viewController.view addSubview:quiz.view];
            [quiz.quizImage setImage:[UIImage imageWithContentsOfFile:self.quizImagePath]];
            quiz.correctAnswer = self.correctAnswer;
            quiz.answer = self.answer;
            [quiz setupView];
            
            
            
            /*  QuizViewer *notebookAddView = [[QuizViewer alloc] initWithNibName:@"QuizViewer" bundle:nil];
             TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
             [notebookAddView.quizImage setImage:[UIImage imageWithContentsOfFile:self.quizImagePath]];
             [appDelegate.viewController.view addSubview:notebookAddView.view];
             */
            
        }
        else if( [type isEqualToString:@"image"])
        {
            ImageViewer *viewer = [[ImageViewer alloc] initWithFrame:CGSizeMake(500, 500) andImagePath:self.path];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:viewer];
            [viewer release];
        }
        else if([type isEqualToString:@"document"])
        {
            LibraryDocumentItem *libraryDocumentItem = [[LibraryDocumentItem alloc] init];
            libraryDocumentItem.path = path;
            libraryDocumentItem.name = name;
            
            DocumentViewer *documentViewer = [[DocumentViewer alloc] initWithLibraryItem:libraryDocumentItem];
            TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
            
            [appDelegate.viewController.view addSubview:documentViewer];
            [libraryDocumentItem release];
            [documentViewer release];
            
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

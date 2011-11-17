//
//  NotebookCover.m
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookCover.h"
#import "NotebookAddView.h"
#import "TEA_iPadAppDelegate.h"
#import "NotebookParser.h"

@implementation NotebookCover

@synthesize notebookGuid;
@synthesize notebookWorkspace;
@synthesize notebookName;
@synthesize notebookType;
@synthesize notebookLectureGuid;
@synthesize notebookPosition;
@synthesize notebookCoverColor;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        UIImage *image = [UIImage imageNamed:@"NotebookCover.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setImage:image];
        [self addSubview:imageView];
        [imageView release];
        
        notebookLabel = [[UILabel alloc ]initWithFrame:CGRectMake(21, 51, 139, 19)];
        [notebookLabel setTextAlignment:UITextAlignmentCenter];
        [notebookLabel setFont:[UIFont fontWithName:@"Papyrus" size:14]];
        [notebookLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:notebookLabel];
        [notebookLabel release];
        
        UILongPressGestureRecognizer *longPresGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPerformed:)];
        [self addGestureRecognizer:longPresGesture];
        [longPresGesture release];
    }
    return self;
}

- (void) longPressPerformed:(UILongPressGestureRecognizer*) sender
{
    
    NSLog(@"Long press performed");
    [self removeGestureRecognizer:sender];
    
    NotebookAddView *notebookAddView = [[NotebookAddView alloc] initWithNibName:@"NotebookAddView" bundle:nil];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    notebookAddView.notebookCover = self;
    notebookAddView.notebookWorkspace = notebookWorkspace;
    [appDelegate.viewController.view addSubview:notebookAddView.view];
    [notebookAddView viewDidLoad];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) setNotebookName:(NSString *)pNotebookName
{
    notebookName = [pNotebookName retain];
    notebookLabel.text = pNotebookName;
}

- (void)dealloc
{

    
    [notebookType release];
    [notebookGuid release];
    [notebookName release];
    [notebookLectureGuid release];
    [notebookPosition release];
    [notebookCoverColor release];
    
    [super dealloc];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
   // [notebookWorkspace removeFromSuperview];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@/notebook_%@.xml", [paths objectAtIndex:0], self.notebookGuid];
    NotebookParser *parser = [[NotebookParser alloc] init];
    parser.notebook = appDelegate.viewController.notebook;
    [parser getNotebookWithXMLData:[NSData dataWithContentsOfFile:fileName]];
    
    appDelegate.viewController.notebook.name = self.notebookName;
    appDelegate.viewController.notebook.lectureGuid = self.notebookLectureGuid;
    appDelegate.viewController.notebook.type = self.notebookType;
    appDelegate.viewController.notebook.guid = self.notebookGuid;
    
    [appDelegate.viewController setNotebookHidden:NO];
    
    [appDelegate.viewController.notebook notebookOpen:self.notebookGuid];
    [parser release];
}

@end

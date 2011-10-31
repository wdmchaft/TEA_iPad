//
//  NotebookAddView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookAddView.h"
#import "NotebookWorkspace.h"
#import "NotebookCover.h"
#import <QuartzCore/QuartzCore.h>
#import "BonjouClientDataHandler.h"
#import "LocalDatabase.h"

@implementation NotebookAddView
@synthesize notebookType;
@synthesize notebookName;
@synthesize notebookWorkspace;
@synthesize notebookCover;
@synthesize deleteButton;
@synthesize saveButton;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {

        [self.view setBackgroundColor:[UIColor clearColor]];
        
        UIView *bg = [[UIView alloc] initWithFrame:self.view.frame];
        [bg setBackgroundColor:[UIColor blackColor]];
        [bg setAlpha:0.5];
        [bg setOpaque:YES];
        [self.view insertSubview:bg atIndex:0];

        [bg release];

    }
    return self;
}

- (void)dealloc
{
    [notebookCover release];
    [notebookType release];
    [notebookName release];
    [deleteButton release];
    [saveButton release];
    [imageView release];
    [super dealloc];
}

-(void) regenerateGestureRecognizerForNotebookCover
{
    if(notebookCover)
    {
        UILongPressGestureRecognizer *longPresGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:notebookCover action:@selector(longPressPerformed:)];
        [notebookCover addGestureRecognizer:longPresGesture];
        [longPresGesture release];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    deleteButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    deleteButton.layer.cornerRadius = 8;
    deleteButton.layer.masksToBounds = YES;
    deleteButton.layer.borderWidth = 2;
    
    saveButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    saveButton.layer.cornerRadius = 8;
    saveButton.layer.masksToBounds = YES;
    saveButton.layer.borderWidth = 2;
    
    imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    imageView.layer.cornerRadius = 5;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 2;

    if(notebookCover)
    {
        notebookName.text = notebookCover.notebookName;
        [deleteButton setHidden:NO];
    }
    else
    {
        [deleteButton setHidden:YES];
    }

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self regenerateGestureRecognizerForNotebookCover];
    [self.view removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)saveButtonClicked:(id)sender 
{
    
    if(notebookCover)
    {
        notebookCover.notebookName = notebookName.text;
        notebookCover.notebookType = [NSString stringWithFormat:@"%d", [notebookType selectedSegmentIndex]];
        
        [notebookWorkspace updateNotebookCover:notebookCover];
    }
    else
    {
        NotebookCover *cover = [[NotebookCover alloc] initWithFrame:CGRectNull];
        cover.notebookWorkspace = notebookWorkspace;
        cover.notebookGuid = [LocalDatabase stringWithUUID];
        cover.notebookName = notebookName.text;
        cover.notebookType = [NSString stringWithFormat:@"%d", [notebookType selectedSegmentIndex]];
        
        [notebookWorkspace addNotebookCover:cover];
        [cover release];
        
        
    }
    
    [self regenerateGestureRecognizerForNotebookCover];
    [self.view removeFromSuperview];
    
}



- (IBAction)deleteButtonClicked:(id)sender 
{
    if(notebookCover)
    {
        [notebookWorkspace deleteNotebookCover:notebookCover];
        [self regenerateGestureRecognizerForNotebookCover];
        [self.view removeFromSuperview];
    }
    
    
}
- (void)viewDidUnload {
    
    
    
    [self setDeleteButton:nil];
    [self setSaveButton:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}
@end

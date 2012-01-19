//
//  NotebookWorkspace.m
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "NotebookWorkspace.h"
#import "LocalDatabase.h"
#import "NotebookCover.h"
#import "NotebookAddView.h"
#import "TEA_iPadAppDelegate.h"
#import "Notebook.h"

@implementation NotebookWorkspace

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        notebookCovers = [[NSMutableArray alloc] init];
        UIButton *addNotebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
        [addNotebookButton setImage:[UIImage imageNamed:@"NotebookAdd.png"] forState:UIControlStateNormal];
        [self addSubview:addNotebookButton];
        [addNotebookButton addTarget:self action:@selector(notebookAddButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [addNotebookButton release];
        
        [self loadWorkspace];
        
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
    [notebookCovers release];
    [super dealloc];
}


- (void) saveWorkspace
{

    
    // update old records
    [[LocalDatabase sharedInstance] executeQuery: @"update notebookworkspace set state = 1"];
    
    NSString *sql = @"insert into notebookworkspace select '%@', 0, '%@', '%@', '%@', '%@', NULL";
    
    for(NotebookCover *cover in notebookCovers)
    {
        NSString *executeSql = [NSString stringWithFormat:sql, cover.notebookType, cover.notebookGuid, cover.notebookName, cover.notebookLectureGuid, cover.notebookPosition, cover.notebookCoverColor];
        [[LocalDatabase sharedInstance] executeQuery: executeSql];
    }
    
    [[LocalDatabase sharedInstance] executeQuery: @"delete from notebookworkspace where state = 1"];

    
}

- (void) deleteNotebookCover:(NotebookCover*) pCover
{
    [notebookCovers removeObject:pCover];
    [self saveWorkspace];
    [self loadWorkspace];
}

- (void) updateNotebookCover:(NotebookCover*) pCover
{
    [self saveWorkspace];
    [self loadWorkspace];
}

- (void) addNotebookCover:(NotebookCover*) pCover
{
    [notebookCovers addObject:pCover];
    
    // create initial notebook file
    Notebook *notebook = [[[Notebook alloc] init] autorelease];
    [notebook initNotebook];
    notebook.guid = pCover.notebookGuid;
    notebook.lectureGuid = @"";
    notebook.type = pCover.notebookType;
    notebook.name = pCover.notebookName;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *notebookFileName = [notebook.guid stringByAppendingString:@".xml"]; 
    NSString *notebookPath = [NSString stringWithFormat:@"%@/%@",  [paths objectAtIndex:0], notebookFileName];
    notebook.path = notebookPath;
    
    NSString *initialXMLOfNotebook = [notebook getInitialXMLString];
    
    [initialXMLOfNotebook writeToFile:notebookPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                      
    [self saveWorkspace];
    [self loadWorkspace];
}

- (void) loadWorkspace
{
    
    for(UIView *coverV in self.subviews)
    {
        if([[coverV class] isSubclassOfClass:[NotebookCover class]])
        {
            [coverV removeFromSuperview];
        }
    }
    
    [notebookCovers removeAllObjects];

    
    NSArray *result = [[LocalDatabase sharedInstance] executeQuery: @"select * from notebookworkspace"];
    
    int counter = 0;
    int x = 0,y = 0;
    for(NSDictionary *resultDict in result)
    {
        
        CGRect notebookCoverRect;
        
        x = ((counter % 4) * 224) ;
        y = ((counter / 4) * 246) + 45;
        notebookCoverRect = CGRectMake(x, y, 189, 233);
       
        
        NotebookCover *cover = [[NotebookCover alloc] initWithFrame:notebookCoverRect];
       // cover.notebookGuid = [resultDict valueForKey:@"notebook_guid"];
        [self addSubview:cover];
        
        cover.notebookGuid = [resultDict valueForKey:@"notebook_guid"];
        cover.notebookCoverColor = [resultDict valueForKey:@"notebook_cover_color"];
        cover.notebookLectureGuid = [resultDict valueForKey:@"notebook_lecture_guid"];
        cover.notebookName = [resultDict valueForKey:@"notebook_name"];
        cover.notebookPosition = [resultDict valueForKey:@"notebook_position"];
        cover.notebookType = [resultDict valueForKey:@"notebook_type"];

        [notebookCovers addObject:cover];
        cover.notebookWorkspace = self;
        [cover release];
        counter++;
    }
    


    [self setContentSize:CGSizeMake(self.frame.size.width, y + 300)];
}

- (IBAction) notebookAddButtonClicked:(UIButton*) sender
{
    
    NotebookAddView *notebookAddView = [[NotebookAddView alloc] initWithNibName:@"NotebookAddView" bundle:nil];
    TEA_iPadAppDelegate *appDelegate = (TEA_iPadAppDelegate*) [[UIApplication sharedApplication] delegate];
    notebookAddView.notebookCover = nil;
    notebookAddView.notebookWorkspace = self;
    [appDelegate.viewController.view addSubview:notebookAddView.view];
   
    
    /*NotebookAddView *notebookAddView = [[NotebookAddView alloc] initWithNibName:@"NotebookAddView" bundle:nil];
    notebookAddView.notebookCover = nil;
    notebookAddView.notebookWorkspace = self;
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:notebookAddView];
    popover.popoverContentSize = notebookAddView.view.frame.size;
    [popover presentPopoverFromRect:sender.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];*/
}

@end

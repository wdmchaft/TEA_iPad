//
//  NotebookWorkspace.h
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotebookCover;
@interface NotebookWorkspace : UIScrollView 
{
    NSMutableArray *notebookCovers;
    
}

- (void) loadWorkspace;
- (IBAction) notebookAddButtonClicked:(UIButton*) sender;
- (void) addNotebookCover:(NotebookCover*) pCover;
- (void) updateNotebookCover:(NotebookCover*) pCover;
- (void) deleteNotebookCover:(NotebookCover*) pCover;

@end

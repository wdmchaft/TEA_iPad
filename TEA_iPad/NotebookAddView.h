//
//  NotebookAddView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotebookWorkspace;
@class NotebookCover;

@interface NotebookAddView : UIViewController {
    

    UISegmentedControl *notebookType;
    UITextField *notebookName;
    NotebookWorkspace *notebookWorkspace;
    NotebookCover *notebookCover;
    UIButton *deleteButton;
    UIButton *saveButton;
    UIImageView *imageView;
    
}
@property (nonatomic, retain) IBOutlet UITextField *notebookName;
@property (nonatomic, retain) IBOutlet UISegmentedControl *notebookType;
@property (nonatomic, assign) IBOutlet NotebookWorkspace *notebookWorkspace;
@property (nonatomic, retain) NotebookCover *notebookCover;
@property (nonatomic, retain) IBOutlet UIButton *deleteButton;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;

@end

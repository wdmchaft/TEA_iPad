//
//  NotebookCover.h
//  TEA_iPad
//
//  Created by Oguz Demir on 6/9/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NotebookWorkspace;
@interface NotebookCover : UIView {
    
    UILabel *notebookLabel;
    NotebookWorkspace *notebookWorkspace;
    
    
    NSString *notebookName;
    NSString *notebookType;
    NSString *notebookGuid;
    NSString *notebookLectureGuid;
    NSString *notebookPosition;
    NSString *notebookCoverColor;
    
}


@property (nonatomic, retain) NSString *notebookName;
@property (nonatomic, retain) NSString *notebookType;
@property (nonatomic, retain) NSString *notebookGuid;
@property (nonatomic, retain) NSString *notebookLectureGuid;
@property (nonatomic, retain) NSString *notebookPosition;
@property (nonatomic, retain) NSString *notebookCoverColor;
@property (nonatomic, assign) NotebookWorkspace *notebookWorkspace;



@end

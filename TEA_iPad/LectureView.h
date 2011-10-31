//
//  LectureView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 12/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryView;

@interface LectureView : UIView 
{
    NSString *lectureName;
    NSString *lecture_guid;
    BOOL selected;
    
    UIImageView *lectureImage;
    UILabel *labelName;
    
    LibraryView *viewController;
}

@property (nonatomic, retain) NSString *lectureName;
@property (nonatomic, retain) NSString *lecture_guid;

@property (nonatomic, retain) UIImageView *lectureImage;
@property (nonatomic, retain) UILabel *labelName;
@property (nonatomic, assign) LibraryView *viewController;

- (void) selectLecture:(BOOL) pSelected;

@end

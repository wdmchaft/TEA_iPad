//
//  SessionLibraryItemView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 17/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>


enum kState {
    kStateEditMode = 1,
    kStateNormalMode = 0
    };

@class SessionView;
@interface SessionLibraryItemView : UIView <UIWebViewDelegate> {
    NSString *name;
    NSString *path;
    NSString *type;
    NSString *quizImagePath;
    NSString *previewPath;
    NSString *guid;
    int correctAnswer;
    int answer;
    
    int state;
    
    UITextField *itemName ;
    SessionView *sessionView;
    
    UIImageView *previewImage;
    UIImageView *borderImage;
    UIWebView *previewWebView;
    
    
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *quizImagePath;
@property (nonatomic, retain) NSString *previewPath;
@property (nonatomic, assign) SessionView *sessionView;

@property (nonatomic, retain) NSString *guid;
@property (nonatomic, assign) int correctAnswer;
@property (nonatomic, assign) int answer;

- (void) initLibraryItemView;

@end

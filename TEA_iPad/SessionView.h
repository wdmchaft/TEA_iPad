//
//  SessionView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 17/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryView;
@interface SessionView : UIView 
{
    NSString *sessionGuid;
    NSString *sessionName; 
    UILabel *sessionNameLabel;
    
    LibraryView *libraryViewController;
}

@property (nonatomic, retain) NSString *sessionGuid; 
@property (nonatomic, retain) NSString *sessionName; 
@property (nonatomic, assign) LibraryView *libraryViewController; 

- (void) initSessionView;

@end

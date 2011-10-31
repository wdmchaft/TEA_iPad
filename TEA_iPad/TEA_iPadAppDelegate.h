//
//  TEA_iPadAppDelegate.h
//  TEA_iPad
//
//  Created by Oguz Demir on 8/7/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BonjourBrowser.h"
#import "LibraryView.h"
#import "Session.h"
#import "SessionLibraryItemView.h"

enum appState 
{
    kAppStateIdle   = 0,
    kAppStateLogon = 1
};

@class Quiz;
@interface TEA_iPadAppDelegate : NSObject <UIApplicationDelegate> {

    BonjourBrowser *bonjourBrowser;
    Session     *session;
    int         state;
    NSString *connectedHost;
    BOOL exitingApp;
    NSThread *bonjourBrowserThread;
    
    
    SessionLibraryItemView *selectedItemView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LibraryView *viewController;
@property (nonatomic, retain) BonjourBrowser *bonjourBrowser;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) NSString *connectedHost;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) NSThread *bonjourBrowserThread;
@property (nonatomic, retain) SessionLibraryItemView *selectedItemView;

- (NSString *) getDeviceUniqueIdentifier;
- (void) showQuizWindow:(Quiz*) quizView;
- (void) stopBonjourBrowser;
- (void) restartBonjourBrowser;

@end

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
    kAppStateLogon = 1,
    kAppStateSyncing = 2
};

@class Quiz;
@interface TEA_iPadAppDelegate : NSObject <UIApplicationDelegate> {

    BonjourBrowser *bonjourBrowser;
    Session     *session;
    int         state;
    int         guestEnterNumber;
    NSString *connectedHost;
    BOOL exitingApp;
    NSThread *bonjourBrowserThread;
    
    Quiz *currentQuizWindow;
    SessionLibraryItemView *selectedItemView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LibraryView *viewController;
@property (nonatomic, retain) BonjourBrowser *bonjourBrowser;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) NSString *connectedHost;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) Quiz *currentQuizWindow;
@property (nonatomic, assign) NSThread *bonjourBrowserThread;
@property (nonatomic, retain) SessionLibraryItemView *selectedItemView;

@property (nonatomic, assign) int guestEnterNumber;

- (NSString *) getDeviceUniqueIdentifier;
- (NSString *) getDeviceName;
- (void) showQuizWindow:(Quiz*) quizView;
- (void) restartBonjourBrowser;
- (void) stopBonjourBrowser;

@end

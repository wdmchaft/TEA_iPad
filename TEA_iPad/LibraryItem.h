//
//  LibraryItem.h
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalDatabase.h"
#import "TEA_iPadAppDelegate.h"

@interface LibraryItem : NSObject {
@private
    int type;
    NSString *creationDate;
    NSString *modificationDate;
    NSString *sessionName;
    NSString *name;
    NSString *path;
    NSString *serverPath;
    NSString *extension;
    NSString *guid;
}

@property (nonatomic, assign) int type;
@property (nonatomic, retain) NSString *creationDate;
@property (nonatomic, retain) NSString *modificationDate;
@property (nonatomic, retain) NSString *sessionName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *serverPath;
@property (nonatomic, retain) NSString *extension;
@property (nonatomic, retain) NSString *guid;


- (void) saveLibraryItem;

@end

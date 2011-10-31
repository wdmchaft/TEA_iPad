//
//  LocalDatabase.h
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

enum kLocalDbState {
    kLocalDbStateIdle = 0,
    kLocalDbStateRunning = 1
    };

@interface LocalDatabase : NSObject {
@private
    sqlite3 *database;
}

- (void) openDatabase;
- (NSMutableArray*) executeQuery:(NSString*)pQuery;
- (void) closeDatabase;
+ (NSString*) stringWithUUID;

@end

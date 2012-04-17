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
    
    //NSOperationQueue *operationQue;
   // BOOL busy;
}

- (NSMutableArray*) executeQuery:(NSString*)pQuery;
- (NSMutableArray*) executeQuery:(NSString*)pQuery returnSimpleArray:(BOOL) returnSimpleArray;
+ (NSString*) stringWithUUID;
+ (LocalDatabase*) sharedInstance;


@end

//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  GlobalSync;
@interface Sync : NSObject 
{

    int fileSize;
    int previousState;
    NSString *fileName;
    long totalReceivedBytes;
    
   // NSMutableData *downloadData;
    NSMutableArray *fileList;
    NSString *directoryPath;
    
    NSOutputStream *fileStream;
}

@property (nonatomic, assign) GlobalSync *globalSync;

- (void) requestForSync;
- (void) downloadSyncFile;
- (void) applySyncing;
+ (void) compressDocuments;
@end

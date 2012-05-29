//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GlobalSync;
@interface SyncUploadiPadDataService : NSObject 
{
        
    long totalBytes;
    long totalReceivedBytes;
    long sizeOfFile;
    
    NSOutputStream *fileStream;
    NSURLConnection *uploadURLConnection;
    NSURLConnection *downloadURLConnection;
    GlobalSync *globalSync;
}

@property (nonatomic, assign) GlobalSync *globalSync;

- (void) requestForSync;
+ (void) compressDocuments;
@end

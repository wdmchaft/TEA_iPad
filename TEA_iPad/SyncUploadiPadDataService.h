//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncUploadiPadDataService : UIView 
{
    UIProgressView *progressView;
    UILabel *progressLabel;
    
    long totalBytes;
    long totalReceivedBytes;
    
    NSOutputStream *fileStream;
    NSURLConnection *uploadURLConnection;
    NSURLConnection *downloadURLConnection;
}

- (void) requestForSync;
- (void) downloadSyncFile;
- (void) applySyncing;
+ (void) compressDocuments;
@end

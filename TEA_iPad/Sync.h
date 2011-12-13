//
//  Sync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 27/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Sync : UIView 
{
    UIProgressView *progressView;
    UILabel *progressLabel;
    
    int fileSize;
    int previousState;
    NSString *fileName;
    
    NSMutableData *downloadData;
    NSMutableArray *fileList;
    NSString *directoryPath;
}

- (void) requestForSync;
- (void) downloadSyncFile;
- (void) applySyncing;

@end

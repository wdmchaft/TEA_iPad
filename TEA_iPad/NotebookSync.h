//
//  NotebookSync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 11/2/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LibraryView;
@interface NotebookSync : UIView
{
    UIProgressView *progressView;
    UILabel *progressLabel;
    
    int fileSize;
    NSString *fileName;
    
    NSMutableData *downloadData;
    NSMutableArray *fileList;
    NSString *directoryPath;
    LibraryView *libraryView;
}

@property (assign) LibraryView *libraryView;

- (void) compressDocuments;

- (void) requestForNotebookSync;
- (void) uploadSyncFile;
@end

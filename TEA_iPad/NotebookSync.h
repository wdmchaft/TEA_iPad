//
//  NotebookSync.h
//  TEA_iPad
//
//  Created by Oguz Demir on 11/2/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LibraryView, GlobalSync;
@interface NotebookSync : NSObject
{
    
    int fileSize;
    NSString *fileName;
    
    NSMutableData *downloadData;
    NSMutableArray *fileList;
    NSString *directoryPath;
    LibraryView *libraryView;
    GlobalSync *globalSync;
}

@property (assign) LibraryView *libraryView;
@property (assign, nonatomic)  GlobalSync *globalSync;


- (void) compressDocuments;

- (void) requestForNotebookSync;
- (void) uploadSyncFile;
@end

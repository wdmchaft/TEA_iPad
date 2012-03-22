//
//  DocumentViewer.h
//  TEA_iPad
//
//  Created by Oguz Demir on 21/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewerInterface.h"

@class LibraryDocumentItem;
@interface DocumentViewer : UIView <ContentViewerInterface> {
    
    UIWebView *webView;
    LibraryDocumentItem *libraryItem;
    BOOL contentSetFlag;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet LibraryDocumentItem *libraryItem;

- (id) initWithLibraryItem:(LibraryDocumentItem*) libraryDocumentItem;

@end

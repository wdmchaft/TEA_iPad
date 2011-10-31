//
//  Library.h
//  TEA_iPad
//
//  Created by Oguz Demir on 8/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LibraryItem;

@interface Library : NSObject {
@private
}

+ (void) addLibraryItem:(LibraryItem*) pItem;
+ (void) deleteLibraryItem:(LibraryItem*) pItem;

@end

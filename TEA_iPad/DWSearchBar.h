//
//  DWSearchBar.h
//  TEA_iPad
//
//  Created by Oguz Demir on 24/2/2012.
//  Copyright (c) 2012 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWSearchBar : UITextField
{
    id target;
    SEL selector;

}

- (void) searchingForText:(NSString*) aText;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end


@interface DWSearchBarDelegate : NSObject <UITextFieldDelegate>
{
    NSTimer *searchTimer;
    DWSearchBar *searchBar;
}
@end
//
//  LocationServiceMessageView.h
//  TEA_iPad
//
//  Created by Oguz Demir on 17/11/2011.
//  Copyright (c) 2011 Dualware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationServiceMessageView : UIView
{
    UITextView *messageLabel;
    
    UILabel *errorMessageLabel;
    UILabel *locationMessageLabel;
}

- (void) setMessage:(NSString*) message;
- (void) setMessageLocationLabel:(NSString *) message;



@end

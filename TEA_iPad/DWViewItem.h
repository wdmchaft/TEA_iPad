

#import <UIKit/UIKit.h>
#import "DWColor.h"
#import "DWLineWidth.h"
#import "DWLineStyle.h"
#import "DWTransparency.h"
#import "DWFont.h"
#import "DWScale.h"
#import "DWLocation.h"
#import "DWRotate.h"
#import "DWFlip.h"
#import "ScreenResizeAnchor.h"


enum DWViewItemState {
    kItemStateNormal = 0,
    kItemStateSelected = 1,
    kItemStateBeingEdited = 2,
    kItemStateDelted = 3
};

typedef enum DWViewItemState DWViewItemState; 


@class DWObjectView;
@interface DWViewItem : UIView 
{
    UIView *viewObject;
    
    DWColor *lineColor;
    DWLineWidth *lineWidth;
    DWLineStyle *lineStyle;
    DWColor *fillColor;
    DWFont *font;
    DWTransparency *transparency;
    DWScale *scale;
    DWRotate *rotate;
    DWFlip *flip;
    
    DWViewItemState itemState;
    
    BOOL selected;
    
    ScreenResizeAnchor *moveAnchor;
    ScreenResizeAnchor *southEastAnchor;
    ScreenResizeAnchor *closeAnchor;
    
    NSString *guid;
    DWObjectView *container;
}

@property (retain) NSString *guid;
@property (assign) UIView *viewObject;
@property (retain) DWColor *lineColor;
@property (retain) DWLineWidth *lineWidth;
@property (retain) DWLineStyle *lineStyle;
@property (retain) DWColor *fillColor;
@property (retain) DWFont *font;
@property (retain) DWTransparency *transparency;
@property (retain) DWScale *scale;
@property (retain) DWRotate *rotate;
@property (retain) DWFlip *flip;
@property (assign) DWViewItemState itemState;
@property (assign, nonatomic) BOOL selected;
@property (nonatomic, assign) DWObjectView *container;


- (void) initViewItem;
- (void) resized;
- (NSString *) getXML;
- (NSString *) getPosition;
- (CGRect) getPositionByString:(NSString *)aPositionString;

@end

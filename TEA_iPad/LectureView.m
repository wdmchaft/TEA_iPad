//
//  LectureView.m
//  TEA_iPad
//
//  Created by Oguz Demir on 12/8/2011.
//  Copyright 2011 Dualware. All rights reserved.
//

#import "LectureView.h"
#import "LibraryView.h"

@implementation LectureView
@synthesize lectureName, lecture_guid, lectureImage, labelName, viewController;

- (void) selectLecture:(BOOL) pSelected
{
    if(pSelected)
    {
        [self setBackgroundColor:[UIColor colorWithRed:109.0/255.0 green:36.0/255.0 blue:35.0/255.0 alpha:0.5]];
    }
    else
    {
        [self setBackgroundColor:[UIColor colorWithRed:109.0/255.0 green:36.0/255.0 blue:35.0/255.0 alpha:0.0]];
    }
    
    
    
    selected = pSelected;
}

- (void) initLectureView
{
    lectureImage = [[UIImageView alloc] initWithFrame:CGRectMake(9, 12, 26, 26)];
    [lectureImage setImage:[UIImage imageNamed:@"LibraryLectureIcon.png"]];
    
    labelName = [[UILabel alloc] initWithFrame:CGRectMake(46, 18, 129, 16)];
    [labelName setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [labelName setBackgroundColor:[UIColor clearColor]];
    [labelName setTextColor:[UIColor whiteColor]];
    
    [self addSubview:lectureImage];
    [self addSubview:labelName];

    
    [self selectLecture:NO];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLectureView];
    }
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self selectLecture:!selected];
    
    [viewController selectLecture:self];
    
    [viewController initSessionNames];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initLectureView];
    }
    return self;
}

- (void) setLectureName:(NSString *)pLectureName
{
    lectureName = [pLectureName retain];
    [labelName setText:lectureName];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextRef, [[UIColor colorWithRed:76.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0] CGColor]);
    CGContextMoveToPoint(contextRef, 0, rect.size.height);
    CGContextAddLineToPoint(contextRef, rect.size.width, rect.size.height);
    CGContextDrawPath(contextRef, kCGPathStroke);
    
}


- (void)dealloc
{
    [lecture_guid release];
    [lectureImage release];
    [lectureName release];
    [labelName release];

    [super dealloc];
}

@end

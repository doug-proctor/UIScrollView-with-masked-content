//
//  ViewController.h
//  iceSheets
//
//  Created by Doug Proctor on 28/02/2015.
//  Copyright (c) 2015 Doug Proctor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) CGFloat maskStartingY;
@property (nonatomic, assign) CGFloat maskMaxTravellingDistance;

@property (nonatomic, retain) UILabel *header;
@property (nonatomic, retain) UIView *mask;
@property (nonatomic, retain) UIView *content;

@end


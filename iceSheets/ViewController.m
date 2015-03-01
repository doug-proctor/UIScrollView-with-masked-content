//
//  ViewController.m
//  iceSheets
//
//  Created by Doug Proctor on 28/02/2015.
//  Copyright (c) 2015 Doug Proctor. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Settings
    
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.footerHeight = 50.0f;
    self.maskStartingY = 270.0f;  // Distance between top of scrolling content and top of screen
    self.maskMaxTravellingDistance = 180.0f; // Distance the mask can move upwards before its content starts scrolling and gets clipped
    
    self.view.backgroundColor = [UIColor colorWithRed:166/255.0f green:197/255.0f blue:255/255.0f alpha:1.0f]; // light blue
    
    
    
    // Header. This will change size and postion as the scrollview scrolls
    
    self.header = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, self.screenWidth - 200, 100)];
    self.header.text = @"Header";
    self.header.font  = [UIFont boldSystemFontOfSize:50.0f];
    self.header.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.header];
    
    
    
    // Scrollview
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];

    
    
    // Mask
    
    CGRect maskFrame = CGRectMake(0, self.maskStartingY, self.screenWidth, self.screenHeight - self.maskStartingY - self.footerHeight);
    self.mask = [[UIView alloc] initWithFrame:maskFrame];
    self.mask.clipsToBounds = YES; // important
    [scrollView addSubview:self.mask];
    
    
    
    // Scrollable content
    
    self.content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight * 1.5)];
    self.content.backgroundColor = [UIColor lightGrayColor];
    
    // Create some dummy content. 14 red bars that vertically fill the content container
    for (int i = 0; i < 14; i++) {
        UILabel *bar = [[UILabel alloc] initWithFrame:CGRectMake(20, 0 + 52*i, self.screenWidth - 40, 45)];
        bar.text = [NSString stringWithFormat:@"bar no. %i", i + 1];
        [self.content addSubview:bar];
    }
    
    [self.mask addSubview:self.content];
    
    
    
    // Set scrollview size to 1.5x the screen height for this example
    
    scrollView.contentSize = CGSizeMake(self.screenWidth, (self.screenHeight * 1.5) + self.footerHeight);
    
    

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    // MOVING THE MASK
    //
    // Here we prevent the mask from moving as the scollview scrolls. There are two phases of motion:
    //
    // 1.
    // At first, we want the top of the mask to move upwards as the user starts scrolling, while the bottom of
    // the mask stays anchored to the top of the footer. This means the mask's height increases at the same
    // speed that it moves upwards. During this phase, the mask appears to be stretching upwards.
    //
    //
    // 2.
    // Then when the mask reaches the threshold (self.maskMaxTravellingDistance), the top of the mask
    // stops moveing upwards with the scroll and the mask stops increasing in height. It is then completely
    // stationary with respect to the screen.
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    CGFloat newMaskHeight;
    CGFloat newMaskY;
    CGRect newMaskFrame;
    
    if (offsetY < self.maskMaxTravellingDistance) {
        
        // Motion phase 1
        
        newMaskHeight = self.screenHeight - self.maskStartingY - self.footerHeight + offsetY;
        newMaskY = self.maskStartingY;
        newMaskFrame = CGRectMake(0, newMaskY, self.screenWidth, newMaskHeight);
        
    } else {
        
        // Motion phase 2

        newMaskHeight = self.screenHeight - self.maskStartingY - self.footerHeight + self.maskMaxTravellingDistance;
        newMaskY =  self.maskStartingY - self.maskMaxTravellingDistance + offsetY;
        newMaskFrame = CGRectMake(0, newMaskY, self.screenWidth, newMaskHeight);
        
    }
    
    self.mask.frame = newMaskFrame;
    
    
    // MOVING THE CONTENT
    //
    // Because our content container is a subview of the mask, it means that the content view is
    // also fixed to the screen along with the mask. To counteract this, we have to do the opposite to what we
    // did to the mask (above).
    //
    // But we only have to apply this counteractive measure when the scrollview is in the second phase of
    // motion, i.e. after the mask has stopped moving upwards and has become fully static with relative to the
    // screen.
    
    CGFloat newContentY;
    CGRect newContentFrame;
    
    if (offsetY < self.maskMaxTravellingDistance) {
        
        // Motion phase 1
        
        // We make sure the frame is set correctly to stop the top of the content from occasionally being clipped by the mask when
        // the user has scrolled too fast.
        
        newContentFrame = CGRectMake(0, 0, self.screenWidth , self.screenHeight * 1.5);
        self.content.frame = newContentFrame;
        
    } else {
        
        // Motion phase 2
        
        // Once the mask is fixed to the screen, ensure that its content subview can still scroll
        
        newContentY = self.maskMaxTravellingDistance - offsetY;
        newContentFrame = CGRectMake(0, newContentY, self.screenWidth , self.screenHeight * 1.5);
        self.content.frame = newContentFrame;
        
    }
    
    
    // MOVING THE HEADER
    //
    // In this example, the header is going to move upwards and fade out as the user scrolls.
    // The to achieve this effect, we must map the header's origin.y to the amount that the
    // scrollview has scrolled
    
    CGRect newHeaderFrame;
    CGFloat newHeaderY;
    
    if (offsetY <= self.maskMaxTravellingDistance) {
        
        newHeaderY = 100 - (offsetY * 0.5); // move at half the speed of scroll
        newHeaderFrame = CGRectMake(self.header.frame.origin.x, newHeaderY, self.header.frame.size.width, self.header.frame.size.height);
        self.header.frame = newHeaderFrame;
        
    } else {
        
        newHeaderY = 100 - (self.maskMaxTravellingDistance * 0.5);
        newHeaderFrame = CGRectMake(self.header.frame.origin.x, newHeaderY, self.header.frame.size.width, self.header.frame.size.height);
        self.header.frame = newHeaderFrame;

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
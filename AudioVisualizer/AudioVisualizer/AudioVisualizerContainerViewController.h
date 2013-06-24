//
//  AudioVisualizerContainerViewController.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/24/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioVisualizerContainerViewController : UIViewController

@property (strong, nonatomic) UIViewController* currentChildViewController;
- (void) displayContentController:(UIViewController*)content;

@end

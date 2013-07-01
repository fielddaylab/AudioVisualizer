//
//  TestStartViewController.h
//  AudioVisualizer
//
//  Created by Nick Heindl on 6/28/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioVisualizerViewController.h"

@interface TestStartViewController : UIViewController

@property (strong, nonatomic) AudioVisualizerViewController *AVVC;

- (IBAction)gotonext:(id)sender;

- (IBAction)record:(id)sender;
- (IBAction)stoprec:(id)sender;

@end

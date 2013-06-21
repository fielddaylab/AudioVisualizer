//
//  WaveformViewController.h
//  AudioVisualizer
//
//  Created by Justin Moeller on 6/20/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaveFormViewIOS.h"

@interface WaveformViewController : UIViewController
@property (weak, nonatomic) IBOutlet WaveFormViewIOS *waveformView;

@end

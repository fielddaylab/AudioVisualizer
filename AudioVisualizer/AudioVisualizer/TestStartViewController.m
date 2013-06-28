//
//  TestStartViewController.m
//  AudioVisualizer
//
//  Created by Nick Heindl on 6/28/13.
//  Copyright (c) 2013 Justin Moeller. All rights reserved.
//

#import "TestStartViewController.h"

#import "AudioVisualizerViewController.h"

@interface TestStartViewController ()

@end

@implementation TestStartViewController

@synthesize AVVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)nextScreen
{
    
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
//                                                                             style:UIBarButtonItemStyleBordered
//                                                                            target:nil
//                                                                            action:nil];
    
    
    
    self.AVVC = [[AudioVisualizerViewController alloc] initWithNibName:@"AudioVisualizerViewController" bundle:nil];


    
    
    [self.navigationController pushViewController:self.AVVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotonext:(id)sender {
    [self nextScreen];
}
@end

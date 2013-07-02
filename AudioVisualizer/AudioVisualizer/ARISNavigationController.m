//
//  ARISNavigationController.m
//  ARIS
//
//  Created by Phil Dougherty on 5/16/13.
//
//

#import "ARISNavigationController.h"

@implementation ARISNavigationController

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end

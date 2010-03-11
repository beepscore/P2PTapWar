//
//  P2PTapWarAppDelegate.m
//  P2PTapWar
//
//  Created by Chris Adamson on 6/9/09.
//  Copyright Subsequently and Furthermore, Inc. 2009. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import "P2PTapWarAppDelegate.h"
#import "P2PTapWarViewController.h"

@implementation P2PTapWarAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end

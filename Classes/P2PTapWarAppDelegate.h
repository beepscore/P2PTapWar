//
//  P2PTapWarAppDelegate.h
//  P2PTapWar
//
//  Created by Chris Adamson on 6/9/09.
//  Copyright Subsequently and Furthermore, Inc. 2009. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//


#import <UIKit/UIKit.h>

@class P2PTapWarViewController;

@interface P2PTapWarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    P2PTapWarViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet P2PTapWarViewController *viewController;

@end


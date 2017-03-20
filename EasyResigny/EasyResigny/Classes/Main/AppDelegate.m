//
//  AppDelegate.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+ERSetup.h"
#import "ERDashboardViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.window.contentViewController = [[ERDashboardViewController alloc] init];
    [self.window makeMainWindow];
    [self applicationDidFinishLaunching];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

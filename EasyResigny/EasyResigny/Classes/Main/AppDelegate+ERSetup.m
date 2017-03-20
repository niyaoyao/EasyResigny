//
//  AppDelegate+ERSetup.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "AppDelegate+ERSetup.h"
#import "NYCocoaKit.h"

@implementation AppDelegate (ERSetup)

- (void)applicationDidFinishLaunching {
    [NYCocoaKit showAlertOfKind:NSAlertStyleCritical
                          title:@"About EasyResigny"
                        message:@"EasyResigny is an opensource resign IPA tool created by NY~ \nWelcome to star the project on GitHub~ Thanks~"];
}

@end

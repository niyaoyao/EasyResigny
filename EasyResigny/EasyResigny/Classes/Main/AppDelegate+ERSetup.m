//
//  AppDelegate+ERSetup.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "AppDelegate+ERSetup.h"
#import "ERContex.h"

@implementation AppDelegate (ERSetup)

- (void)applicationDidFinishLaunching {
    [ERContex easyResignyDidLaunched];
}

@end

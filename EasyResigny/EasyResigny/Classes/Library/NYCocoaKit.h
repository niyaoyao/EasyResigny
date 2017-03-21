//
//  NYCocoaKit.h
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NYCocoaKit : NSObject

+ (void)showErrorMessage:(NSString *)message;
+ (void)showInformationMessage:(NSString *)message;
+ (void)showAlertOfKind:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message;

@end

//
//  NYCocoaKit.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "NYCocoaKit.h"

static NSString * const kAlertErrorTitle = @"Error";
static NSString * const kAlertInfoioinforTitle = @"Information";

@implementation NYCocoaKit

+ (void)showErrorMessage:(NSString *)message {
    [self showAlertOfKind:NSAlertStyleCritical title:kAlertErrorTitle message:message];
}

+ (void)showInformationMessage:(NSString *)message {
    [self showAlertOfKind:NSAlertStyleCritical title:kAlertInfoioinforTitle message:message];
}

+ (void)showAlertOfKind:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:style];
    [alert runModal];
}

@end

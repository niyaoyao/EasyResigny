//
//  NYCmd.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "NYCmdTool.h"
#import "NYCocoaKit.h"

static NSString * const kCMDZip = @"/usr/bin/zip";
static NSString * const kCMDUnzip = @"/usr/bin/zip";
static NSString * const kCMDCodesign = @"/usr/bin/codesign";
static NSString * const kCMDSecurity = @"/usr/bin/security";



static NYCmdTool *cmdTool = nil;

@implementation NYCmdTool

+ (instancetype)commonTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cmdTool = [[super alloc] init];
    });
    return cmdTool;
}

+ (void)startResign {
    [self checkCommandLineTools];
}

+ (void)checkCommandLineTools {
    [self checkCommandLineToolsCompletion:nil];
}

+ (void)checkCommandLineToolsCompletion:(void(^)())completion {
    if (![NYCmdTool fileExistsAtPath:kCMDZip]) {
        [NYCocoaKit showAlertOfKind:NSAlertStyleCritical title:@"" message:@"不能运行 zip 命令"];
        exit(0);
    }
    if (![NYCmdTool fileExistsAtPath:kCMDUnzip]) {
        [NYCocoaKit showAlertOfKind:NSAlertStyleCritical title:@"错误" message:@"不能运行 unzip 命令"];
        exit(0);
    }
    if (![NYCmdTool fileExistsAtPath:kCMDCodesign]) {
        [NYCocoaKit showAlertOfKind:NSAlertStyleCritical title:@"错误" message:@"不能运行 codesign 命令"];
        exit(0);
    }
    if (![NYCmdTool fileExistsAtPath:kCMDCodesign]) {
        [NYCocoaKit showAlertOfKind:NSAlertStyleCritical title:@"错误" message:@"不能运行 security 命令"];
        exit(0);
    }
}

+ (void)getCertifacations {
    
}

+ (BOOL)fileExistsAtPath:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

@end

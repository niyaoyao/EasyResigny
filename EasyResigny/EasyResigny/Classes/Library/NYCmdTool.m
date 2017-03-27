//
//  NYCmd.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.

#import "NYCmdTool.h"
#import "NYCocoaKit.h"
#import <objc/runtime.h>

static NSString * const kCMDZip = @"/usr/bin/zip";
static NSString * const kCMDUnzip = @"/usr/bin/unzip";
static NSString * const kCMDCodesign = @"/usr/bin/codesign";
static NSString * const kCMDSecurity = @"/usr/bin/security";
static NSString * const kCMDDefaults = @"/usr/bin/defaults";
static NSString * const kCMDChmod = @"/bin/chmod";
static NSString * const kCMDPlistBuddy = @"/usr/libexec/PlistBuddy";
static NSString * const kCMDFind = @"/usr/bin/find";
static NSString * const kCMDRM = @"/bin/rm";

static const char * kCmdTaskQueueLabel = "that.boring.bear.ny.cmdtask.queue";
static NSInteger const kErrorCode = 19999;

static NYCmdTool *cmdTool = nil;

@implementation NYCmdTool


+ (void)printCommand:(NSString *)taskPath arguments:(NSArray *)arguments {
    
    NSMutableString *cmdString = [NSMutableString stringWithString:taskPath];
    for (NSString *arg in arguments) {
        [cmdString appendString:[NSString stringWithFormat:@" %@", arg]];
    }
    
    NSLog(@"Command Line:\n%@\n", cmdString);
}

+ (instancetype)commonTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cmdTool = [[super alloc] init];
    });
    return cmdTool;
}

+ (void)checkCommandLineTools {
    [self checkCommandLineToolsCompletion:nil];
}

+ (void)checkCommandLineToolsCompletion:(NYCmdToolCompletion)completion {
    if (![NYCmdTool fileExistsAtPath:kCMDZip]) {
        [NYCocoaKit showErrorMessage:@"Cannot run zip"];
        exit(0);
    }
    if (![NYCmdTool fileExistsAtPath:kCMDUnzip]) {
        [NYCocoaKit showErrorMessage:@"Cannot run unzip"];
        exit(0);
    }
    if (![NYCmdTool fileExistsAtPath:kCMDCodesign]) {
        [NYCocoaKit showErrorMessage:@"Cannot run codesign"];
        exit(0);
    }
    if (![NYCmdTool fileExistsAtPath:kCMDCodesign]) {
        [NYCocoaKit showErrorMessage:@"Cannot run security"];
        exit(0);
    }
    
    if (completion) {
        completion(nil, nil);
    }
}

+ (BOOL)fileExistsAtPath:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

#pragma mark - Task
+ (dispatch_queue_t)cmdTaskQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create(kCmdTaskQueueLabel, DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark - Find Certificate Task
+ (void)launchFindCertificateIDsTaskCompletion:(NYCmdToolCompletion)completion {
    NYCmdToolCompletion outputHandler = ^(NSError *error, NSString *outputStr) {
        NSArray *outputArray = [outputStr componentsSeparatedByString:@"\n"];
        NSMutableArray *certificates = [NSMutableArray array];
        for (NSString *string in outputArray) {
            NSRange range = [string rangeOfString:@"\""];
            if (range.location != NSNotFound) {
                NSString *certString = [[string substringFromIndex:range.location] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                [certificates addObject:certString];
            }
        }
        if (completion) {
            completion(error, certificates);
        }
    };
    [self launchTaskPath:kCMDSecurity arguments:@[@"find-identity", @"-v", @"-p", @"codesigning"] currentPath:nil outputHandler:outputHandler];
}

#pragma mark - Load Provision Profile Task
+ (void)launchLoadProvisionProfilePath:(NSString *)provisionProfilePath completion:(NYCmdToolCompletion)completion {
    NYCmdToolCompletion outputHandler = ^(NSError *error, NSString *outputStr) {
        NSString *xmlStartStr = @"<?xml";
        NSRange range = [outputStr rangeOfString:xmlStartStr];
        if (range.location != NSNotFound) {
            outputStr = [outputStr substringFromIndex: range.location];
        }
        
        NSDictionary *plistDic = outputStr.propertyList;
        
        if (completion) {
            completion(error, plistDic);
        }
    };
    
    if ([self fileExistsAtPath:provisionProfilePath]) {
        [self launchTaskPath:kCMDSecurity arguments:@[@"cms", @"-D", @"-i", provisionProfilePath] currentPath:nil outputHandler:outputHandler];
    } else {
        completion([self errorInfo:@"Provinsion File is not Exist!"], nil);
    }
}

#pragma mark - Unzip App Task
+ (void)launchUnzipAppTaskWithSource:(NSString *)source destination:(NSString *)destination completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDUnzip arguments:@[@"-q", source, @"-d", destination] currentPath:nil outputHandler:completion];
}

#pragma mark - Defaults Read Task
+ (void)launchReadTaskPath:(NSString *)path key:(NSString *)key completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDDefaults arguments:@[@"read", path, key] currentPath:nil outputHandler:completion];
}

#pragma mark - Defaults Write Task
+ (void)launchWriteTaskPlistPath:(NSString *)plistPath key:(NSString *)key value:(NSString *)value completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDDefaults arguments:@[@"write", plistPath, key, value] currentPath:nil outputHandler:completion];
}

#pragma mark - Chmod Task
+ (void)launchChmodExecutable:(NSString *)executablePath completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDChmod arguments:@[@"755", executablePath] currentPath:nil outputHandler:completion];
}

#pragma mark - Save Entitlements Task
+ (NSString *)saveEntitlements:(NSDictionary *)entitlements savedDir:(NSString *)savedDir {
    NSString *entPath = [savedDir stringByAppendingPathComponent:@"entitlements.plist"];
    NSLog(@"========== %@", entPath);
    [entitlements writeToFile:entPath atomically:YES];
    return entPath;
}

#pragma mark - Find Task
+ (void)launchTaskFindPath:(NSString *)path fileName:(NSString *)fileName completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDFind arguments:@[path, @"-name", fileName] currentPath:nil outputHandler:^(NSError *error, NSString *outputStr) {
        NSString *errorStr = @"No such file or directory";
        NSRange range = [outputStr rangeOfString:errorStr];
        if (range.location != NSNotFound) {
            if (completion) {
                completion(nil, nil);
            }
        } else {
            if (completion) {
                completion([self errorInfo:outputStr], nil);
            }
        }
    }];
}

#pragma mark - Codesign Task
+ (void)launchCodesignCertificate:(NSString *)certificate entitlementsPlisPath:(NSString *)entitlementsPlisPath
                          appPath:(NSString *)appPath completion:(NYCmdToolCompletion)completion {
    NSString *entStr = [NSString stringWithFormat:@"--entitlements=%@", entitlementsPlisPath];
    [self launchTaskPath:kCMDCodesign arguments:@[@"-vvv", @"-fs", certificate, @"--no-strict", entStr, appPath] currentPath:nil outputHandler:completion];
}

#pragma mark - Zip IPA Task
+ (void)launchZipCurrentPath:(NSString *)current destinationPath:(NSString *)destination appPath:(NSString *)appPath completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDZip arguments:@[@"-qry", destination, @"."] currentPath:current outputHandler:completion];
}


+ (void)launchRemovePath:(NSString *)path completion:(NYCmdToolCompletion)completion {
    [self launchTaskPath:kCMDRM arguments:@[@"-fr", path] currentPath:nil outputHandler:completion];
}

#pragma mark - Helper
+ (void)launchTaskPath:(NSString *)taskPath arguments:(NSArray *)arguments currentPath:(NSString *)current outputHandler:(NYCmdToolCompletion)outputHandler {
    NSTask *task = [self taskWithLaunchPath:taskPath arguments:arguments];
    NSPipe *pipe = [self pipeWithTask:task];
    if (current.length > 0) {
        [task setCurrentDirectoryPath:current];
    }
    
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    
    dispatch_block_t taskDefaultBlock = ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (outputHandler) {
            outputHandler(nil, outputStr);
        }
    };
    
    dispatch_async([self cmdTaskQueue], taskDefaultBlock);
    [task launch];
    [self printCommand:taskPath arguments:arguments];
}

+ (NSTask *)taskWithLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:launchPath];
    [task setArguments:arguments];
    return task;
}

+ (NSPipe *)pipeWithTask:(NSTask *)task {
    NSPipe *pipe = [[NSPipe alloc] init];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    return pipe;
}

+ (NSError *)errorInfo:(NSString *)userInfo {
    return [NSError errorWithDomain:@"NYCmdTool"
                               code:kErrorCode
                           userInfo:@{NSLocalizedDescriptionKey: userInfo}];
}

@end

//
//  NYCmd.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
///Users/niyao/N.Y./Reverse/Resign/ReMeituan/unsigned/imeituan_no_watch_no_plugins.ipa

#import "NYCmdTool.h"
#import "NYCocoaKit.h"

static NSString * const kCMDZip = @"/usr/bin/zip";
static NSString * const kCMDUnzip = @"/usr/bin/unzip";
static NSString * const kCMDCodesign = @"/usr/bin/codesign";
static NSString * const kCMDSecurity = @"/usr/bin/security";
static NSString * const kCMDDefaults = @"/usr/bin/defaults";
static NSString * const kCMDChmod = @"/bin/chmod";
static NSString * const kCMDPlistBuddy = @"/usr/libexec/PlistBuddy";

static const char * kCmdTaskQueueLabel = "that.boring.bear.ny.cmdtask.queue";
static NSInteger const kErrorCode = 19999;

static NYCmdTool *cmdTool = nil;

@implementation NYCmdTool

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
+ (NSTask *)findCertificateIDsTask {
    return [self taskWithLaunchPath:kCMDSecurity arguments:@[@"find-identity", @"-v", @"-p", @"codesigning"]];
}

+ (void)launchFindCertificateIDsTaskCompletion:(NYCmdToolCompletion)completion {
    NSTask *findCerTask = [self findCertificateIDsTask];
    NSPipe *pipe = [self pipeWithTask:findCerTask];
    
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
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
            completion(nil, certificates);
        }
    });
    [findCerTask launch];
}

+ (void)getCertifacationsCompletion:(NYCmdToolCompletion)completion {
    [self launchFindCertificateIDsTaskCompletion:completion];
}

#pragma mark - Load Provision Profile Task
+ (NSTask *)loadProvinsionProfilePlistTask:(NSString *)provisionProfilePath {
    return [self taskWithLaunchPath:kCMDSecurity arguments:@[@"cms", @"-D", @"-i", provisionProfilePath]];
}

+ (void)launchLoadProvisionProfilePath:(NSString *)provisionProfilePath completion:(NYCmdToolCompletion)completion {
    if ([self fileExistsAtPath:provisionProfilePath]) {
        NSTask *loadProvisionPlistTask = [self loadProvinsionProfilePlistTask:provisionProfilePath];
        NSPipe *pipe = [self pipeWithTask:loadProvisionPlistTask];
        
        __block NSFileHandle *handle = [pipe fileHandleForReading];
        dispatch_async([self cmdTaskQueue], ^{
            NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
            NSString *xmlStartStr = @"<?xml";
            NSRange range = [outputStr rangeOfString:xmlStartStr];
            if (range.location != NSNotFound) {
                outputStr = [outputStr substringFromIndex: range.location];
            }
            
            NSDictionary *plistDic = outputStr.propertyList;
            
            if (completion) {
                completion(nil, plistDic);
            }
            
        });
        [loadProvisionPlistTask launch];
    } else {
        completion([self errorInfo:@"Provinsion File is not Exist!"], nil);
    }
}

+ (void)loadProvinsionProfilePlistWithPath:(NSString *)provisionProfilePath completion:(NYCmdToolCompletion)completion {
    [self launchLoadProvisionProfilePath:provisionProfilePath completion:completion];
}


#pragma mark - Unzip App Task
+ (NSTask *)unzipSource:(NSString *)source destination:(NSString *)destination {
    return [self taskWithLaunchPath:kCMDUnzip arguments:@[@"-q", source, @"-d", destination]];
}

+ (void)launchUnzipAppTaskWithSource:(NSString *)source destination:(NSString *)destination completion:(NYCmdToolCompletion)completion {
    NSTask *unzipTask = [self unzipSource:source destination:destination];
    NSPipe *pipe = [self pipeWithTask:unzipTask];
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (completion) {
            completion(nil, outputStr);
        }
    });
    
    [unzipTask launch];
}

+ (void)unzipAppWithIPAPath:(NSString *)ipaPath workSpace:(NSString *)workSpace completion:(NYCmdToolCompletion)completion {
    [self launchUnzipAppTaskWithSource:ipaPath destination:workSpace completion:completion];
}

#pragma mark - Defaults Read Task
+ (void)launchReadTaskPath:(NSString *)path key:(NSString *)key completion:(NYCmdToolCompletion)completion {
    NSTask *readTask = [self taskWithLaunchPath:kCMDDefaults arguments:@[@"read", path, key]];
    NSPipe *pipe = [self pipeWithTask:readTask];
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (completion) {
            completion(nil, outputStr);
        }
    });
    [readTask launch];
}

#pragma mark - Defaults Write Task
+ (void)launchWriteTaskPlistPath:(NSString *)plistPath key:(NSString *)key value:(NSString *)value completion:(NYCmdToolCompletion)completion {
    NSTask *task = [self taskWithLaunchPath:kCMDDefaults arguments:@[@"write", plistPath, key, value]];
    NSPipe *pipe = [self pipeWithTask:task];
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (completion) {
            completion(nil, outputStr);
        }
    });
    [task launch];
}

#pragma mark - Chmod Task
+ (void)launchChmodExecutable:(NSString *)executablePath completion:(NYCmdToolCompletion)completion {
    NSTask *task = [self taskWithLaunchPath:kCMDChmod arguments:@[@"755", executablePath]];
    NSPipe *pipe = [self pipeWithTask:task];
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (completion) {
            completion(nil, outputStr);
        }
    });
    [task launch];
}

#pragma mark - Save Entitlements Task
+ (NSString *)saveEntitlements:(NSDictionary *)entitlements savedDir:(NSString *)savedDir {
    NSString *entPath = [savedDir stringByAppendingPathComponent:@"entitlements.plist"];
    NSLog(@"%@", entPath);
    [entitlements writeToFile:entPath atomically:YES];
    return entPath;
}


#pragma mark - Codesign Task
+ (void)launchCodesignCertificate:(NSString *)certificate entitlementsPlisPath:(NSString *)entitlementsPlisPath
                          appPath:(NSString *)appPath completion:(NYCmdToolCompletion)completion {
    NSString *entStr = [NSString stringWithFormat:@"--entitlements=%@", entitlementsPlisPath];
    NSTask *task = [self taskWithLaunchPath:kCMDCodesign arguments:@[@"-vvv", @"-fs", certificate, @"--no-strict", entStr, appPath]];
    NSPipe *pipe = [self pipeWithTask:task];
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (completion) {
            completion(nil, outputStr);
        }
    });
    [task launch];
}

#pragma mark - Zip IPA Task
+ (void)launchZipCurrentPath:(NSString *)current destinationPath:(NSString *)destination appPath:(NSString *)appPath completion:(NYCmdToolCompletion)completion {
    NSTask *task = [self taskWithLaunchPath:kCMDZip arguments:@[@"-qry", destination, @"."]];
    [task setCurrentDirectoryPath:current];
    NSPipe *pipe = [self pipeWithTask:task];
    __block NSFileHandle *handle = [pipe fileHandleForReading];
    dispatch_async([self cmdTaskQueue], ^{
        NSString *outputStr = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
        if (completion) {
            completion(nil, outputStr);
        }
    });
    [task launch];
}


#pragma mark - Helper
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

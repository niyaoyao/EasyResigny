//
//  NYCmd.h
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NYCmdToolCompletion)(NSError *error, id object);

@interface NYCmdTool : NSObject

+ (BOOL)fileExistsAtPath:(NSString *)filePath;
+ (dispatch_queue_t)cmdTaskQueue;

#pragma mark - Check
+ (void)checkCommandLineTools;
+ (void)checkCommandLineToolsCompletion:(NYCmdToolCompletion)completion;

#pragma mark - Resign Task
+ (void)launchFindCertificateIDsTaskCompletion:(NYCmdToolCompletion)completion;
+ (void)launchLoadProvisionProfilePath:(NSString *)provisionProfilePath completion:(NYCmdToolCompletion)completion;
+ (void)launchUnzipAppTaskWithSource:(NSString *)source destination:(NSString *)destination completion:(NYCmdToolCompletion)completion;

+ (void)launchReadTaskPath:(NSString *)path key:(NSString *)key completion:(NYCmdToolCompletion)completion;
+ (void)launchWriteTaskPlistPath:(NSString *)plistPath key:(NSString *)key value:(NSString *)value completion:(NYCmdToolCompletion)completion;
+ (void)launchChmodExecutable:(NSString *)executablePath completion:(NYCmdToolCompletion)completion;
+ (NSString *)saveEntitlements:(NSDictionary *)entitlements savedDir:(NSString *)savedDir;
+ (void)launchCodesignCertificate:(NSString *)certificate entitlementsPlisPath:(NSString *)entitlementsPlisPath
                          appPath:(NSString *)appPath completion:(NYCmdToolCompletion)completion;
+ (void)launchZipCurrentPath:(NSString *)current destinationPath:(NSString *)destination appPath:(NSString *)appPath completion:(NYCmdToolCompletion)completion;
+ (void)launchTaskFindPath:(NSString *)path fileName:(NSString *)fileName completion:(NYCmdToolCompletion)completion;
+ (void)launchRemovePath:(NSString *)path completion:(NYCmdToolCompletion)completion;
@end

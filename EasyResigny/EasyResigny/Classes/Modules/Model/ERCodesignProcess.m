//
//  ERResignProcess.m
//  EasyResigny
//
//  Created by NiYao on 21/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "ERCodesignProcess.h"
#import "NYCmdTool.h"
#import "ERContex.h"

@implementation ERCodesignProcess

+ (void)startLoadProvisionProfileCompletion:(ERCodesignCompletion)loadProvisionProfileCompletion
                         unzipIPACompletion:(ERCodesignCompletion)unzipIPACompletion
                getExecutableFileCompletion:(ERCodesignCompletion)getExecutableFileCompletion
                    changeExeModeCompletion:(ERCodesignCompletion)changeExeModeCompletion
                   writeInfoPlistCompletion:(ERCodesignCompletion)writeInfoPlistCompletion
                  signCertificateCompletion:(ERCodesignCompletion)signCertificateCompletion
                          saveIPACompletion:(ERCodesignCompletion)saveIPACompletion {
    
    dispatch_async([NYCmdTool cmdTaskQueue], ^{
        [self loadProvisionProfileCompletion:loadProvisionProfileCompletion];
        
        [self unzipIPACompletion:unzipIPACompletion];
        
        [self getExecutableFileCompletion:getExecutableFileCompletion];
        
        [self changeExeModeCompletion:changeExeModeCompletion];
        
        [self writeInfoPlistCompletion:writeInfoPlistCompletion];
        
        [self signCertificateCompletion:signCertificateCompletion];
        
        [self saveIPACompletion:saveIPACompletion];
    });
}

+ (void)loadProvisionProfileCompletion:(ERCodesignCompletion)completion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NYCmdTool launchLoadProvisionProfilePath:[ERContex getSelectProvisionProfilePath] completion:^(NSError *error, NSDictionary *plistDic) {
        [ERContex setProvisionPlist:plistDic];
        [NYCmdTool saveEntitlements:[ERContex getEntitlements]
                           savedDir:[ERContex getWorkSpacePath]];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (completion) {
        completion([ERContex getResignedAppBundleID]);
    }
}

+ (void)unzipIPACompletion:(ERCodesignCompletion)unzipIPACompletion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NYCmdTool launchUnzipAppTaskWithSource:[ERContex getIPAOriginPath] destination:[ERContex getWorkSpacePath] completion:^(NSError *error, id object) {
        [ERContex setPayloadPath];
        [ERCodesignProcess rmPath];
        dispatch_semaphore_signal(semaphore);
        
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (unzipIPACompletion) {
        unzipIPACompletion(@"Start to Unzip IPA...");
    }
}

+ (void)getExecutableFileCompletion:(ERCodesignCompletion)getExecutableFileCompletion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NYCmdTool launchReadTaskPath:[ERContex getInfoPlistPath] key:@"CFBundleExecutable" completion:^(NSError *error, NSString *exeName) {
        exeName = [exeName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [ERContex setCFBundleExecutableName:exeName];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (getExecutableFileCompletion) {
        getExecutableFileCompletion(@"Start to Find App Executable File...");
    }
}

+ (void)changeExeModeCompletion:(ERCodesignCompletion)changeExeModeCompletion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NYCmdTool launchChmodExecutable:[ERContex getExecutableFilePath] completion:^(NSError *error, id object) {
        NSLog(@"%@", object);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (changeExeModeCompletion) {
        changeExeModeCompletion(@"Start to Change Executable File Mode...");
    }
}

+ (void)writeBundleID {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [NYCmdTool launchWriteTaskPlistPath:[ERContex getInfoPlistPath] key:@"CFBundleIdentifier" value:[ERContex getResignedAppBundleID] completion:^(NSError *error, id object) {
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

+ (void)writeInfoPlistCompletion:(ERCodesignCompletion)writeInfoPlistCompletion {
    [self writeBundleID];
    NSString *appName = [ERContex getAppName];
    NSString *appVersion = [ERContex getAppVersion];
    NSString *appBuildCode = [ERContex getAppBuildCode];
    
    if (appName.length > 0) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [NYCmdTool launchWriteTaskPlistPath:[ERContex getInfoPlistPath] key:@"CFBundleDisplayName" value:appName completion:^(NSError *error, id object) {
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    if (appVersion.length > 0) {
        dispatch_semaphore_t versionSemaphore = dispatch_semaphore_create(0);
        [NYCmdTool launchWriteTaskPlistPath:[ERContex getInfoPlistPath] key:@"CFBundleVersion" value:appVersion completion:^(NSError *error, id object) {
            dispatch_semaphore_signal(versionSemaphore);
        }];
        dispatch_semaphore_wait(versionSemaphore, DISPATCH_TIME_FOREVER);
    }
    
    if (appBuildCode.length > 0) {
        dispatch_semaphore_t shortVersionsemaphore = dispatch_semaphore_create(0);
        [NYCmdTool launchWriteTaskPlistPath:[ERContex getInfoPlistPath] key:@"CFBundleShortVersionString" value:appBuildCode completion:^(NSError *error, id object) {
            dispatch_semaphore_signal(shortVersionsemaphore);
        }];
        dispatch_semaphore_wait(shortVersionsemaphore, DISPATCH_TIME_FOREVER);
    }
    
    if (writeInfoPlistCompletion) {
        writeInfoPlistCompletion(@"Start to Modify Info.plist...");
    }
}

+ (void)signCertificateCompletion:(ERCodesignCompletion)signCertificateCompletion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [NYCmdTool launchCodesignCertificate:[ERContex getSelectCertificate]
                    entitlementsPlisPath:[ERContex getEntitlementsPath]
                                 appPath:[ERContex getAppPath] completion:^(NSError *error, id object) {
                                     dispatch_semaphore_signal(semaphore);
                                     if (signCertificateCompletion) {
                                         signCertificateCompletion(@"Start to Codesign App...");
                                     }
                                 }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

}

+ (void)saveIPACompletion:(ERCodesignCompletion)completion {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSString *ipa = [[ERContex getIPAOriginPath] lastPathComponent];
    NSString *ipaReName = [ipa stringByReplacingOccurrencesOfString:@".ipa" withString:@"-"];
    ipaReName = [ipaReName stringByAppendingString:[ERContex getResignedAppBundleID]];
    ipaReName = [ipaReName stringByAppendingString:@"-resigny"];
    ipaReName = [ipaReName stringByAppendingPathExtension:@"ipa"];
    
    NSRange range = [[ERContex getIPAOriginPath] rangeOfString:ipa];
    NSString *des = [[ERContex getIPAOriginPath] substringToIndex:range.location];
    des = [des stringByAppendingPathComponent:ipaReName];
    [ERContex setResignedAppSavePath:des];
    
    [NYCmdTool launchZipCurrentPath:[ERContex getWorkSpacePath] destinationPath:des appPath:[ERContex getAppPath] completion:^(NSError *error, id object) {
        [ERCodesignProcess easyResignyDidFinishCodesigning];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (completion) {
        NSString *str = [NSString stringWithFormat:@"Save IPA :%@", [ERContex getResignedAppSavePath]];
        completion(str);
    }
}

+ (void)rmPath {
    dispatch_semaphore_t watchSemaphore = dispatch_semaphore_create(0);
    NSString *watch = [[ERContex getAppPath] stringByAppendingPathComponent:@"Watch"];
    [NYCmdTool launchRemovePath:watch completion:^(NSError *error, id object) {
        dispatch_semaphore_signal(watchSemaphore);
    }];
    
    dispatch_semaphore_t pluginsSemaphore = dispatch_semaphore_create(0);
    NSString *plugins = [[ERContex getAppPath] stringByAppendingPathComponent:@"PlugIns"];
    [NYCmdTool launchRemovePath:plugins completion:^(NSError *error, id object) {
        dispatch_semaphore_signal(pluginsSemaphore);
    }];
    
    dispatch_semaphore_wait(pluginsSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(watchSemaphore, DISPATCH_TIME_FOREVER);
}

+ (void)syncMethod:(SEL)selector target:(id)target parameters:(NSArray *)parameters {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // __block NSMutableDictionary *responseDic = [NSMutableDictionary dictionary];
    // NYCmdToolCompletion completion = ^(id  _Nonnull result, NSError * _Nullable error) {
        
    //    dispatch_semaphore_signal(semaphore);
    // };
    NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    
    NSInteger index = 2;
    for (int i = 0; i < parameters.count; i++, index++) {
        id p = [parameters objectAtIndex:i];
        [invocation setArgument:&p atIndex:index];
    }
    
    //[invocation setArgument:&completion atIndex:index];
    [invocation invokeWithTarget:target];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark - Life Cycle
+ (void)easyResignyDidLaunched {
    NSString *workSpace = [NSTemporaryDirectory() stringByAppendingString:[[NSBundle mainBundle]bundleIdentifier]];
    [[NSFileManager defaultManager] removeItemAtPath:workSpace error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:workSpace withIntermediateDirectories:TRUE attributes:nil error:nil];
    [ERContex setWorkSpacePath:workSpace];
    NSLog(@"workSpace: %@\n", workSpace);
}

+ (void)easyResignyDidFinishCodesigning {
    [ERContex clearAll];
    [self easyResignyDidLaunched];
}


@end

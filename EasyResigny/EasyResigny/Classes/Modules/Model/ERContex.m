//
//  ERContex.m
//  EasyResigny
//
//  Created by NiYao on 21/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "ERContex.h"
#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]

static ERContex *context = nil;

#pragma mark + Input Data
static NSString * const kIPAOriginPathKey = @"IPAOriginPath";
static NSString * const kSelectCertificateKey = @"SelectCertificate";
static NSString * const kSelectProvisionProfilePathKey = @"SelectProvisionProfilePath";
static NSString * const kAppBundleIDKey = @"AppBundleID";
static NSString * const kAppNameKey = @"AppName";
static NSString * const kAppVersionKey = @"AppVersion";
static NSString * const kAppBuildCodeKey = @"AppBuildCode";

#pragma mark + Meta Data
static NSString * const kProvisionPlistKey = @"ProvisionPlist";
static NSString * const kEntitlementsKey = @"Entitlements";
static NSString * const kInfoPlistBundleIDKey = @"CFBundleIdentifier";
static NSString * const kFrameworksDirName = @"Frameworks";
static NSString * const kProductsDirName = @"Products";

static NSString * const kWorkSpacePathKey = @"WorkSpace";
static NSString * const kWorkSpacePayloadPathKey = @"WorkSpacePayloadPath";
static NSString * const kWorkSpaceAppPathKey = @"WorkSpaceAppPath";
static NSString * const kWorkSpaceAppInfoPlistPathKey = @"WorkSpaceAppInfoPlistPath";

@implementation ERContex

+ (instancetype)sharedContex {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        context = [[ERContex alloc] init];
    });
    return context;
}

+ (void)easyResignyDidLaunched {
    NSString *workSpace = [NSTemporaryDirectory() stringByAppendingString:[[NSBundle mainBundle]bundleIdentifier]];
    [[NSFileManager defaultManager] removeItemAtPath:workSpace error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:workSpace withIntermediateDirectories:TRUE attributes:nil error:nil];
    [ERContex setWorkSpacePath:workSpace];
    NSLog(@"workSpace: %@\n", workSpace);
}

#pragma mark - Getter & Setter
+ (void)setIPAOriginPath:(NSString *)originPath {
    [ERContex setContextObject:originPath key:kIPAOriginPathKey];
}

+ (NSString *)getIPAOriginPath {
    return [ERContex getContextObjectForKey:kIPAOriginPathKey];
}

+ (void)clearIPAOriginPath {
    [ERContex removeContextObjectForKey:kIPAOriginPathKey];
}

+ (void)setSelectCertificate:(NSString *)certificate {
    [ERContex setContextObject:certificate key:kSelectCertificateKey];
}

+ (NSString *)getSelectCertificate {
    return [ERContex getContextObjectForKey:kSelectCertificateKey];
}

+ (void)setSelectProvisionProfilePath:(NSString *)selectProvisionProfilePath {
    [ERContex setContextObject:selectProvisionProfilePath key:kSelectProvisionProfilePathKey];
}

+ (NSString *)getSelectProvisionProfilePath {
    return [ERContex getContextObjectForKey:kSelectProvisionProfilePathKey];
}

+ (void)setResignedAppBundleID:(NSString *)appBundleID {
    [ERContex setContextObject:appBundleID key:kAppBundleIDKey];
}

+ (NSString *)getResignedAppBundleID {
    return [ERContex getContextObjectForKey:kAppBundleIDKey];
}

+ (void)setAppName:(NSString *)appName {
    [ERContex setContextObject:appName key:kAppNameKey];
}

+ (NSString *)getAppName {
    return [ERContex getContextObjectForKey:kAppNameKey];
}

+ (void)setAppVersion:(NSString *)appVersion {
    [ERContex setContextObject:appVersion key:kAppVersionKey];
}

+ (NSString *)getAppVersion {
    return [ERContex getContextObjectForKey:kAppVersionKey];
}

+ (void)setAppBuildCode:(NSString *)appBuildCode {
    [ERContex setContextObject:appBuildCode key:kAppBuildCodeKey];
}

+ (NSString *)getAppBuildCode {
    return [ERContex getContextObjectForKey:kAppBuildCodeKey];
}

+ (void)setProvisionPlist:(NSDictionary *)dic {
    [ERContex setContextObject:dic key:kProvisionPlistKey];
    [ERContex setEntitlements:[dic objectForKey:kEntitlementsKey]];
}

+ (void)setEntitlements:(NSDictionary *)entitlements {
    [ERContex setContextObject:entitlements key:kEntitlementsKey];
    NSString *team = [[entitlements objectForKey:@"com.apple.developer.team-identifier"] stringByAppendingString:@"."];
    NSString *bundleID = [entitlements objectForKey:@"application-identifier"];
    NSRange range = [bundleID rangeOfString:team];
    bundleID = [bundleID substringFromIndex:range.length];
    [ERContex setResignedAppBundleID:bundleID];
}

+ (NSDictionary *)getEntitlements {
    return [ERContex getContextObjectForKey:kEntitlementsKey];
}

+ (NSString *)getEntitlementsPath {
    return [[ERContex getWorkSpacePath] stringByAppendingPathComponent:@"entitlements.plist"];
}
+ (void)setWorkSpacePath:(NSString *)tempWorkingPath {
    [ERContex setContextObject:tempWorkingPath key:kWorkSpacePathKey];
}

+ (NSString *)getWorkSpacePath {
    return [ERContex getContextObjectForKey:kWorkSpacePathKey];
}

+ (void)setPayloadPath {
    NSString *path = [[ERContex getWorkSpacePath] stringByAppendingPathComponent:@"Payload"];
    [ERContex setContextObject:path key:kWorkSpacePayloadPathKey];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ERContex getPayloadPath]
                                                                               error:nil];
    
    for (NSString *file in dirContents) {
        if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"]) {
            NSString *appPath = [[ERContex getPayloadPath] stringByAppendingPathComponent:file];
            [ERContex setAppPath:appPath];
            [ERContex setInfoPlistPath:[appPath stringByAppendingPathComponent:@"Info.plist"]];
        }
    }
}

+ (NSString *)getPayloadPath {
    return [ERContex getContextObjectForKey:kWorkSpacePayloadPathKey];
}

+ (void)setAppPath:(NSString *)path {
    [ERContex setContextObject:path key:kWorkSpaceAppPathKey];
}

+ (NSString *)getAppPath {
    return [ERContex getContextObjectForKey:kWorkSpaceAppPathKey];
}

+ (void)setInfoPlistPath:(NSString *)path {
    [ERContex setContextObject:path key:kWorkSpaceAppInfoPlistPathKey];
}

+ (NSString *)getInfoPlistPath {
    return [ERContex getContextObjectForKey:kWorkSpaceAppInfoPlistPathKey];
}

#pragma mark + Helper
+ (void)setContextObject:(id)value key:(NSString *)key {
    [USER_DEFAULTS removeObjectForKey:key];
    [USER_DEFAULTS setObject:value forKey:key];
    [USER_DEFAULTS synchronize];
}

+ (void)removeContextObjectForKey:(NSString *)key {
    [USER_DEFAULTS removeObjectForKey:key];
}

+ (id)getContextObjectForKey:(NSString *)key {
    return [USER_DEFAULTS objectForKey:key];
}

@end

//
//  ERContex.h
//  EasyResigny
//
//  Created by NiYao on 21/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERContex : NSObject

+ (instancetype)sharedContex;

+ (void)setIPAOriginPath:(NSString *)originPath;
+ (NSString *)getIPAOriginPath;
+ (void)clearIPAOriginPath;

+ (void)setSelectCertificate:(NSString *)certificate;
+ (NSString *)getSelectCertificate;

+ (void)setSelectProvisionProfilePath:(NSString *)selectProvisionProfilePath;
+ (NSString *)getSelectProvisionProfilePath;

+ (NSString *)getResignedAppBundleID;

+ (void)setAppName:(NSString *)appName;
+ (NSString *)getAppName;

+ (void)setAppVersion:(NSString *)appVersion;
+ (NSString *)getAppVersion;

+ (void)setAppBuildCode:(NSString *)appBuildCode;
+ (NSString *)getAppBuildCode;

+ (void)setProvisionPlist:(NSDictionary *)dic;
+ (NSDictionary *)getEntitlements;
+ (NSString *)getEntitlementsPath;

+ (NSString *)getWorkSpacePath;

+ (void)setPayloadPath;
+ (NSString *)getPayloadPath;
+ (NSString *)getAppPath;
+ (NSString *)getInfoPlistPath;


+ (void)easyResignyDidLaunched;

@end

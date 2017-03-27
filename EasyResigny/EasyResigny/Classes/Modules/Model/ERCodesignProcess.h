//
//  ERResignProcess.h
//  EasyResigny
//
//  Created by NiYao on 21/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ERCodesignCompletion)(NSString *prompt);

@interface ERCodesignProcess : NSObject

+ (void)easyResignyDidLaunched;

+ (void)startLoadProvisionProfileCompletion:(ERCodesignCompletion)loadProvisionProfileCompletion
                         unzipIPACompletion:(ERCodesignCompletion)unzipIPACompletion
                getExecutableFileCompletion:(ERCodesignCompletion)getExecutableFileCompletion
                    changeExeModeCompletion:(ERCodesignCompletion)changeExeModeCompletion
                   writeInfoPlistCompletion:(ERCodesignCompletion)writeInfoPlistCompletion
                  signCertificateCompletion:(ERCodesignCompletion)signCertificateCompletion
                          saveIPACompletion:(ERCodesignCompletion)saveIPACompletion;

+ (void)easyResignyDidFinishCodesigning;

@end

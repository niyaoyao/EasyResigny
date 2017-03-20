//
//  NYCmd.h
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NYCmdTool : NSObject

+ (void)startResign;
+ (void)checkCommandLineTools;
+ (void)checkCommandLineToolsCompletion:(void(^)())completion;

@end

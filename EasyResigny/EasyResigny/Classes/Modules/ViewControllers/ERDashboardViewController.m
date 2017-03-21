//
//  ERDashboardViewController.m
//  EasyResigny
//
//  Created by NiYao on 20/03/2017.
//  Copyright © 2017 suneny. All rights reserved.
//

#import "ERDashboardViewController.h"
#import "NYCmdTool.h"
#import "NYCocoaKit.h"
#import "ERDragTextField.h"
#import "ERContex.h"

@interface ERDashboardViewController () <NSComboBoxDelegate, NSComboBoxDataSource>

@property (weak) IBOutlet NSTextField *promptLabel;
@property (weak) IBOutlet NSProgressIndicator *loadingView;
@property (weak) IBOutlet ERDragTextField *inputIPAPathTextField;
@property (weak) IBOutlet NSComboBox *certListBox;
@property (weak) IBOutlet ERDragTextField *provisionProfileTextField;
@property (weak) IBOutlet ERDragTextField *bundleIDTextField;
@property (weak) IBOutlet ERDragTextField *appNameTextField;
@property (weak) IBOutlet ERDragTextField *appVersionTextField;
@property (weak) IBOutlet ERDragTextField *appBuildCodeTextField;


@property (nonatomic, copy) NSArray *certificates;

@end

@implementation ERDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setupUI];
    [self prepareForResign];
}

- (void)setupUI {
    self.promptLabel.editable = NO;
    self.promptLabel.stringValue = @"Welcome to Use EasyResigny！^0^~ --NY";
    [self.loadingView setHidden:YES];
    //self.resignButton.enabled = NO;]
    [self setupCertBox];
}

- (void)setupCertBox {
    self.certListBox.usesDataSource = YES;
    self.certListBox.dataSource = self;
    self.certListBox.delegate = self;
}

#pragma mark - Resign Process
- (void)prepareForResign {
    [self startLoading];
    self.promptLabel.stringValue = @"Preparing for Resign...";
    [NYCmdTool checkCommandLineTools];
    
    self.promptLabel.stringValue = @"Finding Certificates on this Mac...";
    __weak typeof(self) weakSelf = self;
    [NYCmdTool getCertifacationsCompletion:^(NSError *error, id object) {
        if (error) {
            [NYCocoaKit showErrorMessage:error.localizedDescription];
        } else {
            if ([object isKindOfClass:[NSArray class]]) {
                weakSelf.certificates = [(NSArray *)object mutableCopy];
                [weakSelf.certListBox reloadData];
                weakSelf.promptLabel.stringValue = @"Ready to Resign...";
            } else {
                weakSelf.promptLabel.stringValue = @"There is no certificates on this Mac";
            }
        }
        [weakSelf stopLoading];
    }];
    
}

- (IBAction)beginResignProcess:(id)sender {
    self.promptLabel.stringValue = @"Begin to Resign IPA...";
    NSLog(@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n",
          self.inputIPAPathTextField.stringValue,
          self.certListBox.stringValue,
          self.provisionProfileTextField.stringValue,
          self.bundleIDTextField.stringValue,
          self.appNameTextField.stringValue,
          self.appVersionTextField.stringValue,
          self.appBuildCodeTextField.stringValue);
    [self startLoading];
    
    [ERContex setIPAOriginPath:self.inputIPAPathTextField.stringValue];
    [ERContex setSelectCertificate:self.certListBox.stringValue];
    [ERContex setSelectProvisionProfilePath:self.provisionProfileTextField.stringValue];
    
    [ERContex setAppName:self.appNameTextField.stringValue];
    [ERContex setAppVersion:self.appVersionTextField.stringValue];
    [ERContex setAppBuildCode:self.appBuildCodeTextField.stringValue];
    
    __weak typeof(self) weakSelf = self;
    
    
    dispatch_semaphore_t semaphoreloadProvinsionProfilePlistWithPath = dispatch_semaphore_create(0);
    NYCmdToolCompletion loadProvisionCompletion = ^(NSError *error, NSDictionary *object) {
        NSLog(@"%@\n", object);
        
        [ERContex setProvisionPlist:object];
        [NYCmdTool saveEntitlements:[ERContex getEntitlements]
                           savedDir:[ERContex getWorkSpacePath]];
        
        weakSelf.promptLabel.stringValue = @"Entitlements has been generated";
        dispatch_semaphore_signal(semaphoreloadProvinsionProfilePlistWithPath);
    };
    self.promptLabel.stringValue = @"Start Loading Provision Profile...";
    
    [NYCmdTool loadProvinsionProfilePlistWithPath:[ERContex getSelectProvisionProfilePath]
                                       completion:loadProvisionCompletion];
    dispatch_semaphore_wait(semaphoreloadProvinsionProfilePlistWithPath, DISPATCH_TIME_FOREVER);
    
    
    dispatch_semaphore_t unzipAppWithIPAPath = dispatch_semaphore_create(0);
    [NYCmdTool unzipAppWithIPAPath:[ERContex getIPAOriginPath] workSpace:[ERContex getWorkSpacePath] completion:^(NSError *error, id object) {
        NSLog(@"%@", object);
        [ERContex setPayloadPath];
        dispatch_semaphore_signal(unzipAppWithIPAPath);
    }];
    dispatch_semaphore_wait(unzipAppWithIPAPath, DISPATCH_TIME_FOREVER);
    
    dispatch_group_t plistGroup = dispatch_group_create();
    dispatch_group_enter(plistGroup);
    [NYCmdTool launchReadTaskPath:[ERContex getInfoPlistPath] key:@"CFBundleExecutable" completion:^(NSError *error, id object) {
        dispatch_group_leave(plistGroup);
        [NYCmdTool launchChmodExecutable:object completion:nil];
    }];
    
    
    dispatch_group_enter(plistGroup);
    [NYCmdTool launchWriteTaskPlistPath:[ERContex getInfoPlistPath] key:@"CFBundleIdentifier" value:[ERContex getResignedAppBundleID] completion:^(NSError *error, id object) {
        dispatch_group_leave(plistGroup);
    }];
    
    dispatch_group_notify(plistGroup, dispatch_get_main_queue(), ^{
        NYCmdToolCompletion completion = ^(NSError *error, id object) {
            NSString *ipa = [[ERContex getIPAOriginPath] lastPathComponent];
            NSString *ipaReName = [ipa stringByReplacingOccurrencesOfString:@".ipa" withString:@""];
            ipaReName = [ipaReName stringByAppendingString:@"-resigny"];
            ipaReName = [ipaReName stringByAppendingPathExtension:@"ipa"];
            
            NSRange range = [[ERContex getIPAOriginPath] rangeOfString:ipa];
            NSString *des = [[ERContex getIPAOriginPath] substringToIndex:range.location];
            des = [des stringByAppendingPathComponent:ipaReName];
            
            [NYCmdTool launchZipCurrentPath:[ERContex getWorkSpacePath] destinationPath:des appPath:[ERContex getAppPath] completion:^(NSError *error, id object) {
                weakSelf.promptLabel.stringValue = [NSString stringWithFormat:@"Save IPA at %@", des];
                [weakSelf stopLoading];
            }];
        };
        
        [NYCmdTool launchCodesignCertificate:[ERContex getSelectCertificate]
                        entitlementsPlisPath:[ERContex getEntitlementsPath]
                                     appPath:[ERContex getAppPath] completion:completion];
    });
}


#pragma mark - NSComboBoxDataSource
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return self.certificates.count;
}

- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    id item = nil;
    if ([comboBox isKindOfClass:[NSComboBox class]]) {
        item = self.certificates[index];
    }
    return item;
}

#pragma mark - NSComboBoxDelegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    
}


#pragma mark - Helper
- (void)startLoading {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.loadingView startAnimation:weakSelf];
        [weakSelf.loadingView setHidden:NO];
    });
}

- (void)stopLoading {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.loadingView stopAnimation:weakSelf];
        [weakSelf.loadingView setHidden:YES];
    });
}

@end

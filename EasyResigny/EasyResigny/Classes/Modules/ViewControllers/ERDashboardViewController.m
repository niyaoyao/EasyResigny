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
#import "ERCodesignProcess.h"

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
@property (weak) IBOutlet NSButton *chooseIPAButton;
@property (weak) IBOutlet NSButton *chooseProvisionButton;
@property (weak) IBOutlet NSButton *startButton;


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
    [self disableButtons];
    [NYCmdTool launchFindCertificateIDsTaskCompletion: ^(NSError *error, id object) {
        if (error) {
            [NYCocoaKit showErrorMessage:error.localizedDescription];
        } else {
            if ([object isKindOfClass:[NSArray class]]) {
                weakSelf.certificates = [(NSArray *)object mutableCopy];
                [weakSelf.certListBox reloadData];
                weakSelf.promptLabel.stringValue = @"Start to Resign...";
            } else {
                weakSelf.promptLabel.stringValue = @"There is no certificates on this Mac";
            }
        }
        [weakSelf stopLoading];
        [weakSelf enableButtons];
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
    [self disableButtons];
    [ERCodesignProcess startLoadProvisionProfileCompletion:^(NSString *prompt) {
        weakSelf.bundleIDTextField.stringValue = prompt;
        NSLog(@"%@", prompt);
    } unzipIPACompletion:^(NSString *prompt) {
        weakSelf.promptLabel.stringValue = prompt;
        NSLog(@"%@", prompt);
    } getExecutableFileCompletion:^(NSString *prompt) {
        weakSelf.promptLabel.stringValue = prompt;
        NSLog(@"%@", prompt);
    } changeExeModeCompletion:^(NSString *prompt) {
        weakSelf.promptLabel.stringValue = prompt;
        NSLog(@"%@", prompt);
    } writeInfoPlistCompletion:^(NSString *prompt) {
        weakSelf.promptLabel.stringValue = prompt;
        NSLog(@"%@", prompt);
    } signCertificateCompletion:^(NSString *prompt) {
        weakSelf.promptLabel.stringValue = prompt;
        NSLog(@"%@", prompt);
    } saveIPACompletion:^(NSString *prompt) {
        NSLog(@"%@", prompt);
        [weakSelf stopLoading];
        weakSelf.inputIPAPathTextField.stringValue = @"";
        weakSelf.certListBox.stringValue = @"";
        weakSelf.provisionProfileTextField.stringValue = @"";
        weakSelf.bundleIDTextField.stringValue = @"";
        weakSelf.appNameTextField.stringValue = @"";
        weakSelf.appVersionTextField.stringValue = @"";
        weakSelf.appBuildCodeTextField.stringValue = @"";
        weakSelf.promptLabel.stringValue = prompt;
        [weakSelf enableButtons];
    }];
    
}

- (IBAction)browseFiles:(NSButton *)sender {
    NSString *title = [sender title];
    NSRange range = [title rangeOfString:@"IPA"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (range.location != NSNotFound) {
            [ERDashboardViewController browseFileAllowedFileTypes:@[@"ipa", @"IPA", @"xcarchive"]
                                                        textField:self.inputIPAPathTextField];
        } else {
            [ERDashboardViewController browseFileAllowedFileTypes:@[@"mobileprovision", @"MOBILEPROVISION"]
                                                        textField:self.provisionProfileTextField];
        }
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

#pragma mark - Helper

+ (void)browseFileAllowedFileTypes:(NSArray *)allowedFileTypes textField:(NSTextField *)textField {
    NSOpenPanel *openDialogue = [NSOpenPanel openPanel];
    
    [openDialogue setCanChooseFiles:TRUE];
    [openDialogue setCanChooseDirectories:FALSE];
    [openDialogue setAllowsMultipleSelection:FALSE];
    [openDialogue setAllowsOtherFileTypes:FALSE];
    [openDialogue setAllowedFileTypes:allowedFileTypes];
    
    if ([openDialogue runModal] == NSModalResponseOK) {
        NSString *fileName = [[[openDialogue URLs] objectAtIndex:0] path];
        [textField setStringValue:fileName];
    }

}

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

- (void)enableButtons {
    self.startButton.enabled = YES;
    self.chooseIPAButton.enabled = YES;
    self.chooseProvisionButton.enabled = YES;
}

- (void)disableButtons {
    self.startButton.enabled = NO;
    self.chooseIPAButton.enabled = NO;
    self.chooseProvisionButton.enabled = NO;
}

@end

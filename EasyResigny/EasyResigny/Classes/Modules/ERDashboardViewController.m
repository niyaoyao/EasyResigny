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

@interface ERDashboardViewController ()

@property (weak) IBOutlet NSTextField *promptLabel;
@property (weak) IBOutlet NSButton *resignButton;
@property (weak) IBOutlet NSProgressIndicator *loadingView;
@property (weak) IBOutlet NSTextField *inputIPAPath;

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
    [self.loadingView setAlphaValue:0];
    //self.resignButton.enabled = NO;
}

#pragma mark - Resign Process
- (void)prepareForResign {
    [self startLoading];
    self.promptLabel.stringValue = @"Preparing for Resign...";
    [NYCmdTool checkCommandLineTools];
    self.promptLabel.stringValue = @"Ready to Resign...";
    [self stopLoading];
}


- (IBAction)beginResignProcess:(id)sender {
    self.promptLabel.stringValue = @"Begin to Resign IPA...";
    [self startLoading];
}


#pragma mark - Helper
- (void)startLoading {
    [self.loadingView setHidden:NO];
    [self.loadingView startAnimation:self];
}

- (void)stopLoading {
    [self.loadingView stopAnimation:self];
    [self.loadingView setHidden:YES];
}

@end

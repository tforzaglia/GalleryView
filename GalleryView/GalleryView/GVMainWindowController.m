//
//  GVMainWindowController.m
//  GalleryView
//
//  Created by Thomas Forzaglia on 6/30/16.
//  Copyright © 2016 Thomas Forzaglia. All rights reserved.
//

#import "GVMainViewController.h"
#import "GVMainWindowController.h"

@interface GVMainWindowController ()

@property (nonatomic, weak) IBOutlet NSView *mainView;
@property (nonatomic, weak) IBOutlet GVMainViewController *mainViewController;

@end

@implementation GVMainWindowController

- (id)init {
    self = [super initWithWindowNibName:@"GVMainWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.mainView addSubview:self.mainViewController.view];
}

@end

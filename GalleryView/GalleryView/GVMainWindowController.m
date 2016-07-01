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

@end

@implementation GVMainWindowController

- (id)init {
    self = [super initWithWindowNibName:@"GVMainWindow"];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    GVMainViewController *mainViewController = [[GVMainViewController alloc] init];
    [self.mainView addSubview:mainViewController.view];
}

@end

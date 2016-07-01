//
//  GVAppDelegate.m
//  GalleryView
//
//  Created by Thomas Forzaglia on 6/30/16.
//  Copyright © 2016 Thomas Forzaglia. All rights reserved.
//

#import "GVAppDelegate.h"
#import "GVMainWindowController.h"

@interface GVAppDelegate ()

@property (nonatomic, strong) GVMainWindowController *mainWindow;

@end

@implementation GVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.window close];
    self.mainWindow = [[GVMainWindowController alloc] init];
    self.window = self.mainWindow.window;
}

@end

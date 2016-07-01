//
//  GVMainViewController.m
//  GalleryView
//
//  Created by Thomas Forzaglia on 6/30/16.
//  Copyright © 2016 Thomas Forzaglia. All rights reserved.
//

#import "GVMainViewController.h"

@interface GVMainViewController ()

- (IBAction)openImageDirectory:(id)sender;
- (IBAction)openImageInPreview:(id)sender;

@property (weak) IBOutlet NSButton *openDirectoryButton;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *fileCol;
@property (weak) IBOutlet NSImageView *imageView;

@property (nonatomic, strong) NSArray *imageFilenameArray;
@property (nonatomic, strong) NSString *directoryPath;

@end

@implementation GVMainViewController

- (void)awakeFromNib {
    [self.tableView setTarget:self];
    [self.tableView setAction:@selector(showImageInWell:)];
    [self.tableView setDoubleAction:@selector(openImageInPreview:)];
}

- (id)init {
    return [super initWithNibName:@"GVMainView" bundle:[NSBundle bundleForClass:[self class]]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithNibName:@"GVMainView" bundle:[NSBundle bundleForClass:[self class]]];
}

- (IBAction)openImageDirectory:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            self.directoryPath = [[panel URL] path];
            self.imageFilenameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:nil];
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (IBAction)openImageInPreview:(id)sender {
    NSInteger clickedRow = [self.tableView clickedRow];
    NSString *filename = self.imageFilenameArray[clickedRow];
    [[NSWorkspace sharedWorkspace] openFile:[NSString stringWithFormat:@"%@/%@", self.directoryPath, filename]];
}

- (IBAction)showImageInWell:(id)sender {
    NSInteger clickedRow = [self.tableView clickedRow];
    NSString *filename = self.imageFilenameArray[clickedRow];
    [self.imageView setImage:[[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.directoryPath, filename]]];
    
}

#pragma mark NSTableViewDataSource Protocol Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv {
    NSInteger count = 0;
    if (self.imageFilenameArray) {
        count = [self.imageFilenameArray count];
    }
    return count;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableColumn == self.fileCol) {
        NSString *filename = [self.imageFilenameArray objectAtIndex:row];
        return filename;
    } else {
        return @"";
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    NSString *filename = self.imageFilenameArray[row];
    [self.imageView setImage:[[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", self.directoryPath, filename]]];
    return YES;
}

@end

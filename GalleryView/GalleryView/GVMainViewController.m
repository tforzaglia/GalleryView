//
//  GVMainViewController.m
//  GalleryView
//
//  Created by Thomas Forzaglia on 6/30/16.
//  Copyright © 2016 Thomas Forzaglia. All rights reserved.
//

#include <stdlib.h>

#import "GVImageFile.h"
#import "GVMainViewController.h"

@interface GVMainViewController ()

- (IBAction)openImageDirectory:(id)sender;
- (IBAction)openImageInPreview:(id)sender;
- (IBAction)selectRandomImage:(id)sender;

@property (weak) IBOutlet NSButton *openDirectoryButton;
@property (weak) IBOutlet NSButton *randomImageButton;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTableColumn *fileCol;
@property (weak) IBOutlet NSTableColumn *tagCol;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSPopUpButton *tagFilter;
@property (weak) IBOutlet NSButton *enableFilterCheckbox;
@property (weak) IBOutlet NSTokenField *tagTokenField;

@property (nonatomic, strong) NSArray *imageFileObjects;
@property (nonatomic, strong) NSArray *filteredImageFileObjects;
@property (nonatomic, strong) NSSet *allTags;
@property (nonatomic, strong) NSSet *currentlySelectedTags;

@property (nonatomic, strong) NSString *directoryPath;

@property (nonatomic) BOOL filterEnabled;

@end

@implementation GVMainViewController

#pragma mark Initialization Methods

- (void)awakeFromNib {
    [self.tableView setTarget:self];
    [self.tableView setAction:@selector(showImageInWell:)];
    [self.tableView setDoubleAction:@selector(openImageInPreview:)];
    
    self.allTags = [[NSSet alloc] init];
    self.currentlySelectedTags = [[NSSet alloc] init];
    self.filteredImageFileObjects = [[NSArray alloc] init];
    self.filterEnabled = NO;
    [self setWidgetsEnabled:NO];
}

- (id)init {
    return [super initWithNibName:@"GVMainView" bundle:[NSBundle bundleForClass:[self class]]];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithNibName:@"GVMainView" bundle:[NSBundle bundleForClass:[self class]]];
}

#pragma  mark IBAction Methods

- (IBAction)openImageDirectory:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            self.directoryPath = [[panel URL] path];
            self.imageFileObjects = [self buildImageFileArray];
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [self setWidgetsEnabled:YES];
        }
    }];
}

- (IBAction)openImageInPreview:(id)sender {
    NSInteger clickedRow = [self.tableView clickedRow];
    [self openImageAtRow:clickedRow];
}

- (IBAction)showImageInWell:(id)sender {
    GVImageFile *imageFile = [self currentDataSourceArray][[self.tableView clickedRow]];
    [self showImageThumbnail:imageFile];
}

- (IBAction)filterImages:(id)sender {
    NSString *tag = [[self.tagFilter selectedItem] title];
    self.currentlySelectedTags = [self.currentlySelectedTags setByAddingObject:tag];
    [self.tagTokenField setObjectValue:[self.currentlySelectedTags allObjects]];
    [self buildFilteredImages];
}

- (IBAction)enableFilter:(id)sender {
    [self handleFilterEnabling];
}

- (IBAction)selectRandomImage:(id)sender {
    NSNumber *count  = [NSNumber numberWithUnsignedInteger:[[self currentDataSourceArray] count]];
    int randomIndex = arc4random_uniform([count unsignedIntValue]);
    GVImageFile *randomImage = [self currentDataSourceArray][randomIndex];
    [self showImageThumbnail:randomImage];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:randomIndex];
    [self.tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:randomIndex];
}

#pragma mark Private Methods

- (void)openImageAtRow:(NSInteger)row {
    GVImageFile *imageFile = [self currentDataSourceArray][row];
    [[NSWorkspace sharedWorkspace] openFile:[self fullFilePath:imageFile]];
}

- (NSArray *)buildImageFileArray {
    NSMutableArray *mutableFileObjectArray = [NSMutableArray array];
    for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:nil]) {
        GVImageFile *imageFile = [GVImageFile new];
        imageFile.filename = filename;
        
        NSArray *tags = [NSArray array];
        NSURL *fileUrl = [NSURL fileURLWithPath:[self fullFilePath:imageFile]];
        [fileUrl getResourceValue:&tags forKey:NSURLTagNamesKey error:nil];
        imageFile.tags = tags;
        self.allTags = [self.allTags setByAddingObjectsFromArray:tags];
        
        [mutableFileObjectArray addObject:imageFile];
    }
    NSArray *allTagsArray = [self.allTags allObjects];
    NSArray *sortedArray = [allTagsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [self.tagFilter addItemsWithTitles:sortedArray];
    
    return mutableFileObjectArray;
}

- (NSString *)fullFilePath:(GVImageFile *)imageFile {
    return [NSString stringWithFormat:@"%@/%@", self.directoryPath, imageFile.filename];
}

- (NSArray *)currentDataSourceArray {
    return (self.filterEnabled) ? self.filteredImageFileObjects : self.imageFileObjects;
}

- (void)handleFilterEnabling {
    if ([self.tableView selectedRow] <= [[self currentDataSourceArray] count]) {
        GVImageFile *imageFile = [self currentDataSourceArray][[self.tableView selectedRow]];
        [self showImageThumbnail:imageFile];
    }
    self.filterEnabled = (self.enableFilterCheckbox.state == 1) ? YES :  NO;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)showImageThumbnail:(GVImageFile *)imageFile {
    [self.imageView setImage:[[NSImage alloc] initWithContentsOfFile:[self fullFilePath:imageFile]]];
}

- (void)setWidgetsEnabled:(BOOL)enabled {
    self.tagFilter.enabled = enabled;
    self.enableFilterCheckbox.enabled = enabled;
    self.randomImageButton.enabled = enabled;
    self.tagTokenField.enabled = enabled;
}

- (void)buildFilteredImages {
    NSMutableArray *mutableFilteredImageObjects = [NSMutableArray array];
    for (GVImageFile *imageFile in self.imageFileObjects) {
        for (NSString *setTag in self.currentlySelectedTags) {
            if ([imageFile.tags containsObject:setTag]) {
                [mutableFilteredImageObjects addObject:imageFile];
            }
        }
    }
    self.filteredImageFileObjects = mutableFilteredImageObjects;
    [self.enableFilterCheckbox setState:NSOnState];
    [self handleFilterEnabling];
}

#pragma mark NSTableViewDataSource Protocol Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv {
    return [[self currentDataSourceArray] count];
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    GVImageFile *imageFile = [self currentDataSourceArray][row];
    if (tableColumn == self.fileCol) {
        return imageFile.filename;
    } else if (tableColumn == self.tagCol) {
        return [imageFile.tags componentsJoinedByString:@" | "];
    } else {
        return @"";
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    GVImageFile *imageFile = [self currentDataSourceArray][row];
    [self.imageView setImage:[[NSImage alloc] initWithContentsOfFile:[self fullFilePath:imageFile]]];
    return YES;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    [self openImageAtRow:row];
    return YES;
}

#pragma mark NSControl Delegate Protocol Methods

- (void)controlTextDidChange:(NSNotification *)obj {
    self.currentlySelectedTags = [NSSet setWithArray:[self.tagTokenField objectValue]];
    [self buildFilteredImages];
}

@end

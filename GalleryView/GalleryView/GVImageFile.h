//
//  GVImageFile.h
//  GalleryView
//
//  Created by Thomas Forzaglia on 7/2/16.
//  Copyright © 2016 Thomas Forzaglia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVImageFile : NSObject

@property (nonatomic, copy, nonnull) NSString *filename;
@property (nonatomic, strong, nonnull) NSArray *tags;
@property (nonatomic, strong, nonnull) NSDate *createdDate;
@property (nonatomic, strong, nonnull) NSDate *modifiedDate;

@end

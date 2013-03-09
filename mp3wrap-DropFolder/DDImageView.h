//
//  DMImageView.h
//  mp3wrap-DropFolder
//
//  Created by Dominik Pich on 03.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//
#import <AppKit/AppKit.h>

@class DDImageView;

@protocol DDImageViewDelegate
- (BOOL)imageView:(DDImageView*)imageView didReceiveDrop:(NSArray*)files;
@end

@interface DDImageView : NSImageView

@property(nonatomic,/*weak fails*/ unsafe_unretained) IBOutlet id<DDImageViewDelegate> delegate;
@property(nonatomic, strong) NSArray *quickLookFilePaths;

@end

@interface NSImage (DDImagePathView)

+ (NSImage*)imageWithPreviewAtPath:(NSString*)path ofSize:(NSSize)size;
- initWithCGImage:(CGImageRef)cgImage;

@end
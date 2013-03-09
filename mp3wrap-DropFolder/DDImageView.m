//
//  DDImageView.m
//  mp3wrap-DropFolder
//
//  Created by Dominik Pich on 03.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//
#import "DDImageView.h"
#import <QuickLook/QuickLook.h>

@implementation DDImageView

#pragma mark drag and drop of files to delegate

- (void)awakeFromNib {
	[self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (NSDragOperation)draggingEntered:(id )sender {
    return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id )sender {
	return YES;
}

- (BOOL)performDragOperation:(id )sender {
	NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *zFiles = [zPasteboard propertyListForType:NSFilenamesPboardType];
	return [_delegate imageView:self didReceiveDrop:zFiles];
}

- (void)setImage:(NSImage *)newImage {
	self.quickLookFilePaths = nil;
	[super setImage:newImage];
}

- (void) setQuickLookFilePaths:(NSArray *)quickLookFilePaths {
	if(_quickLookFilePaths == quickLookFilePaths) {
		return;
    }
    
    _quickLookFilePaths = nil;

    //calculate previews for paths and draw compound image
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSImage *compoundImage = nil;
        NSUInteger filesCount = quickLookFilePaths.count;
        switch (filesCount) {
            case 0:
            {
                //no paths, no image
                break;
            }
            case 1:
            {
                //1 path, draw image inside it
                compoundImage = [NSImage imageWithPreviewAtPath:quickLookFilePaths[0]
                                                         ofSize:NSMakeSize(compoundImage.size.height,compoundImage.size.height)];
                break;
            }
            default:
            {
                compoundImage = [[NSImage alloc] initWithSize:self.frame.size];
                
                //n paths draw images cascaded
                [compoundImage lockFocus];
                CGFloat distance = compoundImage.size.height*0.2;
                CGFloat imageSize = compoundImage.size.height*0.8;
                CGFloat xOffset = 0;
                
                for (int i = 0; i < filesCount ; i++) {
                    NSImage * ql = [NSImage imageWithPreviewAtPath:quickLookFilePaths[i]
                                                            ofSize:NSMakeSize(imageSize, imageSize)];
                    
                    xOffset += ql.size.width / 2.0;
                    
                    [ql drawAtPoint:NSMakePoint(distance+xOffset, distance) fromRect:NSMakeRect(0, 0, imageSize, imageSize) operation:NSCompositeSourceOver fraction:1.0];
                }
                
                [compoundImage unlockFocus];
                break;
            }
        }
        
        //set prepared image
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setImage:compoundImage];
            _quickLookFilePaths = quickLookFilePaths;
        });
    });
}

@end

@implementation NSImage (DDImagePathView)

+ (NSImage*)imageWithPreviewAtPath:(NSString*)path ofSize:(NSSize)size
{
	NSURL *fileURL = [NSURL fileURLWithPath:path];
	if (!path || !fileURL) {
		return nil;
	}
    
	NSDictionary *dict = @{(NSString*)kQLThumbnailOptionIconModeKey: @YES};
	CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, 
											(__bridge CFURLRef)fileURL, 
											CGSizeMake(size.width, size.height),
											(__bridge CFDictionaryRef)dict);
    
	if (ref != NULL) {
		NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
		NSImage *newImage = nil;
		if (bitmapImageRep) {
			newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
			[newImage addRepresentation:bitmapImageRep];
			
			if (newImage) {
                CFRelease(ref);
				return newImage;
			}
		}
		CFRelease(ref);
	} else {
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
		if (icon) {
			[icon setSize:size];
		}
		return icon;
	}
    
	return nil;
}

- (id)initWithCGImage:(CGImageRef)cgImage {
    if (cgImage) {
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:cgImage];
        if (bitmapImageRep) {
            self = [self initWithSize:[bitmapImageRep size]];
            [self addRepresentation:bitmapImageRep];
            return self;
        }
    }
    return nil;
}

@end

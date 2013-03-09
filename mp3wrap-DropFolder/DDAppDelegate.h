//
//  DDAppDelegate.h
//  mp3wrap-DropFolder
//
//  Created by Dominik Pich on 03.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDImageView.h"
#import "TaskWrapper.h"

@interface DDAppDelegate : NSObject <NSApplicationDelegate, DDImageViewDelegate, TaskWrapperDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *sheet;
@property (assign) IBOutlet DDImageView *imageView;
@property (assign) IBOutlet NSTextField *folderName;
@property (assign) IBOutlet NSTextField *fileName;

@property (strong) NSArray *mp3s;
@property (strong) NSArray *jpgs;

- (IBAction)open:(id)sender;
- (IBAction)chooseOutputFolder:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)process:(id)sender;

@end

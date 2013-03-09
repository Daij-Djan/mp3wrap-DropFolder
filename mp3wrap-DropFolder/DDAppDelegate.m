//
//  DDAppDelegate.m
//  mp3wrap-DropFolder
//
//  Created by Dominik Pich on 03.03.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDAppDelegate.h"

@implementation DDAppDelegate {
    TaskWrapper *_wrapper;
    NSMutableData *_taskData;
}

- (IBAction)open:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = YES;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if(result==NSFileHandlingPanelOKButton && panel.URLs.count)
            [self imageView:self.imageView didReceiveDrop:[panel.URLs valueForKeyPath:@"path"]];
    }];
}

- (IBAction)chooseOutputFolder:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if(result==NSFileHandlingPanelOKButton && panel.URLs.count)
            [self.folderName setStringValue:[panel.URLs[0] path]];
    }];
}

- (IBAction)cancel:(id)sender {
    self.folderName.stringValue = @"";
    self.fileName.stringValue = @"";
    self.imageView.quickLookFilePaths = nil;
    self.mp3s = nil;
}

- (IBAction)process:(id)sender {
    [self runTask];
}

- (NSString*)outputFilename {
    NSString *filename = [[self.folderName.stringValue stringByAppendingPathComponent:self.fileName.stringValue] stringByAppendingPathExtension:@"mp3"];
    return filename;
}


#pragma mark - NSApplicationDelegate

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    return [self imageView:self.imageView didReceiveDrop:@[filename]];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    [self imageView:self.imageView didReceiveDrop:filenames];
}

#pragma mark - DDImageViewDelegate

- (BOOL)imageView:(DDImageView *)imageView didReceiveDrop:(NSArray *)files {
    if(!files.count) {
        [self cancel:nil];
        return NO;
    }
   
    self.folderName.stringValue = [files[0] stringByDeletingLastPathComponent];
    self.fileName.stringValue = [[files[0] lastPathComponent] stringByDeletingPathExtension];

    NSMutableArray *inMp3s = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *inFile in files) {
        BOOL isDir = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:inFile isDirectory:&isDir] && isDir) {
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inFile error:nil];
            for (NSString *child in contents) {
                if([child.pathExtension isEqualToString:@"mp3"])
                    [inMp3s addObject:[inFile stringByAppendingPathComponent:child]];
            }
        }
        else {
            if([inFile.pathExtension isEqualToString:@"mp3"])
                [inMp3s addObject:inFile];
        }
    }

    self.mp3s = inMp3s;
    self.imageView.quickLookFilePaths = inMp3s;

    return YES;
}

#pragma mark - NSTask handling

- (void)runTask {
    assert(_wrapper == nil);
    assert(_taskData == nil);

    _wrapper = [[TaskWrapper alloc] initWithCommandPath:self.toolLaunchPath
                                              arguments:self.toolArguments
                                            environment:nil
                                               delegate:self];
    
    _taskData = [NSMutableData data];
    [_wrapper startTask];
}

/*! Called before the task is launched. */
- (void)taskWrapperWillStartTask:(TaskWrapper *)taskWrapper {
    //show overlay
    [NSApp beginSheet:self.sheet modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [self.sheet makeKeyAndOrderFront:self];
}

/*! Called when output arrives from the task, from either stdout or stderr. */
- (void)taskWrapper:(TaskWrapper *)taskWrapper didProduceOutput:(NSData *)outputData {
    [_taskData appendData:outputData];
}

- (void)taskWrapper:(TaskWrapper *)taskWrapper didFinishTaskWithStatus:(NSInteger)terminationStatus {
    [_taskData writeToFile:self.outputFilename atomically:NO];
    _taskData = nil;
    _wrapper = nil;
 
    [self cancel:self];
    
    //hide overlay
    [NSApp endSheet:self.sheet];
    [self.sheet orderOut:self];
}
- (NSString*)toolLaunchPath {
    return @"/bin/cat";
}

- (NSArray*)toolArguments {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.mp3s.count + 1];

    for (NSString *inFilename in self.mp3s) {
        if([[NSFileManager defaultManager] isReadableFileAtPath:inFilename]) {
            [array addObject:inFilename];
        }
    }

    return array;
}

@end
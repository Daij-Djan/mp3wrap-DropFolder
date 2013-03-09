// Based on Apple's "Moriarity" sample code at
// <http://developer.apple.com/library/mac/#samplecode/Moriarity/Introduction/Intro.html>
// See the accompanying LICENSE.txt for Apple's original terms of use.

#import <Foundation/Foundation.h>
#import "TaskWrapperDelegate.h"

/*!
 * Wrapper around NSTask, with a delegate that provides hooks to various
 * points in the lifetime of the task. Evolved from the TaskWrapper class
 * in Apple's Moriarity sample code.
 *
 * There is a delegate method to receive output from the task's stdout
 * and stderr, but no way to interactively send input via stdin.
 *
 * TaskWrapper objects are one-shot, like NSTask. If you need to run
 * a task more than once, create new TaskWrapper instances.
 */
@interface TaskWrapper : NSObject

@property (readonly) id <TaskWrapperDelegate> taskDelegate;
@property (readonly) NSString *commandPath;
@property (readonly) NSArray *commandArguments;
@property (readonly) NSDictionary *environment;

/*!
 * commandPath is the path to the executable to launch. env contains environment variables
 * you want the command to run with. env can be nil.
 */
- (id)initWithCommandPath:(NSString *)commandPath
				arguments:(NSArray *)args
			  environment:(NSDictionary *)env
				 delegate:(id <TaskWrapperDelegate>)aDelegate;

- (void)startTask;

- (void)stopTask;

@end

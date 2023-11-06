//
//  pong.m
//  pong
//
//  Created by Matt Hartley on 06/11/2023.
//  Copyright 2023 GiantJelly. All rights reserved.
//

#import "pong.h"

#import <Cocoa/Cocoa.h>
//#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>

#include <math.h>

int quit = 0;

@interface WindowDelegate: NSObject
@end

@implementation WindowDelegate
	- (void) windowWillClose: (id) sender {
		// close;
		printf("close \n");
		quit = 1;
	}
@end

int main() {
	printf("Hello Pong \n");
	printf("Awesome \n");
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSApplicationLoad();
	
	WindowDelegate* window_delegate = [[WindowDelegate alloc] init];
	NSRect screen_rect = [[NSScreen mainScreen] frame];
	NSRect window_rect = NSMakeRect(100, 100, 800, 600);
	
	NSWindow* window = [[NSWindow alloc]
		initWithContentRect: window_rect
		styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
		backing: NSBackingStoreBuffered
		defer: NO
	];
	
	[window setBackgroundColor: [NSColor redColor]];
	[window setTitle: @"Pong"];
	[window makeKeyAndOrderFront: nil];
	[window setDelegate: window_delegate];
	
	int* back_buffer = malloc(4 * 800 * 600);
//	int i;
	for (int i=0; i<800*600; ++i) {
		char* rgba = back_buffer + i;
		rgba[0] = ((float)rand() / RAND_MAX) * 255.0f;
		rgba[1] = 0;
		rgba[2] = 0;
		rgba[3] = 255;
	}
	
	CVPixelBufferRef cvbuffer;
	CVPixelBufferCreate(kCFAllocatorDefault, 800, 600, *(uint32_t*)"RGBA", NULL, &cvbuffer);
	
	
	while (!quit) {
		NSEvent* event;
		do {
			event = [NSApp
				nextEventMatchingMask: NSAnyEventMask
				untilDate: nil
				inMode: NSDefaultRunLoopMode
				dequeue: YES
			];
			if (event) {
				switch ([event type]) {
				case NSKeyDown:
					printf("key down \n");
					break;
				default:
					printf("default \n");
				}
				[NSApp sendEvent: event];
			}
		} while (event);
	}
	
	[pool release];
	return 0;
}
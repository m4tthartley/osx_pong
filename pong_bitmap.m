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
//#import <Cocoa/CALayer.h>

#include <math.h>
#include <unistd.h>

int quit = 0;

@interface WindowDelegate: NSObject @end

@implementation WindowDelegate
	- (void) windowWillClose: (id) sender {
		// close;
		printf("close \n");
		quit = 1;
	}
@end

NSWindow* window;
CVPixelBufferRef cvbuffer;

void* get_byte_pointer(void* info) {
	return info;
}

void release_byte_pointer(void* info, void* pointer) {
	free(info);
}

void quartz_init() {
//	[window contentView] = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 800, 600)];
	NSView* view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 800, 600)];
//	window->contentView.wantsLayer = YES;
//	[view setAutoresizesSubviews:<#(BOOL)flag#>
	[window setContentView: view];
	
	CVPixelBufferCreate(kCFAllocatorDefault, 800, 600, *(uint32_t*)"RGBA", NULL, &cvbuffer);
}

float x = 0.0f;
//void quartz_render() {
//	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//	
//	CGContextSetRGBFillColor(context, 0, 1, 0, 1);
//	CGContextFillRect(context, CGRectMake(x, 0, 100, 100));
//	
//	CIImage* image = [CIImage imageWithCVPixelBuffer: cvbuffer];
//	CGRect bounds = [image extent];
//	[image drawInRect: NSMakeRect(0, 0, 800, 600), fromRect: bounds operation: MSCompositeCopy fraction:1.0];
//	
////	CGContextFlush(context);
//	
//	x += 0.01f;
//}

//@interface SoftwareCALayer: CALayer @end
//
//@implementation SoftwareCALayer
//	- (instancetype) init {
//		self = [super init];
//	}
//@end

int* back_buffer;
CGImageRef render_image;

@interface SoftwareView: NSView
	CGContextRef context;
@end

@implementation SoftwareView
	- (void) drawRect: (NSRect) dirtyRect {
//		printf("draw rect \n");
		if (render_image) {
			CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
			CGRect bounds = CGRectMake(0, 0, 800, 600);
			CGContextDrawImage(context, bounds, render_image);
			//[NSGraphicsContext set]
		} else {
			printf("no render image \n");
		}
	}
	
	- (void) init_pixel_buffer {
		back_buffer = malloc(4 * 800 * 600);
		for (int i=0; i<800*600; ++i) {
			char* rgba = (char*)(back_buffer + i);
			rgba[0] = 0;//((float)rand() / RAND_MAX) * 255.0f;
			rgba[1] = 255;
			rgba[2] = 0;
			rgba[3] = 255;
		}
		
		CGColorSpaceRef color_space = CGColorSpaceCreateDeviceRGB();
		context = CGBitmapContextCreate(back_buffer, 800, 600, 8, 4*800, color_space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//		[NSGraphicsContext setCurrentContext: context];
	}
	
	- (void) render_pixel_buffer {
//		NSWindow* window = [self window];
	
//		printf("render_pixel_buffer \n");
		
		int* pixels = CGBitmapContextGetData(context);
		for (int i=0; i<800*600; ++i) {
			char* rgba = (char*)(pixels + i);
			rgba[0] = ((float)rand() / RAND_MAX) * 255.0f;
			rgba[1] = 0;
			rgba[2] = 0;
			rgba[3] = 255;
		}
		
		CGContextSetRGBFillColor(context, 0, 1, 1, 1);
		CGContextFillRect(context, CGRectMake(100+x, 100, 100, 100));
		
		if (render_image) CGImageRelease(render_image);
		render_image = CGBitmapContextCreateImage(context);
		
//		CGContextRelease(context);
//		CGColorSpaceRelease(color_space);
		
//		[self setNeedsDisplay: YES];
		
		x += 1.0f;
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
	
	window = [[NSWindow alloc]
		initWithContentRect: window_rect
		styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
		backing: NSBackingStoreNonretained
		defer: NO
	];
	
	[window setBackgroundColor: [NSColor redColor]];
	[window setTitle: @"Pong"];
	[window makeKeyAndOrderFront: nil];
	[window setDelegate: window_delegate];
//	window.contentView.wantsLayer = YES;
	SoftwareView* view = [[SoftwareView alloc] initWithFrame: [window frame]];

	[window setContentView:view];
	//[[window contentView] addSubview: view];
//	[view release];
	
//	quartz_init();
	[view init_pixel_buffer];
	
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
		
//		NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
//			initWithBitmapDataPlanes: &back_buffer
//			pixelsWide: 800
//			pixelsHigh: 600
//			bitsPerSample: 8
//			samplesPerPixel: 4
//			hasAlpha: YES
//			isPlanar: NO
//			colorSpaceName: NSDeviceRGBColorSpace
//			bytesPerRow: 800*4
//			bitsPerPixel: 8*4
//		];

//		quartz_render();
//		sleep(1);
		[view render_pixel_buffer];
		[view drawRect: [window frame]];
//		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
//		CGRect bounds = CGRectMake(0, 0, 800, 600);
//		CGContextDrawImage(context, bounds, render_image);

//		[view setNeedsDisplay: YES];
		//[window display];
		
//		[window flushWindow];
//		[window setNeedsDisplay: YES];
	}
	
	[pool release];
	return 0;
}
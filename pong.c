/*
 *  pong.c
 *  pong
 *
 *  Created by Matt Hartley on 05/11/2023.
 *  Copyright 2023 __MyCompanyName__. All rights reserved.
 *
 */

#include <ApplicationServices/ApplicationServices.h>
#include <Carbon/Carbon.h>
#include <OpenGL/CGLTypes.h>
#include <OpenGL/CGLCurrent.h>
#include <stdio.h>

#include "pong.h"

typedef int CGSConnectionID;
typedef int CGSConnection;
typedef int CGSWindow;
typedef void* CGSRegion;

int kCGSOrderAbove = 1;
int kCGSBufferedBackingType = 2;

int main() {
	printf("Hello Pong \n");
	
	// I think this is pure Carbon?
#if 0
	Rect window_rect = {50, 50, 400, 400};
	WindowRef window = NewCWindow(NULL, &window_rect, "Pong Window", true, plainDBox, (WindowRef)-1L, true, 0);
	SetPortWindowPort(window);
	
	EventRecord event;
	for (;;) {
		if (WaitNextEvent(everyEvent, &event, 0, NULL)) {
			if (event.what == keyDown) {
				exit(0);
			}
		}
	}
#endif

	CGSConnectionID connection_id = CGSMainConnectionID();
	CGRect rect = CGRectMake(0, 0, 800, 600);
	CGSRegion region = NULL;
	CGSNewRegionWithRect(&rect, &region);
	CGSWindow window = 0;
	CGSNewWindow(connection_id, kCGSBufferedBackingType, 200, 200, region, &window);
	CGSOrderWindow(connection_id, window, kCGSOrderAbove, 0);
	
	for (;;) {
		EventTargetRef event_target = GetEventDispatcherTarget();
		EventRef carbon_event_ref;
		while (ReceiveNextEvent(0, NULL, kEventDurationNoWait, true, &carbon_event_ref) == noErr) {
			// Not sure this function exists in this version of OSX
			CGEventRef event = CopyEventCGEvent(carbon_event_ref);
			CGEventType event_type = CGEventGetType(event);
			switch (event_type) {
				case kCGEventKeyDown:
					printf("key down \n");
				break;
			}
		}
	}
}

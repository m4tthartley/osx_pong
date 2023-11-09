//
//  pong_opengl.m
//  pong
//
//  Created by Matt Hartley on 09/11/2023.
//  Copyright 2023 GiantJelly. All rights reserved.
//

#import "pong.h"

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>

//#include <math.h>
//#include <unistd.h>
//#include <stdlib.h>

#define max(a, b) (a>=b ? a : b)

int quit = 0;

@interface WindowDelegate: NSObject @end
@implementation WindowDelegate
	- (void) windowWillClose: (id) sender {
		// close;
		printf("close \n");
		quit = 1;
	}
	
	- (void) mouseMoved: (NSEvent*) event {
		printf("mouse moved \n");
	}
	
	- (void) windowDidMove: (NSNotification *) notification {
		printf("window moved \n");
	}
@end

@interface CustomWindow: NSWindow @end
@implementation CustomWindow
	- (void) mouseMoved: (NSEvent*) event {
		printf("mouse moved \n");
	}
@end

@interface CustomOpenGLView: NSOpenGLView @end
@implementation CustomOpenGLView
	- (BOOL) acceptsFirstResponder {
		return YES;
	}
@end

#define fb_width 320
#define fb_height 240
int fb_size = fb_width*fb_height;
//int aligned_fb_width = fb_width;
//int aligned_fb_height = fb_height;

CustomWindow* window;
uint32_t* framebuffer;

int ilog2(int num) {
	if (num < 2) {
		return 0;
	}
	int result = 0;
	while (num > 1) {
		num >>= 1;
		++result;
	}
	return result;
}

#if 0
// Awesome weird gradient
char drawing = 0;
char drawing2 = 0;
void render() {
	for (int y=0; y<fb_height; ++y) {
		for (int x=0; x<fb_width; ++x) {
			char* rgba = (char*)(framebuffer + x*y);
			//int random = ((float)rand() / RAND_MAX) * 255.0f;
			rgba[0] = 0;
			rgba[1] = drawing;
			rgba[2] = drawing2;
			rgba[3] = 255;
			
			++drawing;
		}
		drawing2 += 1;
	}
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, fb_width, fb_height, GL_RGBA, GL_UNSIGNED_BYTE, framebuffer);
}
#endif

#if 0
char drawing = 0;
char drawing2 = 0;
void render() {
	for (int y=0; y<fb_height; ++y) {
		for (int x=0; x<fb_width; ++x) {
			char* rgba = (char*)(framebuffer + (y*fb_width+x));
			//int random = ((float)rand() / RAND_MAX) * 255.0f;
			rgba[0] = 0;
			rgba[1] = drawing;
			rgba[2] = drawing2;
			rgba[3] = 255;
			
			++drawing;
		}
		drawing2 += 1;
	}
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, fb_width, fb_height, GL_RGBA, GL_UNSIGNED_BYTE, framebuffer);
}
#endif

void draw_rect(int posx, int posy, int width, int height, int color) {
	for (int y=posy; y<posy+height; ++y) {
		for (int x=posx; x<posx+width; ++x) {
			uint32_t* pixel = (framebuffer + (y*fb_width+x));
			//int random = ((float)rand() / RAND_MAX) * 255.0f;
			//rgba[0] = 0;
//			rgba[1] = drawing;
//			rgba[2] = drawing2;
//			rgba[3] = 255;
			*pixel = color;
		}
	}
}

typedef struct {
	float x;
	float y;
	float width;
	float height;
} rect_t;

typedef struct {
	float x;
	float y;
} vec2_t;

typedef struct {
	rect_t pos;
	int controlled;
} player_t;

typedef struct {
	rect_t pos;
	vec2_t speed;
} ball_t;

#define margin 10
#define player_width 5
#define player_height 20

player_t player1 = {
	{margin, 100, player_width, player_height},
	1
};

player_t player2 = {
	{fb_width-player_width-margin, 100, player_width, player_height},
	0
};

ball_t ball = {
	{100, 100, 5, 5},
	{1, 1}
};

int rect_intersection(rect_t* a, rect_t* b, rect_t* overlap) {
	float left = b->x - (a->x+a->width);
	float right = a->x - (b->x+b->width);
	float bottom = b->y - (a->y+a->height);
	float top = a->y - (b->y+b->height);
	
	if (left<0.0f && right<0.0f && bottom<0.0f && top<0.0f) {
		*overlap = (rect_t){left, bottom, right, top};
		return 1;
	}
	return 0;
}

void player_update(player_t* player) {
	if (player->controlled) {
		NSPoint mouse = [NSEvent mouseLocation];
		//player->pos.x = mouse.x;
		player->pos.y = mouse.y;
	} else {
		if (ball.pos.y+2 < player->pos.y+(player_height/2)) {
			//player2_dir = -1;
			player->pos.y -= 1;
		}
		if (ball.pos.y+2 > player->pos.y+(player_height/2)) {
			//player2_dir = 1;
			player->pos.y += 1;
		}
	}
	
	if (player->pos.y < 0 + margin) {
		player->pos.y = margin;
	}
	if (player->pos.y > fb_height-player_height - margin) {
		player->pos.y = fb_height-player_height - margin;
	}
	
	draw_rect(player->pos.x, player->pos.y, player->pos.width, player->pos.height, 0xFFFFFFFF);
}

void ball_update(ball_t* ball) {
	ball->pos.x += ball->speed.x;
	ball->pos.y += ball->speed.y;
	
	if (ball->pos.x < 0) {
		ball->pos.x = 0;
		ball->speed.x *= -1;
	}
	if (ball->pos.x > fb_width-5) {
		ball->pos.x = fb_width-5;
		ball->speed.x *= -1;
	}
	if (ball->pos.y < 0) {
		ball->pos.y = 0;
		ball->speed.y *= -1;
	}
	if (ball->pos.y > fb_height-5) {
		ball->pos.y = fb_height-5;
		ball->speed.y *= -1;
	}
	
	draw_rect(ball->pos.x, ball->pos.y, 5, 5, 0xFFFFFFFF);
}

void ball_interact_with_player(ball_t* ball, player_t* player) {
	//if (ball->pos.x+ball->pos.width > player->pos.x &&
//		bally < player2y+player_height &&
//		bally+5 > player2y) {
//		ballx = fb_width-player_width-10 - 5;
//		ballvx = -1;
//	}
	rect_t overlap;
	if (rect_intersection(&ball->pos, &player->pos, &overlap)) {
		//ball->speed.x = -ball->speed.x;
		float hor = max(overlap.x, overlap.width);
		float ver = max(overlap.y, overlap.height);
		float side = max(hor, ver);
		
		if (side == overlap.x) {
			float edge = -ver / (player->pos.height/1);
			float angle = 1.0f - edge;
			if (ver == overlap.y) {
				ball->speed.y = -angle*2;
				ball->speed.x = -1 - angle;
			} else {
				ball->speed.y = angle*2;
				ball->speed.x = -1 - angle;
			}
		}
		if (side == overlap.width) {
			float edge = -ver / (player->pos.height/1);
			float angle = 1.0f - edge;
			if (ver == overlap.y) {
				ball->speed.y = -angle*2;
				ball->speed.x = 1 - angle;
			} else {
				ball->speed.y = angle*2;
				ball->speed.x = 1 - angle;
			}
		}
		if (side == overlap.y) {
			ball->speed.y = -1;
		}
		if (side == overlap.height) {
			ball->speed.y = 1;
		}
	}
}

//float player1y = 100;
//float player2y = 100;
//float player2_dir = 1;
//float ballx = 100;
//float bally = 100;
//float ballvx = 1;
//float ballvy = 1;
void render() {
//	NSPoint mouse = [NSEvent mouseLocation];
//	NSRect frame = [[window contentView] frame];
	
	//printf("%f %f \n", mouse.x, mouse.y);

	draw_rect(0, 0, fb_width, fb_height, 0x000000FF);

//	draw_rect(10, player1y, player_width, player_height, 0xFFFFFFFF);
//	draw_rect(fb_width-player_width-10, player2y, player_width, player_height, 0xFFFFFFFF);
	
	player_update(&player1);
	player_update(&player2);

	ball_update(&ball);
	ball_interact_with_player(&ball, &player1);
	ball_interact_with_player(&ball, &player2);
	
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, fb_width, fb_height, GL_RGBA, GL_UNSIGNED_BYTE, framebuffer);
}

int main() {
	printf("Hello Pong \n");
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSApplicationLoad();
	
	WindowDelegate* window_delegate = [[WindowDelegate alloc] init];
	NSRect screen_rect = [[NSScreen mainScreen] frame];
	NSRect window_rect = NSMakeRect(100, 100, 800, 600);
	
	window = [[CustomWindow alloc]
		initWithContentRect: window_rect
		styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask
		backing: NSBackingStoreBuffered // Is this right?
		defer: NO
	];
	
//	[window setBackgroundColor: [NSColor redColor]];
	[window setTitle: @"Pong"];
	[window makeKeyAndOrderFront: nil];
	[window setDelegate: window_delegate];
	[window makeFirstResponder: window];
	[window setAcceptsMouseMovedEvents: YES];

	NSOpenGLPixelFormatAttribute glattributes[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADepthSize, 24,
		//NSOpenGLPFAFullScreen,
		//NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion,
		0,
	};
	NSOpenGLPixelFormat* pixel_format = [[NSOpenGLPixelFormat alloc] initWithAttributes: glattributes];
	NSOpenGLContext* glcontext = [[NSOpenGLContext alloc] initWithFormat: pixel_format shareContext:NULL];
	
	CustomOpenGLView* view = [[CustomOpenGLView alloc] init];
	//[view setAutoresizingMask:
	[view setPixelFormat: pixel_format];
	[view setOpenGLContext: glcontext];
	NSView* content_view = [window contentView];
	[view setFrame: [content_view bounds]];
	//[content_view addSubview: view];
//	[window setContentView: view];
	[pixel_format release];
	[glcontext setView: content_view];
	//[glcontext setFullScreen];
	[glcontext makeCurrentContext];
	//[window setContentView:view];
	long swap_interval = 0;
	[glcontext setValues: &swap_interval forParameter: NSOpenGLCPSwapInterval];
	
	printf("%s \n", glGetString(GL_VERSION));
	
	int aligned_fb_width = 0x1 << (ilog2(fb_width)+1);
	int aligned_fb_height = 0x1 << (ilog2(fb_height)+1);
	
	framebuffer = malloc(4 * fb_size);
	GLuint framebuffer_texture;
	glGenTextures(1, &framebuffer_texture);
	glBindTexture(GL_TEXTURE_2D, framebuffer_texture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, aligned_fb_width, aligned_fb_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	render();
	GLenum err = glGetError();
	if (err != GL_NO_ERROR) {
		printf("opengl error: probably invalid texture size \n");
	}
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	float x = 0;
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
					player1.pos.y -= 1;
					break;
				default:
					printf("default: %i \n", [event type]);
				}
				[NSApp sendEvent: event];
			}
		} while (event);
		
			//glClearColor(1.0f, 0.0f, 1.0f, 1.0f);
//			glClear(GL_COLOR_BUFFER_BIT);
//			
//			glLoadIdentity();
//			glOrtho(0, 800, 0, 600, -1, 1);
//			
//			glTranslatef(100 + x, 100, 0);
//			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
//			glBegin(GL_QUADS);
//			glVertex2f(-5, -5);
//			glVertex2f( 5, -5);
//			glVertex2f( 5,  5);
//			glVertex2f(-5,  5);
//			glEnd();
//			x += 1;

//		glClearColor(1.0f, 0.0f, 1.0f, 1.0f);
//		glClear(GL_COLOR_BUFFER_BIT);

		render();

		float fb_texcoord_x = (float)fb_width / (float)aligned_fb_width;
		float fb_texcoord_y = (float)fb_height / (float)aligned_fb_height;
		glEnable(GL_TEXTURE_2D);
		glBegin(GL_QUADS);
		glTexCoord2f(0.0f, 0.0f);                   glVertex2f(-1, -1);
		glTexCoord2f(fb_texcoord_x, 0.0f);          glVertex2f( 1, -1);
		glTexCoord2f(fb_texcoord_x, fb_texcoord_y); glVertex2f( 1,  1);
		glTexCoord2f(0.0f, fb_texcoord_y);          glVertex2f(-1,  1);
		glEnd();
		
		[glcontext flushBuffer];
		//glFlush();
	}
	
	[pool release];
	return 0;
}

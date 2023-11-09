#!/bin/sh

# build.sh
# pong
#
# Created by Matt Hartley on 05/11/2023.
# Copyright 2023 __MyCompanyName__. All rights reserved.

gcc pong_opengl.m -o build/pong -g -framework cocoa -framework Foundation -framework CoreVideo -framework OpenGL -std=c99

if [ $? -eq 0 ]; then
	./build/pong
fi

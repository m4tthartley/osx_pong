#!/bin/sh

# build.sh
# pong
#
# Created by Matt Hartley on 05/11/2023.
# Copyright 2023 __MyCompanyName__. All rights reserved.

gcc pong.m -o build/pong -g -framework cocoa -framework Foundation -framework CoreVideo -std=c99

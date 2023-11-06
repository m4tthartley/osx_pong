#!/bin/sh

# package.sh
# pong
#
# Created by Matt Hartley on 06/11/2023.
# Copyright 2023 GiantJelly. All rights reserved.

mkdir -p build/pong.app
mkdir -p build/pong.app/Contents
mkdir -p build/pong.app/Contents/MacOS
mkdir -p build/pong.app/Contents/Resources

#cp Info.plist build/pong.app/Contents/Info.plist
cp build/pong build/pong.app/Contents/MacOS/pong


cat << EOF >> build/pong.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>pong</string>
	<key>CFBundleIconFile</key>
	<string>AppIconFile</string>
	<key>CFBundleIdentifier</key>
	<string>GiantJellyPong</string>
</dict>
</plist>
EOF

#printf $PLIST > build/pong.app/Contents/Info.plist

#!/bin/bash

# check for pkg-config and brew, if needed and possible
if [ 'x' == $(which pkg-config)'x' ]; then
	if [ 'x' == $(which brew)'x' ]; then
		echo "Must install pkg-config first, but Homebrew is not installed, please follow instructions on https://github.com/p2/Redland-ObjC"
		exit 1
	fi
	
	echo "Installing pkg-config"
	brew install pkg-config
fi

# cross compile
python cross-compile.py

exit $?

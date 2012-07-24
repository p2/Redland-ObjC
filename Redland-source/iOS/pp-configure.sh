#!/bin/bash

#
#	This script runs the GNU Autotools created "./configure" script in order to
#	cross compile C libraries for iOS.
#
#	Easiest is to place this script in your $PATH, e.g. /usr/local/bin, and run
#	"ios-configure -armv6 -armv7" instead of "./configure". Afterwards, just run
#	"make" and "sudo make install". By default, the libraries will be installed
#	into "/usr/local/ios-x.x"
#
#	This script has last been tested with Xcode 4.5-DP3 on OS X 10.8 GM
#

export SDKVER="6.0"

#ARMV6='-arch armv6'
ARMV7='-arch armv7'

if [[ 'x' = ${ARMV6}x && 'x' = ${ARMV7}x ]]; then
	echo "You must specify at least one of armv6 and armv7"
	exit 1
fi

# extract PREFIX
confopts=()
while [ $# -gt 0 ] ; do
	case ${1:0:9} in
		--prefix=)	PREFIX=${1:9};				shift 1;;
		*)			confopts+=("$1");			shift 1;;
	esac
done

if [[ 'x' = ${PREFIX}x ]]; then
	PREFIX="/usr/local/ios-$SDKVER"
fi
export PREFIX

# clean up
unset CPATH
unset C_INCLUDE_PATH
unset CPLUS_INCLUDE_PATH
unset OBJC_INCLUDE_PATH
unset LIBS
unset DYLD_FALLBACK_LIBRARY_PATH
unset DYLD_FALLBACK_FRAMEWORK_PATH

# determine SDK-root
export BUILD_DARWIN_VER=`uname -r`
export XCODE="$(xcode-select --print-path)"
export DEVROOT="$XCODE/Platforms/iPhoneOS.platform/Developer"

if [ ! -d "$DEVROOT" ]; then
	echo "There is no iOS SDK at \"$DEVROOT\""
	exit 1
fi

export SDKROOT="$DEVROOT/SDKs/iPhoneOS$SDKVER.sdk"

if [ ! -d "$SDKROOT" ] ; then
	echo "The iPhone SDK could not be found. Folder \"$SDKROOT\" does not exist."
	exit 1
fi

# pkg-config
#export PKG_CONFIG="$SDKROOT/usr/lib/pkgconfig"
export PKG_CONFIG_PATH="$SDKROOT/usr/lib/pkgconfig:$DEVROOT/usr/lib/pkgconfig:$PREFIX/lib/pkgconfig"
#export PKG_CONFIG_LIBDIR="$PKG_CONFIG"

# set flags
export CFLAGS="-std=c99 $ARMV6 $ARMV7 -pipe --sysroot='$SDKROOT' -isystem '$SDKROOT/usr/include' -isystem '$DEVROOT/usr/include' -isystem $PREFIX/include"
export CPPFLAGS="-pipe -I$SDKROOT/usr/include -I$DEVROOT/usr/include -I$PREFIX/include"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="$ARMV6 $ARMV7 -isysroot=$SDKROOT -L$SDKROOT/usr/lib/system -L$SDKROOT/usr/lib -L$DEVROOT/usr/lib -L$PREFIX/lib"

# set paths
export CC="$DEVROOT/usr/bin/cc"
unset CPP					# configure uses "$CC -E" if CPP is not set, which is needed for many configure scripts. So, DON'T set CPP
#export CPP="$DEVROOT/usr/bin/c++"
#export CXX="$CPP"
#export CXXCPP="$CPP"
export LD="$DEVROOT/usr/bin/ld"
export STRIP="$DEVROOT/usr/bin/strip"
export AS="$DEVROOT/usr/bin/as"
export ASCPP="$AS"
export AR="$DEVROOT/usr/bin/ar"
export RANLIB="$DEVROOT/usr/bin/ranlib"

# run ./configure
./configure --prefix="$PREFIX" --build="i386-apple-darwin$BUILD_DARWIN_VER" --host="arm-apple-darwin" --enable-static --disable-shared ac_cv_file__dev_zero=no ac_cv_func_setpgrp_void=yes ${confopts[@]}
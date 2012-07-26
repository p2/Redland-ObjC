#!/bin/bash

#
#	This script runs the GNU Autotools created "./configure" script in order to
#	cross compile C libraries for iOS.
#
#	Easiest is to place this script in your $PATH, e.g. /usr/local/bin, and run
#	"ios-configure -arch armv7" instead of "./configure". You can also specify
#	your own prefix with --prefix=/usr/mybuild. By default, the libraries will
#	be installed into "/usr/local/ios-x.x"
#	Afterwards, just run "make" and "sudo make install". 
#
#	If you want fat libraries, you'll need to run this script for all archs
#	you want to build for and then use `lipo` to combine the static libs. Some
#	libraries may compile just fine if you specify multiple archs.
#
#	This script has last been tested with Xcode 4.5-DP3 on OS X 10.8 GM
#

export SDKVER="6.0"
export IPHONEOS_DEPLOYMENT_TARGET="4.0"

# extract ARCH and PREFIX
archs=()
confopts=()
while [ $# -gt 0 ]; do
	case ${1:0:9} in
		-arch)		archs+=("-arch $2");		shift 2;;
		--prefix=)	PREFIX=${1:9};				shift 1;;
		*)			confopts+=("$1");			shift 1;;
	esac
done

ARCH=${archs[@]}
if [[ 'x' = ${ARCH}x ]]; then
	ARCH="-arch armv7"
fi

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
	echo "The iPhone SDK could not be found. Directory \"$SDKROOT\" does not exist."
	exit 1
fi

# pkg-config
#export PKG_CONFIG="$SDKROOT/usr/lib/pkgconfig"
export PKG_CONFIG_PATH="$SDKROOT/usr/lib/pkgconfig:$DEVROOT/usr/lib/pkgconfig:$PREFIX/lib/pkgconfig"
#export PKG_CONFIG_LIBDIR="$PKG_CONFIG"

# set flags
export CFLAGS="-std=c99 $ARCH -pipe --sysroot='$SDKROOT' -isysroot '$SDKROOT' -I$SDKROOT/usr/include -I$DEVROOT/usr/include -I$PREFIX/include"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="--sysroot='$SDKROOT' -isysroot='$SDKROOT' -L$SDKROOT/usr/lib/system -L$SDKROOT/usr/lib -L$DEVROOT/usr/lib -L$PREFIX/lib"

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
./configure --prefix="$PREFIX" --build="x86_64-apple-darwin$BUILD_DARWIN_VER" --host="arm-apple-darwin" --enable-static --disable-shared ac_cv_file__dev_zero=no ac_cv_func_setpgrp_void=yes ${confopts[@]}
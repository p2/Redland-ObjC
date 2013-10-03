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
#	This script has last been tested with Xcode 4.4 and 4.5-DP4 on OS X 10.8
#

export IPHONEOS_DEPLOYMENT_TARGET="5.0"

# extract command line arguments
archs=()
confopts=()
while [ $# -gt 0 ]; do
	case ${1:0:9} in
		-sdk)		SDKVER=$2;					shift 2;;
		-arch)		archs+=("-arch $2");		shift 2;;
		-platform)	PLATFORM_NAME=$2;			shift 2;;
		--prefix=)	PREFIX=${1:9};				shift 1;;
		*)			confopts+=("$1");			shift 1;;
	esac
done

ARCH=${archs[@]}
if [[ 'x' = ${ARCH}x ]]; then
	ARCH="-arch armv7"
fi

if [[ 'x' = ${PLATFORM_NAME}x ]]; then
	PLATFORM_NAME='iPhoneOS'
fi

# clean up
unset CPATH
unset C_INCLUDE_PATH
unset CPLUS_INCLUDE_PATH
unset OBJC_INCLUDE_PATH
unset LIBS
unset DYLD_FALLBACK_LIBRARY_PATH
unset DYLD_FALLBACK_FRAMEWORK_PATH

# determine Dev-Root
export HOST_DARWIN_VER=$(uname -r)
export HOST_ARCH=$(uname -m)
if [[ 'x' != ${DEVELOPER_DIR}x ]]; then
	export XCODE=$DEVELOPER_DIR
else
	export XCODE="$(xcode-select --print-path)"
fi
export DEVROOT="${XCODE}/Platforms/${PLATFORM_NAME}.platform/Developer"

if [ ! -d "$DEVROOT" ]; then
	echo "There is no SDK at \"$DEVROOT\""
	exit 1
fi

# determine SDK-root and -version
if [[ 'x' = ${SDKVER}x ]]; then
	LATEST=$(ls -1r "$DEVROOT/SDKs/" | head -1)
	export SDKROOT="${DEVROOT}/SDKs/$LATEST"
	SDKVER='x.x'
else
	export SDKROOT="${DEVROOT}/SDKs/${PLATFORM_NAME}${SDKVER}.sdk"
fi

if [ ! -d "$SDKROOT" ] ; then
	echo "The SDK could not be found. Directory \"$SDKROOT\" does not exist."
	exit 1
fi

if [[ 'x' = ${PREFIX}x ]]; then
	PREFIX="/usr/local/ios-$SDKVER"
fi
export PREFIX

# pkg-config
#export PKG_CONFIG="$SDKROOT/usr/lib/pkgconfig"
export PKG_CONFIG_PATH="${SDKROOT}/usr/lib/pkgconfig:${DEVROOT}/usr/lib/pkgconfig:${PREFIX}/lib/pkgconfig"
#export PKG_CONFIG_LIBDIR="$PKG_CONFIG"

# set flags
export CFLAGS="-std=c99 $ARCH -pipe --sysroot=$SDKROOT -isysroot $SDKROOT -I${SDKROOT}/usr/include -I${DEVROOT}/usr/include -I${PREFIX}/include"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="--sysroot=$SDKROOT -isysroot $SDKROOT -L${SDKROOT}/usr/lib/system -L${SDKROOT}/usr/lib -L${PREFIX}/lib"

# set paths
export CC=/usr/bin/gcc		# used to be "${DEVROOT}/usr/bin/gcc", but Xcode 5 no longer bundles gcc for iPhoneOS.platform
unset CPP					# configure uses "$CC -E" if CPP is not set, which is needed for many configure scripts. So, DON'T set CPP
#export CPP="${DEVROOT}/usr/bin/c++"
#export CXX="$CPP"
#export CXXCPP="$CPP"

# compilation works for me without setting the following paths
#export LD="${DEVROOT}/usr/bin/ld"
#export STRIP="${DEVROOT}/usr/bin/strip"
#export AS="${DEVROOT}/usr/bin/as"
#export ASCPP="$AS"
#export AR="${DEVROOT}/usr/bin/ar"
#export RANLIB="${DEVROOT}/usr/bin/ranlib"

# run ./configure
./configure --prefix="$PREFIX" --build="${HOST_ARCH}-apple-darwin${HOST_DARWIN_VER}" --host="${HOST_ARCH}-apple-darwin" --enable-static --disable-shared ac_cv_file__dev_zero=no ac_cv_func_setpgrp_void=yes ${confopts[@]}

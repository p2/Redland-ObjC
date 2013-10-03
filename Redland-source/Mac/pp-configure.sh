#!/bin/bash

export MACOSX_DEPLOYMENT_TARGET="10.6"

# extract ARCH and PREFIX
archs=()
confopts=()
while [ $# -gt 0 ]; do
	case ${1:0:9} in
		-sdk)		echo 'Ignoring SDK';		shift 2;;
		-arch)		archs+=("-arch $2");		shift 2;;
		--prefix=)	PREFIX=${1:9};				shift 1;;
		*)			confopts+=("$1");			shift 1;;
	esac
done

ARCH=${archs[@]}

if [[ 'x' = ${PREFIX}x ]]; then
	PREFIX=/usr/local
fi
export PREFIX

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig"

export CFLAGS="-std=c99 $ARCH -pipe -I$PREFIX/include"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"

export LDFLAGS="$ARCH -L$PREFIX/lib"

./configure --prefix="$PREFIX" ${confopts[@]}

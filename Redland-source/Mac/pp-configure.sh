#!/bin/bash

confopts=()
while [ $# -gt 0 ] ; do
	case ${1:0:9} in
		--prefix=)	PREFIX=${1:9};				shift 1;;
		*)			confopts+=("$1");			shift 1;;
	esac
done

if [[ 'x' = ${PREFIX}x ]]; then
	PREFIX=/usr/local
fi
export PREFIX

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

# seems to not like multiple arches?
#export CFLAGS="-std=c99 -arch i386 -arch x86_64 -isystem $PREFIX/include"
export CFLAGS="-std=c99 -pipe -isystem $PREFIX/include"
export CPPFLAGS="-pipe -I$PREFIX/include"
export CXXFLAGS="$CFLAGS"

export LDFLAGS="-L$PREFIX/lib"

./configure --prefix="$PREFIX" --enable-static --disable-shared ${confopts[@]}
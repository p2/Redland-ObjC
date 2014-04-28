##
##	Configuration file for the cross-compile.py script for Redland
##

SOURCES = [
	# 'http://xmlsoft.org/sources/libxml2-2.9.1.tar.gz',
	'http://download.librdf.org/source/raptor2-2.0.10.tar.gz',
	'http://download.librdf.org/source/rasqal-0.9.30.tar.gz',
	'http://download.librdf.org/source/redland-1.0.16.tar.gz',
]

ARCHS = {
	'iOS': ['armv7', 'armv7s', 'arm64'],
	#'Sim': ['i386', 'x86_64'],		disable as we can just use the "Mac" build these days
	'Mac': ['i386', 'x86_64']
}

FLAGS = {
	'raptor2-2.0.10': {
		'*': ['--with-www=none'],
	},
	'redland-1.0.16': {
		'*': ['--disable-modular', '--without-mysql', '--without-postgresql', '--without-virtuoso', '--without-bdb'],
	},
}

MAKE_UNIVERSAL = ['libraptor2', 'librasqal', 'librdf']

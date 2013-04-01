##
##	Configuration file for the cross-compile.py script for Redland
##

SOURCES = [
	'ftp://xmlsoft.org/libxml2/libxml2-sources-2.7.8.tar.gz',
	'http://download.librdf.org/source/raptor2-2.0.9.tar.gz',
	'http://download.librdf.org/source/rasqal-0.9.30.tar.gz',
	'http://download.librdf.org/source/redland-1.0.16.tar.gz',
]

ARCHS = {
	'iOS': ['armv7', 'armv7s'],
	'Sim': ['i386'],
	'Mac': ['i386', 'x86_64']
}

FLAGS = {
	'raptor2-2.0.9': {
		'*': ['--with-www=none'],
	},
	'redland-1.0.16': {
		'*': ['--disable-modular', '--without-mysql', '--without-postgresql', '--without-virtuoso', '--without-bdb'],
	},
}

FIX_DEP_LIBS = {
	'iOS': {
		'raptor2-2.0.8': {
			'libraptor2.la': ('/usr/lib/libxml2.la', '-lxml2')		# SDK 6.0 does this correctly, but not 5.1
		},
	},
	'Sim': {
		'raptor2-2.0.8': {
			'libraptor2.la': ('/usr/lib/libxml2.la', '-lxml2')
		},
	},
}

MAKE_UNIVERSAL = ['libraptor2', 'librasqal', 'librdf']

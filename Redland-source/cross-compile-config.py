##
##	Configuration file for the cross-compile.py script for Redland
##

SOURCES = [
	# 'http://xmlsoft.org/sources/libxml2-2.9.1.tar.gz',
	'http://download.librdf.org/source/raptor2-2.0.13.tar.gz',
	'http://download.librdf.org/source/rasqal-0.9.32.tar.gz',
	'http://download.librdf.org/source/redland-1.0.17.tar.gz',
]

ARCHS = {
	'iOS': ['armv7', 'armv7s', 'arm64'],
	'Sim': ['i386', 'x86_64'],
	'Mac': ['i386', 'x86_64']
}

FLAGS = {
	'raptor2-2.0.13': {
		'*': ['--with-www=none'],
	},
	'rasqal-0.9.32': {
		'*': ['--with-decimal=none'],	# strangely configure picks up a mpfr from somewhere for OS X/Sim builds...
	},
	'redland-1.0.17': {
		'*': ['--disable-modular', '--with-sqlite=3', '--without-mysql', '--without-postgresql', '--without-virtuoso', '--without-bdb'],
	},
}

MAKE_UNIVERSAL = ['libraptor2', 'librasqal', 'librdf']

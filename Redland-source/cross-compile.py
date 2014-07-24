#!/usr/bin/env python
#
#	This script downloads and cross-compiles C-sources prepared with GNU
#	Autoconf for the configured platforms on a Mac with Xcode installed.
#
#	It is configured to cross-compile the Redland RDF libraries but can be re-
#	purposed to cross-compile any C-source. Use 'iOS', 'Sim' and 'Mac' as
#	platform identifiers.
#

import os
import sys
import shutil
import urllib2
import tarfile
import subprocess
import re
import fileinput

##
##	Configure. Create your own file 'cross-compile-config.py' to override these
##

# URLs to the sources' tar.gz files
#
# format:
#	['http://domain.com/dl/file.tar.gz']
SOURCES = []

# target architectures per platform
# format:
#	ARCHS{ platform: [ arch, ... ]}
ARCHS = {}

# Configuration flags per project per platform and/or architecture.
# This is a dictionary with the target directory as the first key and either
# '*' or the platform or the architecture (or a mix thereof) as second level
#
# format:
#	FLAGS{ 'module name': { 'platform or *': [ '--flag', ... ]}}
FLAGS = {}

# libtool sometimes doesn't play nice and puts the wrong file paths into its
# "dependency_libs" setting in .la files. We can fix this here by regex wizardry,
# "search-expr" and "replacement-expr" will be fed into re.sub().
#
# format:
#	FIX_DEP_LIBS{ 'platform': { 'module name': { 'file.la': ('search-expr', 'replacement-expr') }}}
FIX_DEP_LIBS = {}

# libraries that should be glued into a universal library. You need to know
# the built library names (w/o extension).
#
# format:
#	['library.a', 'cool.a']
MAKE_UNIVERSAL = []

# where to put the universal libraries and downloads
UNIVERSAL = 'Universal'
DOWNLOAD = 'downloads'

# SDK-version to use (e.g. 5.1 for iOS SDK 5.1). Can be 'None'
SDK_VERSION = None

# desired library extensions
# format:
#	LIBEXT{ platform: extension }
LIBEXT = {'iOS': 'a', 'Sim': 'a', 'Mac': 'dylib'}

# name of custom configure scripts. If such a file is present it is copied to
# the target directory and used instead of "./configure" (so don't name it
# "configure"!
CONFIG_NAME = 'pp-configure.sh'

# link our platform shortnames to the SDK directory names used by Xcode
PLATFORM_NAMES = {'iOS': 'iPhoneOS', 'Sim': 'iPhoneSimulator'}

# used to keep track of the current building dir
CURRENTLY_BUILDING = None

# ok, import overrides from the config file
execfile('cross-compile-config.py')


##
##	main function
##
def main():
	abspath = os.path.abspath(__file__)
	if ' ' in abspath:
		print shell_color("x>  Your working directory contains spaces, I can not cross compile.", 'red', True)
		sys.exit(1)
	
	os.chdir(os.path.split(abspath)[0])
	
	# collect all needed directories
	dirs = [DOWNLOAD, UNIVERSAL]
	for platform in ARCHS.keys():
		dirs.append('%s-%s' % (UNIVERSAL, platform))
		archs = ARCHS[platform]
		for arch in archs:
			dirs.append('build-%s-%s' % (platform, arch))
			dirs.append('product-%s-%s' % (platform, arch))
	create_directories(dirs)
	
	platform_libs = {}
	
	# loop all sources
	if len(SOURCES) > 0:
		for url in SOURCES:
			print shell_color('->  %s' % os.path.basename(url), 'magenta')
			src = download(url, DOWNLOAD)
			if src is None:
				_compile_failed(None, "Failed to download %s" % url)
				sys.exit(1)
			
			# unpack and build
			for platform in ARCHS.keys():
				archs = ARCHS[platform]
				for arch in archs:
					print shell_color('-->  %s: %s' % (platform, arch), 'green')
					build_dir = 'build-%s-%s' % (platform, arch)
					product_dir = 'product-%s-%s' % (platform, arch)
					
					# compile and install
					directory, do_compile = unpack_into(src, build_dir)
					if do_compile:
						compile_and_install(directory, product_dir, platform, arch, FLAGS)
					
					# remember platform/lib directory
					pf = platform_libs[platform] if platform in platform_libs else []
					product_lib = '%s/lib' % product_dir
					if product_lib not in pf:
						pf.append(product_lib)
						platform_libs[platform] = pf
	else:
		_compile_failed(None, 'No sources are configured (SOURCES is empty)')
		sys.exit(1)
	
	# use lipo to create fat libraries
	if len(MAKE_UNIVERSAL) > 0:
		print shell_color('->  Creating universal libraries', 'magenta')
		for lib_base in MAKE_UNIVERSAL:
			
			# per platform
			for platform in platform_libs:
				lib_ext = LIBEXT[platform] if platform in LIBEXT else 'a'
				lib = '%s.%s' % (lib_base, lib_ext)
				
				target = '%s-%s/%s' % (UNIVERSAL, platform, lib)
				pf = platform_libs[platform]
				libs = [foo + '/%s' % lib for foo in pf]
				if len(libs) > 1:
					p = subprocess.call('lipo -create -output %s %s' % (target, ' '.join(libs)), shell=True)
					if 0 != p:
						print shell_color('xx>  lipo failed to create the universal library for %s (%s)' % (platform, lib), 'red', True)
						#sys.exit(1)
				elif len(libs) > 0 and os.path.exists(libs[0]):
					shutil.copy2(libs[0], target)
			
			# iOS and Simulator universal
			lib = '%s.a' % lib_base
			p = subprocess.call('lipo -create -output %s/%s product-iOS-*/lib/%s product-Mac-*/lib/%s' % (UNIVERSAL, lib, lib, lib), shell=True)
			if 0 != p:
				print shell_color('xx>  lipo failed to create the uber-universal library for %s' % lib, 'red', True)
				#sys.exit(1)
	
	# set install names
	# install_name_tool -id @loader_path/Frameworks/librdf.dylib librdf.dylib


##
##	functions
##
def download(url, directory=None, filename=None, force=False, nostatus=False):
	"""Downloads a URL to a file with the same name, unless overridden
	
	Returns the path to the file downloaded
	
	Will NOT download the file if it exists at target directory and filename,
	unless force is True
	"""
	
	# can we write te the directory?
	if directory is None:
		abspath = os.path.abspath(__file__)
		directory = os.path.dirname(abspath)

	if not os.access(directory, os.W_OK):
		raise Exception("Can't write to %s" % directory)
	
	if filename is None:
		filename = os.path.basename(url)
	
	# if it already exists, we're not going to do anything
	path = os.path.join(directory, filename)
	if os.path.exists(path):
		if force:
			os.remove(path)
		else:
			print "-->  %s has already been downloaded" % filename
			return path
	
	# create url and file handles
	try:
		urlhandle = urllib2.urlopen(url)
	except Exception as e:
		return None
	filehandle = open(path, 'wb')
	meta = urlhandle.info()
	
	# start
	contentlen = meta.getheaders("Content-Length")
	filesize = int(contentlen[0]) if contentlen else None
	print "-->  Downloading %s (%s KB)" % (filename, filesize / 1000 if filesize else "??")
	if filesize is None:
		nostatus = True
	
	loaded = 0
	blocksize = 8192
	while True:
		buffer = urlhandle.read(blocksize)
		if not buffer:
			break
		
		loaded += len(buffer)
		filehandle.write(buffer)
		
		if not nostatus:
			status = r"%10d	 [%3.2f%%]" % (loaded, loaded * 100.0 / filesize)
			status = status + chr(8) * (len(status) + 1)
			print status,
	
	if not nostatus:
		print
	
	# return filename
	filehandle.close()
	return path


def unpack_into(archive, directory):
	"""Unarchives a gzipped tar into the given subdirectories.
	
	Will NOT unpack the archive if there already is a directory with the same
	base name.
	
	Returns a tuple with the unpacked directory name as first and a bool
	indicating whether the archive was freshly extracted or not as second
	member.
	"""
	
	newly_unpacked = False
	
	# unpack
	tar = tarfile.open(archive)
	base = tar.getnames()[0]
	target_dir = os.path.join(directory, base)
	if os.access(target_dir, os.F_OK):
		print "--->  %s already exists, skipping" % target_dir
	else:
		print "--->  Unpacking %s" % archive
		tar.extractall(directory)
		newly_unpacked = True
	
	# close and remember directory name
	tar.close()
	
	return (target_dir, newly_unpacked)


def compile_and_install(source, target, platform, arch, flag_mapping):
	"""Compiles the given source directories into the mapped target directories.
	
	- source directory must be configure/make/make install-able
	- target is the directory where the products will be installed
	- platform directory is searched for 'CONFIG_NAME' files and patches with
	  the same name as the source directory plus ".patch"
	- arch is the architecture to build for
	- flag_mapping may contain additional flags that will be applied when
	  configuring
	"""
	
	global CURRENTLY_BUILDING
	CURRENTLY_BUILDING = os.path.abspath(source)
	current_dir = os.getcwd()
	
	parent, module_name = os.path.split(source)
	abs_prefix = os.path.abspath(target)
	
	# apply patches and find the config script
	config_script = None
	for filename in os.listdir(platform):
		if len(filename) > 6 and '.patch' == filename[-6:]:
			apply_patch(os.path.join(platform, filename), source)
		elif CONFIG_NAME == filename:
			config_script = os.path.join(platform, filename)
	
	# copy the config script to the source dir, if we have a script
	has_conf = False
	if os.path.isfile(config_script):
		try:
			shutil.copy2(config_script, os.path.join(source, CONFIG_NAME))
			has_conf = True
		except OSError:
			pass
	
	# prepare to configure
	config_name = './%s' % CONFIG_NAME if has_conf else './configure'
	config = [config_name, '-arch', arch, '--prefix=%s' % abs_prefix]
	if has_conf and SDK_VERSION:
		config.extend(['-sdk', SDK_VERSION])
	if has_conf and platform in PLATFORM_NAMES:
		config.extend(['-platform', PLATFORM_NAMES[platform]])
	
	# find additional flags
	poss_flags = flag_mapping[module_name] if module_name in flag_mapping else None
	if poss_flags and '*' in poss_flags:
		config.extend(poss_flags['*'])
	if poss_flags and platform in poss_flags:
		config.extend(poss_flags[platform])
	if poss_flags and arch in poss_flags:
		config.extend(poss_flags[arch])
	
	os.chdir(source)
	
	# configure
	print "--->  Configuring %s" % source
	c = subprocess.Popen(config, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
	out = c.communicate()[0]
	if 0 != c.returncode:
		os.chdir(current_dir)
		_compile_failed(config, out)
		sys.exit(1)
	
	# make
	print "--->  Building %s" % source
	m = subprocess.Popen(['make'], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
	out = m.communicate()[0]
	if 0 != m.returncode:
		os.chdir(current_dir)
		_compile_failed(config, out)
		sys.exit(1)
	
	# make install
	print "--->  Installing %s" % source
	i = subprocess.Popen(['make', 'install'], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
	out = i.communicate()[0]
	if 0 != i.returncode:
		os.chdir(current_dir)
		_compile_failed(config, out)
		sys.exit(1)
	
	os.chdir(current_dir)
	CURRENTLY_BUILDING = None
	
	# help libtool by fixing dependency paths
	if FIX_DEP_LIBS:
		for fix_platform in FIX_DEP_LIBS:
			if platform == fix_platform:
				for fix_module in FIX_DEP_LIBS[platform]:
					if module_name == fix_module:
						fix_las = FIX_DEP_LIBS[platform][module_name]
						
						# loop the .la-files we need to fix
						for fix_la in fix_las:
							pat_from, pat_to = fix_las[fix_la]
							
							fix_path = os.path.join(target, 'lib')
							fix = os.path.join(fix_path, fix_la)
							
							# edit in-place
							if os.path.exists(fix):
								print shell_color('--->  Fixing dependency_libs in %s' % fix, 'yellow')
								
								for line in fileinput.input(fix, inplace=1):
									# like this: https://dev.openwrt.org/attachment/ticket/2233/glib2-dependencies.patch
									if line.startswith('dependency_libs'):
										print re.sub(pat_from, pat_to, line),
									else:
										print line,
								
							else:
								print shell_color("I'm told to fix an .la file that does not exist: %s" % fix, 'red', True)


def _compile_failed(config_command=[], message=None):
	"""Prints the failed command and message and moves the source directory so
		it will be picked up again on a re-run
	"""
	
	# log
	if config_command and len(config_command) > 0:
		print shell_color("Failed, here's the config and output:", 'red', True)
		print "----------\n%s" % ' '.join(config_command)
	else:
		print shell_color("Aborted", 'red', True)
	if message:
		print "----------\n%s\n----------\n" % message
	
	# clean up
	global CURRENTLY_BUILDING
	if CURRENTLY_BUILDING is not None:
		p, d = os.path.split(CURRENTLY_BUILDING)
		source_moved = os.path.join(p, '%s-failed' % d)
		if os.path.exists(source_moved):
			try:
				shutil.rmtree(source_moved)
			except Exception, e:
				print shell_color("Removing old failed directory %s failed: %s" % (source_moved, e), 'red', True)
		try:
			os.rename(CURRENTLY_BUILDING, source_moved)
		except Exception, e:
			print shell_color("Moving source directory to %s failed: %s" % (source_moved, e), 'red', True)
		CURRENTLY_BUILDING = None


def apply_patch(patch, target_base):
	"""Applies a patch to the directory identified by the patch name
	"""
	
	patch_dir, patch_name = os.path.split(patch)
	patch_base = patch_name[0:-6]
	
	# does the patch have a target?
	if patch_base == os.path.split(target_base)[1]:
		print shell_color("--->  Patching %s" % os.path.basename(target_base), 'yellow')
		
		# copy patch to target dir, apply patch and get out of there
		shutil.copy2(patch, os.path.join(target_base, patch_name))
		current_dir = os.getcwd()
		os.chdir(target_base)
		p = subprocess.call(['patch', '-p1', '-f', '-s', '-i', patch_name])
		os.chdir(current_dir)


def create_directories(dirs):
	"""Creates directories
	"""
	
	for directory in dirs:
		try:
			os.mkdir(directory)
		except OSError:
			pass


def shell_color(string, color, bold=False):
	if not sys.stdout.isatty():
		return string
	
	# stdout is a TTY, let's go
	attr = []
	if 'gray' == color:
		attr.append('30')
	elif 'red' == color:
		attr.append('31')
	elif 'green' == color:
		attr.append('32')
	elif 'yellow' == color:
		attr.append('33')
	elif 'blue' == color:
		attr.append('34')
	elif 'magenta' == color:
		attr.append('35')
	elif 'cyan' == color:
		attr.append('36')
	elif 'crimson' == color:
		attr.append('38')
	else:
		attr.append('37')		# white
	
	if bold:
		attr.append('1')
	
	return '\x1b[%sm%s\x1b[0m' % (';'.join(attr), string)


##
##	did you really read down to here?
##
if __name__ == "__main__":
	try:
		main()
	except KeyboardInterrupt:
		_compile_failed()




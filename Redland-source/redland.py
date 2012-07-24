#!/usr/bin/env python
#
#

import os
import sys
import shutil
import urllib2
import tarfile
import subprocess


# URLs to the sources
URL_RAPTOR = 'http://download.librdf.org/source/raptor2-2.0.8.tar.gz'
URL_RASQAL = 'http://download.librdf.org/source/rasqal-0.9.29.tar.gz'
URL_REDLAND = 'http://download.librdf.org/source/redland-1.0.15.tar.gz'

# where to download to
DOWNLOAD = 'downloads'

# target architectures per platform
ARCHS = {'iOS': ['armv7'], 'Mac': ['i386', 'x86_64']}

# name of custom configure scripts
CONFIG_NAME = 'pp-configure.sh'

# config flags perf project per platform and/or architecture
FLAGS = {
	'redland-1.0.15': {
		'iOS': ['--without-mysql', '--without-postgresql', '--without-virtuoso'],
	}
}


##
##	main function
##
def main():
	
	# setup
	arch_bases = []
	dirs = [DOWNLOAD]
	for platform in ARCHS.keys():
		archs = ARCHS[platform]
		for arch in archs:
			dirs.append('build-%s' % arch)
			arch_bases.append('build-%s' % arch)
			dirs.append('product-%s' % arch)
	create_directories(dirs)
	
	# download all
	raptorsrc = download(URL_RAPTOR, DOWNLOAD)
	rasqalsrc = download(URL_RASQAL, DOWNLOAD)
	rdfsrc = download(URL_REDLAND, DOWNLOAD)
	
	# unpack and build
	for platform in ARCHS.keys():
		archs = ARCHS[platform]
		for arch in archs:
			build_dir = 'build-%s' % arch
			product_dir = 'product-%s' % arch
			
			# raptor
			raptordir = unpack_into(raptorsrc, build_dir)
			compile(raptordir, product_dir, platform, arch, FLAGS)
			
			# rasqal
			rasqaldir = unpack_into(rasqalsrc, build_dir)
			compile(rasqaldir, product_dir, platform, arch, FLAGS)
			
			# librdf
			rdfdir = unpack_into(rdfsrc, build_dir)
			compile(rdfdir, product_dir, platform, arch, FLAGS)
	
	# now we should use lipo to create fat libraries...





##
##	functions
##
def download(url, directory=None, filename=None):
	"""Downloads a URL to a file with the same name, unless overridden
	
	Returns the path to the file downloaded
	
	Will NOT download the file if it exists at target directory and filename
	"""
	
	# can we write te the directory?
	if directory is None:
		abspath = os.path.abspath(__file__)
		directory, foo = os.path.split(abspath)

	if not os.access(directory, os.W_OK):
		raise Exception("Can't write to %s" % directory)
	
	if filename is None:
		filename = url.split('/')[-1]
	
	# if it already exists, we're not going to do anything
	path = os.path.join(directory, filename)
	if os.path.exists(path):
		print "%s has already been downloaded" % filename
		return path
	
	# create url and file handles
	urlhandle = urllib2.urlopen(url)
	filehandle = open(path, 'wb')
	meta = urlhandle.info()
	
	# start
	filesize = int(meta.getheaders("Content-Length")[0])
	print "Downloading %s (%s KB)" % (filename, filesize/1000)
	
	loaded = 0
	blocksize = 8192
	while True:
		buffer = urlhandle.read(blocksize)
		if not buffer:
			break
		
		loaded += len(buffer)
		filehandle.write(buffer)
		status = r"%10d	 [%3.2f%%]" % (loaded, loaded * 100.0 / filesize)
		status = status + chr(8)*(len(status)+1)
		print status,
	
	# return filename
	filehandle.close()
	return path


def unpack_into(archive, directory):
	"""Unarchives a gzipped tar into the given subdirectories
	
	Will NOT unpack the archive if there already is a directory with the same
	base name
	"""
	
	# unpack
	tar = tarfile.open(archive)
	base = tar.getnames()[0]
	target_dir = os.path.join(directory, base)
	if os.access(target_dir, os.F_OK):
		print "%s already exists, not unpacking %s" % (target_dir, os.path.split(archive)[1])
	else:
		print "Unpacking %s" % archive
		tar.extractall(directory)
	
	# close and remember directory name
	tar.close()
	
	return target_dir


def compile(source, target, platform, arch, flag_mapping):
	"""Compiles the given source directories into the mapped target directories
	
	- source directory must be configure/make/make install-able
	- target is the directory where the products will be installed
	- platform directory is searched for 'pp-configure.sh' and patches
	- arch is the architecture to build for
	- flag_mapping may contain additional flags that will be applied when
	  configuring
	"""
	
	current_dir = os.getcwd()
	
	parent, main = os.path.split(source)
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

	# find additional flags
	poss_flags = flag_mapping[main] if main in flag_mapping else None
	if poss_flags and platform in poss_flags:
		config.extend(poss_flags[platform])
	if poss_flags and arch in poss_flags:
		config.extend(poss_flags[arch])
	
	os.chdir(source)
	
	# configure
	print "Configuring %s" % source
	c = subprocess.Popen(config, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
	out = c.communicate()[0]
	if 0 != c.returncode:
		print "Failed, here's the config and output:\n----------\n%s" % ' '.join(config)
		print "----------\n%s\n----------\n" % out
		sys.exit(1)
	
	# make
	print "Building %s" % source
	m = subprocess.Popen(['make'], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
	out = m.communicate()[0]
	if 0 != m.returncode:
		print "Failed, here's the config and output:\n----------\n%s" % ' '.join(config)
		print "----------\n%s\n----------\n" % out
		sys.exit(1)
	
	# make install
	print "Installing %s" % source
	i = subprocess.Popen(['make', 'install'], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
	out = i.communicate()[0]
	if 0 != i.returncode:
		print "Failed, here's the config and output:\n----------\n%s" % ' '.join(config)
		print "----------\n%s\n----------\n" % out
		sys.exit(1)

	os.chdir(current_dir)


def apply_patch(patch, target_base):
	"""Applies a patch to the directory identified by the patch name
	"""
	
	patch_dir, patch_name = os.path.split(patch)
	patch_base = patch_name[0:-6]
	
	# does the patch have a target?
	if patch_base == os.path.split(target_base)[1]:
		print "Patching %s" % os.path.split(target_base)[1]
		
		# copy patch to target dir, apply patch and get out of there
		shutil.copy2(patch, os.path.join(target_base, patch_name))
		current_dir = os.getcwd()
		os.chdir(target_base)
		p = subprocess.call(['patch', '-f', '-s', '-i', patch_name])
		os.chdir(current_dir)


def create_directories(dirs):
	"""Creates directories
	"""
	
	for directory in dirs:
		try:
			os.mkdir(directory)
		except OSError:
			pass


##
##	did you really read down to here?
##
if __name__ == "__main__":
	main()



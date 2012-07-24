#!/usr/bin/env python
#
#

import os
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

# target instruction and build directories
TARGETS = {'iOS': 'build-ios', 'Mac': 'build-mac'}

# name of custom configure scripts
CONFIG_NAME = 'pp-configure.sh'

# config flags
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
	dirs = [DOWNLOAD]
	dirs.extend(TARGETS.keys())
	dirs.extend(TARGETS.values())
	create_directories(dirs)
	
	# handle raptor
	raptorsrc = download(URL_RAPTOR, DOWNLOAD)
	raptordirs = unpack_into(raptorsrc, TARGETS.keys())
	compile_all(raptordirs, TARGETS, FLAGS)
	
	# handle rasqal
	rasqalsrc = download(URL_RASQAL, DOWNLOAD)
	rasqaldirs = unpack_into(rasqalsrc, TARGETS.keys())
	compile_all(rasqaldirs, TARGETS, FLAGS)
	
	# handle librdf
	rdfsrc = download(URL_REDLAND, DOWNLOAD)
	rdfdirs = unpack_into(rdfsrc, TARGETS.keys())
	compile_all(rdfdirs, TARGETS, FLAGS)
	
	# ...





##
##	functions
##
def unpack_into(archive, directories=()):
	"""Unarchives a gzipped tar into the given subdirectories
	
	Will NOT unpack the archive if there already is a directory with the same
	base name
	"""
	
	unpacks = []
	
	# unpack into all targets
	for directory in directories:
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
		unpacks.append(target_dir)
	
	return unpacks


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


def compile_all(sources, target_mapping, flag_mapping):
	"""Compiles the given source directories into the mapped target directories
	
	- source directories must be configure/make/make install-able
	- target_mapping contains a target directory where the key is the parent
	  directory of the source
	- flag_mapping contains a dictionary for target directory names which again
	  contains dictionaries for the keys in target_mapping, which holds an
	  array of flags that we pass through to the configure script
	"""
	
	current_dir = os.getcwd()
	
	# repeat for all base directories
	for source in sources:
		os.chdir(current_dir)
		
		parent, main = os.path.split(source)
		rel_prefix = target_mapping[parent] if parent in target_mapping else '.'
		abs_prefix = os.path.abspath(rel_prefix)
		
		# apply patches if there are any
		for filename in os.listdir(parent):
			if len(filename) > 6 and '.patch' == filename[-6:]:
				apply_patch(os.path.join(parent, filename), source)
		
		# get the script there
		has_conf = False
		config_script = os.path.join(parent, CONFIG_NAME)
		if os.path.isfile(config_script):
			try:
				shutil.copy2(config_script, os.path.join(source, CONFIG_NAME))
				has_conf = True
			except OSError:
				pass
		
		# change directory
		os.chdir(source)
		
		# prepare to configure
		config_name = './%s' % CONFIG_NAME if has_conf else './configure'
		config = [config_name, '--prefix=%s' % abs_prefix]
		source_flags = flag_mapping[main] if main in flag_mapping else {}
		flags = source_flags[parent] if parent in source_flags else None
		if flags and len(flags) > 0:
			config.extend(flags)
		
		# configure
		print "Configuring %s" % source
		c = subprocess.Popen(config, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
		out = c.communicate()[0]
		if 0 != c.returncode:
			print "Failed, here's the config:\n----------\n%s\n" % ' '.join(config)
			print "Here's the output:\n----------\n%s\n----------\n" % out
			continue
		
		# make
		print "Building %s" % source
		m = subprocess.Popen(['make'], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
		out = m.communicate()[0]
		if 0 != m.returncode:
			print "Failed, here's the config:\n----------\n%s\n" % ' '.join(config)
			print "Here's the output:\n----------\n%s\n----------\n" % out
			continue
		
		# make install
		print "Installing %s" % source
		i = subprocess.Popen(['make', 'install'], stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
		out = i.communicate()[0]
		if 0 != i.returncode:
			print "Failed, here's the config:\n----------\n%s\n" % ' '.join(config)
			print "Here's the output:\n----------\n%s\n----------\n" % out
			continue
	
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
	"""Creates our base directories
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



    The project is heavily WIP!
    
    STATUS:
    [x]  C libraries cross-compile successfully (armv6, armv7)
    [x]  Mac build succeeds
    [x]  Mac unit tests succeed
    [x]  iOS build succeeds
    [~]  iOS unit tests succeed (1 exception remaining)
    [ ]  Deprecated librdf calls have been replaced
    [ ]  Mac framework has been used in a sample application
    [x]  iOS framework has been used in a sample app


Redland Objective-C RDF Wrapper
===============================

This projects is a resurrection of Rene Puls' Objective-C wrapper for the [Redland C libraries][redland] for **Mac**, with the addition of a static library target suitable for **iOS**. The code now requires **Automatic Reference Counting** (ARC) to be enabled.


Building the C libraries
------------------------

There is a Python-script that downloads and (cross-)compiles [raptor2], [rasqal] and [librdf][redland], the components you need. The script needs you to have Xcode 4.4 or 4.5 and the iOS SDK 5.1 installed, and make sure you install the command line tools from within Xcode. Then just choose the **Build C Library** target and hit **Run**. Alternatively, open the Terminal and execute the script manually:

    $ cd Redland-ObjC/Redland-source
    $ ./redland.py

Compiling requires `pkg-config` which you can most easily install via [Homebrew][]:

    $ brew install pkg-config


Using the Framework
-------------------

[more to come]


Building the Documentation
--------------------------

The code is documented using [Doxygen]. If you want to compile the documentation, install doxygen (again, easiest through [Homebrew]) and run the "Documentation" target. Or you can perform it manually from the command line:

    $ brew install doxygen
	$ cd path/to/Redland-ObjC
	$ doxygen
	$ cd Docs/html
	$ make install

Doxygen should pick up the configuration file `Doxyfile` automatically. Edit that file to tweak how the documentation looks.


[redland]: http://librdf.org/
[raptor2]: http://librdf.org/raptor/
[rasqal]: http://librdf.org/rasqal/
[homebrew]: http://mxcl.github.com/homebrew/
[doxygen]: http://www.stack.nl/~dimitri/doxygen/

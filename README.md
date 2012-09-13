    STATUS:
    [x]  C libraries cross-compile successfully (armv6, armv7)
    [x]  Mac build succeeds
    [x]  Mac unit tests succeed
    [x]  iOS build succeeds
    [x]  iOS unit tests succeed
    [x]  Deprecated librdf calls have been replaced
    [ ]  Mac framework has been used in a sample application
    [x]  iOS framework has been used in a sample app


Redland Objective-C RDF Wrapper
===============================

This projects is a resurrection of Rene Puls' Objective-C wrapper for the [Redland C libraries][redland] for **Mac**, with the addition of a static library target suitable for **iOS**. The code now requires **Automatic Reference Counting** (ARC) to be enabled.


Building the C libraries
------------------------

There is a Python-script that downloads and (cross-)compiles [raptor2], [rasqal] and [librdf][redland], the components you need. The script needs you to have Xcode 4.4 or 4.5 and the iOS SDK 5.1 or later installed, and make sure you install the command line tools from within Xcode. Then just choose the **Redland C Library** target and hit **Run**. Alternatively, open the Terminal and execute the script manually:

    $ cd Redland-ObjC/Redland-source
    $ ./cross-compile.py

Compiling requires `pkg-config` which you can most easily install via [Homebrew][]:

    $ brew install pkg-config


Using the Framework
-------------------

[more to come]


Building the Documentation
--------------------------

The code is documented using [appledoc]. If you want to compile the documentation it's best if you grab appledoc from GitHub, build and install it and then run it against the code:

    $ git clone git://github.com/tomaz/appledoc.git
    $ cd appledoc
    $ ./install-appledoc.sh -b /usr/local/bin -t ~/Library/Application\ Support/appledoc
    $ cd ..
    $ appledoc .

> NOTE: appledoc currently does not support the `///<` token, so some property documentations are shifted and thus off!

Note that this assumes that you have write permissions for `/usr/local`, if not you may need to issue this command as root with `sudo`. The documentation is now available from within Xcode.


[redland]: http://librdf.org/
[raptor2]: http://librdf.org/raptor/
[rasqal]: http://librdf.org/rasqal/
[homebrew]: http://mxcl.github.com/homebrew/
[appledoc]: http://gentlebytes.com/appledoc/

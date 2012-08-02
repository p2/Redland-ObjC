    The project is heavily WIP!
    
    STATUS:
    [x]  C libraries cross-compile successfully (armv6, armv7)
    [x]  Mac build succeeds
    [x]  Mac unit tests succeed
    [x]  iOS build succeeds
    [~]  iOS unit tests succeed (1 exception remaining)
    [ ]  Deprecated librdf calls have been replaced
    [ ]  Mac framework has been used in a sample application
    [ ]  iOS framework has been used in a sample app


Redland Objective-C RDF Wrapper
===============================

This projects is a resurrection of Rene Puls' Objective-C wrapper for the [Redland C libraries][redland] for **Mac**, with the addition of a static library target suitable for **iOS**. The code now requires **Automatic Reference Counting** (ARC) to be enabled.


Building the C libraries
------------------------

There is a Python-script that downloads and (cross-)compiles [raptor2][], [rasqal][] and [librdf][redland], the components you need. The script needs you to have Xcode 4.4 or 4.5 and the iOS SDK 5.1 installed, and make sure you install the command line tools from within Xcode. Then just choose the **Build C Library** target and hit **Run**. Alternatively, open the Terminal and execute the script manually:

    $ cd Redland-ObjC/Redland-source
    $ ./redland.py

Compiling requires `pkg-config` which you can most easily install via [Homebrew][]:

    $ brew install pkg-config


[redland]: http://librdf.org/
[raptor2]: http://librdf.org/raptor/
[rasqal]: http://librdf.org/rasqal/
[homebrew]: http://mxcl.github.com/homebrew/



Using the Framework
-------------------

[more to come]
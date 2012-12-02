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

This projects is a resurrection of Rene Puls' Objective-C wrapper for the [Redland C libraries][librdf] for **Mac**, with the addition of a static library target suitable for **iOS**. The code now requires **Automatic Reference Counting** (ARC) to be enabled.

[git]: http://git-scm.com


Getting the Framework
---------------------

If you're using [Git] for version control of your project (and I hope you are), it's easiest to add the framework as a submodule:

    $ cd YourProject
    $ git submodule add git://github.com/p2/Redland-ObjC.git
    $ git submodule update --init --recursive

If not you should still use Git to check out the latest version:

    $ cd YourProject
    $ git clone git://github.com/p2/Redland-ObjC.git

Now whenever there has been an update to the framework and you want to get the latest and greatest, you can just pull:

    $ cd YourProject/Redland-ObjC
    $ git pull


Building the C libraries
------------------------

> **Note:** When building the C libraries with Xcode, the progress bar will appear stalled while saying _Running 1 of 1 custom shell scripts_, which can take a few minutes. Just be patient, the compilation will go through or abort with an error.

The first time you build the framework, the C libraries will automatically be built, so you need not worry about this. But for the curious mind:

There is a Python-script that downloads and (cross-)compiles [raptor2], [rasqal] and [librdf], the components you need. The script needs you to have Xcode 4.5 and the iOS SDK 5.1 or later installed. Make sure you install the command line tools from within Xcode. Then just choose the **Redland C Library** target and hit **Run**. Alternatively, open the Terminal and execute the script manually:

    $ cd Redland-ObjC/Redland-source
    $ ./cross-compile.py

Compiling requires `pkg-config` which you can most easily install via [Homebrew]:

    $ brew install pkg-config

As of Xcode 4.5, this will build libraries for `armv7`, `armv7s`, `i386` and `x86_64`. You can change this in the file `cross-compile-config.py`.

[raptor2]: http://librdf.org/raptor/
[rasqal]: http://librdf.org/rasqal/
[librdf]: http://librdf.org/
[homebrew]: http://mxcl.github.com/homebrew/


Using the Framework
-------------------

The framework is intended to be added to your Xcode workspace and linked into your app. Add the project file `Redland.xcodeproj` to your own project workspace by dragging it to the file area in Xcode.

Then, in your app's **Build Settings**, you need to adjust a few things:

### For iOS Apps ###

In your app's **Build Phases** under **Link Binary with Libraries**, add these libraries by clicking the [+] button:

* `libredland-ios.a`
  
  > After you've added this lib and build your app, Xcode will automatically build the Redland-ObjC project first. As noted above, this will take a few minutes the first time it happens because Xcode cross-compiles the redland C libraries for the first time.

* `libxml2.dylib`
* `libsqlite3.dylib` (if you use storage)

Now you need to give Xcode some more hints so it can compile your app

* Add this path to your **Header Search Paths**:
  * `"$(BUILT_PRODUCTS_DIR)"` with _recursive_ enabled

* Add this to **Other Linker Flags**:
  * `-ObjC`. This makes sure categories used in the framework are being correctly loaded. If you forget this flag, your app will crash as soon as you try to use a class method on a Redland object.


### For Mac Apps ###

[coming…]

### Using Redland Objects ###

In whichever class you use the Redland-ObjC objects, you need to include our header:

    #import <Redland-ObjC.h>

Here's an example on how you would parse RDF+XML contained in a file `example.xml` from your bundle:

```objective-c
NSString *rdfPath = [[NSBundle mainBundle] pathForResource:@"example" ofType:@"xml"];
NSString *rdfString = [[NSString alloc] initWithContentsOfFile:rdfPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
RedlandParser *parser = [RedlandParser parserWithName:RedlandRDFXMLParserName];
RedlandURI *uri = [RedlandURI URIWithString:@"http://www.w3.org/1999/02/22-rdf-syntax-ns#"];
RedlandModel *model = [RedlandModel new];

// parse
@try {
	[parser parseString:rdfString intoModel:model withBaseURI:uri];
}
@catch (NSException *exception) {
	NSLog(@"Failed to parse RDF: %@", [exception reason]);
}
```
example.rdf:
```xml
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
  <rdf:Description rdf:about="http://www.w3.org/2001/08/rdf-test/">
    <dc:creator>Jan Grant</dc:creator>
    <dc:creator>Dave Beckett</dc:creator>
    <dc:publisher>
      <rdf:Description>
        <dc:title>World Wide Web Consortium</dc:title>
        <dc:source rdf:resource="http://www.w3.org/"/>
      </rdf:Description>
    </dc:publisher>
  </rdf:Description>
</rdf:RDF>
```

Here's how you would query this model for one of the creators of rdf-test:

```objective-c
RedlandNode *subject = [RedlandNode nodeWithURIString:@"http://www.w3.org/2001/08/rdf-test/"];
RedlandNode *predicate = [RedlandNode nodeWithURIString:@"http://purl.org/dc/elements/1.1/creator"];
RedlandStatement *statement = [RedlandStatement statementWithSubject:subject
                                                           predicate:predicate
                                                              object:nil];
RedlandStreamEnumerator *query = [model enumeratorOfStatementsLike:statement];

RedlandStatement *rslt = [query nextObject];
// be aware that if literalValue can only be used on literal nodes.
// object is the object-node of the RedlandStatement that is returned by the query.
NSString *creator = [rslt.object literalValue];
NSLog(@"Creator: %@", creator);
```

I've made a [simple demo app for iOS](https://github.com/p2/RedlandDemo) if you want to see it in action. The demo app contains the framework as a submodule, so just clone the demo repository and hit `Run`.


Building the Documentation
--------------------------

The code is documented using [appledoc]. This allows you to integrate the documentation right into Xcode, meaning you can then `ALT` + click Redland classes and methods to see what they do.  
If you want to compile the documentation, it's best if you grab appledoc from GitHub, build and install it and then run it against the code:

    $ git clone git://github.com/tomaz/appledoc.git
    $ cd appledoc
    $ ./install-appledoc.sh -b /usr/local/bin -t ~/Library/Application\ Support/appledoc
    $ cd ..
    $ appledoc .

> NOTE: appledoc currently does not support the `///<` token, so some property documentations are shifted and thus off!

Note that this assumes that you have write permissions for `/usr/local`, if not you may need to issue this command as root with `sudo`. The documentation is now available from within Xcode.

[appledoc]: http://gentlebytes.com/appledoc/

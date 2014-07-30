Redland Objective-C Wrapper
===========================

This projects is a resurrection of Rene Puls' Objective-C wrapper for the [Redland C RDF libraries][librdf] for **Mac**, with the addition of a static library target suitable for **iOS**.
The code now requires **Automatic Reference Counting** (ARC) to be enabled.

The wrapped libraries are:

- raptor2 _2.0.13_
- rasqal _0.9.32_
- redland _1.0.17_

The **documentation** is available at [http://p2.github.io/Redland-ObjC/][docs].
Please note that there will be compilation errors if the path to your project directory contains **spaces**.


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

**Note** that building the C libraries is not possible if your project directory contains spaces.
The build script will warn you about this fact and exit.


Building the C libraries
------------------------

**TL;DR:** Run the script `Redland-source/build.sh`

> **Note:** When building the C libraries with Xcode, the progress bar will appear stalled while saying _Running 1 of 1 custom shell scripts_, which can take some minutes.
> Just be patient, the compilation will go through or abort with an error.

The first time you build the framework, the C libraries will automatically be built, so you need not worry about this.
Compilation requires `pkg-config`, which will be installed for you if you run the `build.sh` script.
You can install it yourself via [Homebrew]:

```bash
$ brew install pkg-config
```

#### Cross compiling librdf

There is a Python-script that downloads and (cross-)compiles [raptor2], [rasqal] and [librdf], the components you need.
The script needs you to have Xcode 4.5 and the iOS SDK 5.1 or later installed.
If you are on Xcode < 5.0, make sure you have the command line tools installed, you do that from within Xcode » Preferences » Downloads » Components.

Just choose the **Redland C Library** target and hit **Run**.
Alternatively, open the Terminal and execute the script manually:

```bash
$ cd Redland-ObjC/Redland-source
$ python cross-compile.py
```

This will build libraries for `armv7`, `armv7s`, `arm64`, `i386` and `x86_64`.
You can change all this in the file `cross-compile-config.py` if you dare.
The script will only build the missing C libraries, if you want to force a new build run the target **Redland PURGE C Library** or run the script `Redland-source/start-over.sh`.

**Problems?** Take a look at [common errors](https://github.com/p2/Redland-ObjC/wiki/Common-Errors).

[raptor2]: http://librdf.org/raptor/
[rasqal]: http://librdf.org/rasqal/
[librdf]: http://librdf.org/
[homebrew]: http://mxcl.github.com/homebrew/


Using the Framework
-------------------

The framework is intended to be added to your Xcode workspace and linked into your app. Add the project file `Redland.xcodeproj` to your own project workspace
by dragging it to the file area in Xcode.

Then, in your app's **Build Settings**, you need to adjust a few things:

### For iOS Apps ###

In your app's **Build Phases** under **Link Binary with Libraries**, add these libraries by clicking the [+] button:

* `libredland-ios.a`
  
  > **Note:** After you've added this lib and build your app, Xcode will automatically build the Redland-ObjC project first. As noted above, this will take a
  > few minutes the first time it happens because Xcode cross-compiles the redland C libraries for the first time.
  
  > **Note:** Xcode seems to have issues when header files get added during a build process, which is what happens on the first cross compile. If your app
  > build fails because of missing headers, simply close and reopen the project again.

* `libxml2.dylib`
* `libxslt.dylib`
* `libsqlite3.dylib` (if you use storage)

Now you need to give Xcode some more hints so it can compile your app

#### Add this path to your `Header Search Paths` and `User Header Search Paths`:

`"$(PROJECT_DIR)"` with _recursive_ enabled.  

> This assumes that the `Redland-ObjC` directory is inside your app directory, adjust as needed.

#### Add this to `Other Linker Flags`:

`-ObjC`  

> This makes sure categories used in the framework are being correctly loaded. If you forget this flag, your app will crash as soon as you try to use a class
> method on a Redland object.

### A Note on Header Files ###

What you would usually do with static libraries is have public header files. This however prevents Xcode from building an executable app when archiving since
it also archives the public headers to a usr/include folder in the archive.

For this reason all iOS header files in the framework are on project level only. This is why you must tell Xcode to go look for your header files in the
project directory instead, as instructed above.


Using Redland Objects
---------------------

In whichever class you use the Redland-ObjC objects, you need to include our header:

    #import <Redland-ObjC.h>

Here's an example on how you would parse RDF+XML contained in a file `example.xml` in your bundle:

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

example.xml:
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

I've made a [simple demo app for iOS](https://github.com/p2/RedlandDemo) if you want to see it in action. The demo app contains the framework as a submodule,
so just clone the demo repository and hit `Run`.


Building the Documentation
--------------------------

The code is documented using [appledoc] and available on [http://p2.github.io/Redland-ObjC/][docs]. Appledoc allows you to integrate the documentation right into Xcode, meaning you can then `ALT` - click Redland classes
and methods to see what they do.  
If you want to compile the documentation, it's best if you grab appledoc from GitHub directly:

    $ git clone git://github.com/tomaz/appledoc.git
    $ cd appledoc
    $ ./install-appledoc.sh -b /usr/local/bin -t ~/Library/Application\ Support/appledoc

> Note that this assumes that you have write permissions for `/usr/local`, if not you may need to issue this command as root with `sudo`.

Afterwards just select the **Redland Documentation** target in Xcode and hit `CMD` + `B`. This will build and install the documentation, after which it will be available from within Xcode. To build manually you do:

    $ appledoc .

> NOTE: appledoc currently does not support the `///<` token, so some property documentations are shifted and thus off!


[git]: http://git-scm.com
[docs]: http://p2.github.io/Redland-ObjC/
[appledoc]: http://gentlebytes.com/appledoc/

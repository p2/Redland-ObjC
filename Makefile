TARGETNAME=Redland
BUILDSTYLE=Deployment
OBJROOT=objects
SYMROOT=products
BDB_LDFLAGS=/usr/local/berkeleydb/lib/libdb-4.2.a
REDLAND_LDFLAGS=/usr/local/lib/libraptor.a /usr/local/lib/librdf.a /usr/local/lib/librasqal.a
PCRE_LDFLAGS=/usr/local/lib/libpcre.a

# no need to change anything below this point
XCODE_COMMAND=xcodebuild -target $(TARGETNAME) -buildstyle $(BUILDSTYLE)
EXTRA_SETTINGS="REDLAND_LDFLAGS=$(REDLAND_LDFLAGS)" "PCRE_LDFLAGS=$(PCRE_LDFLAGS)" "BDB_LDFLAGS=$(BDB_LDFLAGS)" "SYMROOT=$(SYMROOT)" "OBJROOT=$(OBJROOT)"

build:
	$(XCODE_COMMAND) build $(EXTRA_SETTINGS)

clean:
	$(XCODE_COMMAND) clean $(EXTRA_SETTINGS)

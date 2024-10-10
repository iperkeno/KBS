# KBS developement

## *config* and *configure*

The use of two terms *config* and *configure* makes the read of code confusing.
The idea is to substitute the terme *config* with *setup*


## variable *packages*

the function:

         proc ::kbs::config::Package {name script} 

populate the *packages* variable


## Build commands and examples

```tcl
tclsh ./kbs.tcl -v -builddir=buildLinux -r -mk-bi -bi="tk8.6" install kbskit8.6
```

```tcl
    MAKEFLAGS=-j4 tclsh ./kbs.tcl -v -builddir=buildLinux -r -mk-bi -bi="tk8.6 tls1.7.22 tcllib1.21" install kbskit8.6
```

## KIT generation process

1. source/configure/build/install packages TCL nad Tk
2. source/configure/build/install additional packages
3. source/configure/build/install kbskit8.6

### KIT generation from BASEKIT
for KITGEN based on makefile, is implemented an interesting method to generate the kit:

```
    tclkit-gui$(EXE): kit-cli$(EXE) kit-gui$(EXE) ../../setupvfs.tcl build/files
        cp kit-gui$(EXE) $@ && $(STRIP) $@ && $(UPX) $@
        ./kit-cli -init- ../../setupvfs.tcl $(KIT_OPTS) $@ gui
```
1. copy `kit` to `tclkit`
2. `STRIP tclkit` to remove content in the overlay
3. `UPX tclkit` to compress it
4. `runtime-kit -init-`  with function `setupvfs.tcl` with options - t`$(KIT_OPTS)` to `tclkit`

TODO modificare basekit in mod da generare un basekit con upx e poi caricare le librerie a seconda della configurazione.

TODO add in the kbs-config file the dependencies download; we can addd it in SOURCE case with `sudo apt-get install xxx-dev `



## Documentation
Doxigen does not support tcl anymore.
TODO: doxygen: remove action related to doxigen
TODO: doxygen: remove doxygen from help
TODO: doxygen: substitute with a tcl script for generating a markdown documentation, conside RUFF!

## Tcl-Pkg

Sarnold offers ...

What : Tcl-Pkg  
Where : http://sourceforge.net/projects/tcl-pkg   
Dependencies : Tcl/Tk 8.4, BWidget 1.7, TclXml 2.6    
Description : Tcl-Pkg is a sort of client-server online Tcl package repository browser. The purpose of this software is to access package data via a distributed (as in distributed computing) sort of repository.
Then, with simple Internet access and a Web browser, users download static or even dynamically generated up-to-date information in XML files and are able to view the resources or their favorite Tcl-related software, packages and extensions.

Currently at version 0.5.3 
Updated: 11/2006
Contact: <stephanearnold@yahoo.fr> & <sarnold75@users.sourceforge.net>

## a package fetching script
https://wiki.tcl-lang.org/page/A+Tcl+repository

http://prdownloads.sourceforge.net/tcl/tcl9.0b1-src.tar.gz

    # Patch [Get srcdir]/Makefile.in 13 \
    #   { PACKAGE_INSTALL_DIR = $(TCL_PACKAGE_PATH)/tcltls$(PACKAGE_VERSION)} \
    #   { PACKAGE_INSTALL_DIR = $(TCL_PACKAGE_PATH)/tls$(PACKAGE_VERSION)}



### readline library wrapper
rlwrap tclsh

consider *tcl-linenoise* at https://andreas-kupries.github.io/tcl-linenoise/

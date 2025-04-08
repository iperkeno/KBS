# KBS - Kitgen Build System 
Version 0.4.9
[license](kbs-license)





## Build commands examples

Build a single package:
```bash
tclsh ./kbs.tcl -v -builddir=buildLinux -r install <packge-name>
```

Build a basekit with tk8.6
```bash
tclsh ./kbs.tcl -v -builddir=buildLinux -r -mk-bi -bi="tk8.6" install kbskit8.6
```


Build a TCLKIT with tk8.6 tls1.7.22 tcllib1.21, using 4 core
```bash
MAKEFLAGS=-j4 tclsh ./kbs.tcl -v -builddir=buildLinux -r -mk-bi -bi="tk8.6 tls1.7.22 tcllib1.21" install kbskit8.6
```



## README for previous Revision 
[RADME.0.4.8](./README.0.4.8)

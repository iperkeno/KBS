# begin of Tcl/Tk Pakages DB
namespace eval ::kbs::config {
# @{
## @defgroup __
#@verbatim
Package __ {
  Source {
    if {![file exists sf.net]} { file mkdir sf.net }
    Link ../sf.net
  }
  Configure {}
  Make {
    # Build all files for distribution on sourceforge.
    # do everything from the main directory
    cd ../..
    if {$::tcl_platform(platform) == "windows"} {
      set MYEXE "./[exec uname]/bin/tclsh86s.exe kbs.tcl"
      set my0 {}
    } else {
      set MYEXE {./kbs.tcl}
      set my0 expect5.45
    }
    #
    lappend my0\
	bwidget1.9.10\
	gridplus2.11\
	icons1.2 img1.4.6\
	memchan2.3 mentry3.7\
	nsf2.0.0\
	pdf4tcl0.8.4\
	ral0.11.7\
	tablelist5.16 tcllib1.18 tclx8.4 tdom0.8.3\
	tkcon tkdnd2.8 tklib0.6 tkpath0.3.3 tktable2.10 treectrl2.4.1 trofs0.4.9\
	udp1.0.11 ukaz0.2\
	vectcl0.2 vectcltk0.2\
	wcb3.5\
	xotcl1.6.8
    if {$::tcl_platform(os) != "Darwin"} {lappend my0 rbc0.1}
    # 8.6 kbskit
    Run {*}$MYEXE -builddir=sf86 -v -r -vq -mk install kbskit8.6
    # 8.6 tksqlite
    Run {*}$MYEXE -builddir=sf86 -v -r install tksqlite0.5.13
    # 8.6 BI
    set my $my0
    lappend my itk4.0 iwidgets4.1
    Run {*}$MYEXE -builddir=sf86 -v -r -vq-bi -bi=$my install kbskit8.6
    # save results under sf.net
    set myPrefix "sf.net/[string map {{ } {}} $::tcl_platform(os)]_"
    foreach myFile [glob sf*/bin/kbs* sf*/bin/tksqlite*] {
      file copy -force $myFile $myPrefix[file tail $myFile]
    }
    if {![file exists sf.net/kbs.tgz]} {
      puts "+++ [clock format [clock seconds] -format %T] kbs.tgz"
      Run tar czf sf.net/kbs.tgz kbs.tcl sources
    }
if 0 {;# Testfile
  catch {package req x}
  set i 0
  foreach p [lsort [package names]] {
    if {$p == "vfs::template"} continue
    if {$p == "tdbc::mysql"} continue
    puts -nonewline $p== ; update
    puts $p=[catch {package req $p}]
  }
}
  }
}
#@endverbatim
## @defgroup bwidget
# Updated 14/04/2023
#@verbatim
Package bwidget1.9.16 {
  Source {Wget https://downloads.sourceforge.net/project/tcllib/BWidget/1.9.16/bwidget-1.9.16.tar.gz}
  Configure {}
  Install {
    file delete -force [Get builddir]/lib/[file tail [Get srcdir]]
    file copy -force [Get srcdir] [Get builddir]/lib
  }
  Test {
    cd [Get builddir]/lib/bwidget1.9.16/demo
    Run [Get kitgui] demo.tcl
  }
}
#@endverbatim
## @defgroup expect
# Updated 14/04/2023
#@verbatim
Package expect5.45.4 { 
  Source {Wget https://sourceforge.net/projects/expect/files/Expect/5.45.4/expect5.45.4.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup gridplus
#@verbatim
Package gridplus2.11 {
  Require {Use icons2.0 tablelist5.16}
  Source {Wget http://www.satisoft.com/tcltk/gridplus2/download/gridplus.zip}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup icons
# 14/04/2023 - Updated to 2.0
#@verbatim
Package icons2.0 {    
  Source {Wget http://www.satisoft.com/tcltk/icons/icons.zip}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup img
# @bug #76 at https://sourceforge.net/p/tkimg/bugs/
#@verbatim
Package img1.4.3 {
  Source {Svn https://svn.code.sf.net/p/tkimg/code/trunk -r 374}
  Configure {
        Config [Get srcdir-sys]
  }
  Make {Run make collate}
  Install {
    Run make install-libraries
    Libdir Img1.4.3
  }
  Clean {Run make clean}
}
Package img1.4.6 {
  Source {Svn https://svn.code.sf.net/p/tkimg/code/trunk -r 410}
  Configure {
    Config [Get srcdir-sys]
  }
  Make {Run make collate}
  Install {
    Run make install-libraries
    Libdir Img1.4.6
  }
  Clean {Run make clean}
}
#@endverbatim
## @defgroup itcl
#@verbatim
Package itcl4.2.4 {
  Source {Cvs incrtcl.cvs.sourceforge.net:/cvsroot/incrtcl -D 2010-10-28 incrTcl}
  Configure {Config [Get srcdir-sys]/itcl}
  Make {Run make}
  Install {Run make install-binaries install-libraries install-doc}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup itk
#@verbatim
Package itk3.4 {
  Require {Use itcl3.4}
  Source {Link itcl3.4}
  Configure {Config [Get srcdir-sys]/itk}
  Make {Run make}
  Install {Run make install-binaries install-libraries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup itk
#@verbatim
Package itk4.0 {
  Source {Wget http://prdownloads.sourceforge.net/kbskit/itk/itk40.tgz}
  Configure {}
  Install {Tcl itk4.0 library}
}
#@endverbatim
## @defgroup iwidgets
# @bug Source: LD_LIBRARY_PATH setting
#@verbatim
Package iwidgets4.0.2 {
  Require {Use itk3.4}
  Source {
    Cvs incrtcl.cvs.sourceforge.net:/cvsroot/incrtcl -D 2010-10-28 iwidgets 
    Patch [Get srcdir]/Makefile.in 72 {		  @LD_LIBRARY_PATH_VAR@="$(EXTRA_PATH):$(@LD_LIBRARY_PATH_VAR@)"}  {		  LD_LIBRARY_PATH="$(EXTRA_PATH):$(@LD_LIBRARY_PATH_VAR@)"}
  }
  Configure {
  Config [Get srcdir-sys] -with-itcl=[Get srcdir-sys]/../itcl4.2.4
  }
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup iwidgets
#@verbatim
Package iwidgets4.1 {
  Require {Use itk4.0}
  Source {Wget http://prdownloads.sourceforge.net/kbskit/itk/iwidgets41.tgz
Wget https://chiselapp.com/user/rene/repository/iwidgets/iwidgets.tgz?uuid=66a0503a53ed1c6bd09619fcbb6ae6fe3d938398}
  Configure {}
  Install {Tcl iwidgets4.1 library}
}
#@endverbatim
## @defgroup kbskit
#@verbatim
Package kbskit0.4 {
  Source {Cvs kbskit.cvs.sourceforge.net:/cvsroot/kbskit -r kbskit_0_4 kbskit}
}
#@endverbatim
## @defgroup kbskit
#@verbatim
Package kbskit8.5 {
  Require {
    Use kbskit0.4 sdx.kit
    Use tk8.5-static tk8.5 vfs1.4-static zlib1.2.8-static thread2.8.9 {*}[Get bi]
    if {[lsearch -glob [Get kit] {vq*}] != -1} { Use vqtcl4.1-static }
    if {[lsearch -glob [Get kit] {mk*}] != -1} { Use mk4tcl2.4.9.7-static itcl4.2.4 }
  }
  Source {Link kbskit0.4}
  Configure {Config [Get srcdir-sys] --disable-shared}
  Make {
    set MYMK "[Get builddir-sys]/lib/mk4tcl2.4.9.7-static/Mk4tcl.a "
    if {$::tcl_platform(os) == "Darwin"} {
      append MYMK "-static-libgcc -lstdc++ -framework CoreFoundation"
    } elseif {$::tcl_platform(os) == "SunOS" && [Get CC] == "cc"} {
      append MYMK "-lCstd -lCrun"
    } elseif {[Get staticstdcpp]} {
      append MYMK "-Wl,-Bstatic -lstdc++ -Wl,-Bdynamic -lm"
    }  else  {
      append MYMK "-lstdc++"
    }
    if {$::tcl_platform(platform) == "windows"} {
      set MYCLI "[Get builddir-sys]/lib/libtcl85s.a"
      append MYCLI " [Get builddir-sys]/lib/libz.a"
      append MYCLI " [Get builddir-sys]/lib/vfs1.4.1/vfs141.a"
      set MYGUI "[Get builddir-sys]/lib/libtk85s.a"
      set MYVQ "[Get builddir-sys]/lib/vqtcl4.1/vqtcl41.a"
    } else {
      set MYCLI "[Get builddir-sys]/lib/libtcl8.5.a"
      append MYCLI " [Get builddir-sys]/lib/libz.a"
      append MYCLI " [Get builddir-sys]/lib/vfs1.4.1/libvfs1.4.1.a"
      set MYGUI "[Get builddir-sys]/lib/libtk8.5.a"
      set MYVQ "[Get builddir-sys]/lib/vqtcl4.1/libvqtcl4.1.a"
    }
    if {[Get -threads] in {--enable-threads --enable-threads=yes {}}} {
      set MYKITVQ "thread2.8.9"
      set MYKITMK "thread2.8.9 itcl4.2.4"
    } else {
      set MYKITVQ ""
      set MYKITMK "itcl4.2.4"
    }
    foreach my [Get kit] {
      Run make MYCLI=$MYCLI MYGUI=$MYGUI MYVQ=$MYVQ MYKITVQ=$MYKITVQ MYMK=$MYMK MYKITMK=$MYKITMK MYKITBI=[Get bi] all-$my
    }
  }
  Install {foreach my [Get kit] {Run make install-$my}}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup kbskit
#@verbatim
Package kbskit8.6 {
  Require {
    Use kbskit0.4 sdx.kit
    Use tk8.6-static tk8.6 vfs1.4-static {*}[Get bi]
    if {[lsearch -glob [Get kit] {vq*}] != -1} { Use vqtcl4.1-static }
    if {[lsearch -glob [Get kit] {mk*}] != -1} { Use mk4tcl2.4.9.7-static}
  }
  Source {Link kbskit0.4}
  Configure {Config [Get srcdir-sys] --disable-shared --disable-stubs}
  Make {
    set MYMK "[Get builddir-sys]/lib/mk4tcl2.4.9.7-static/Mk4tcl.a "
    if {$::tcl_platform(platform) == "windows"} {
      if {[Get staticstdcpp]} {
        append MYMK "[Get builddir-sys]/lib/libtclstub86s.a -static-libstdc++ -lstdc++"
      } else {
        append MYMK "[Get builddir-sys]/lib/libtclstub86s.a -lstdc++"
      }
    } elseif {$::tcl_platform(os) == "Darwin"} {
      append MYMK "-lstdc++ -framework CoreFoundation"
    } elseif {$::tcl_platform(os) == "SunOS" && [Get CC] == "cc"} {
      append MYMK "-lCstd -lCrun"
    } elseif {[Get staticstdcpp]} {
      append MYMK "-Wl,-Bstatic -lstdc++ -Wl,-Bdynamic -lm"
    }  else  {
      append MYMK "-lstdc++"
    }
    if {$::tcl_platform(platform) == "windows"} {
      set MYCLI "[Get builddir-sys]/lib/libtcl86s.a"
      append MYCLI " [Get builddir-sys]/lib/vfs1.4.1/vfs141.a"
      set MYGUI "[Get builddir-sys]/lib/libtk86s.a"
      set MYVQ "[Get builddir-sys]/lib/vqtcl4.1/vqtcl41.a [Get builddir-sys]/lib/libtclstub86s.a"
    } else {
      set MYCLI "[Get builddir-sys]/lib/libtcl8.6.a"
      append MYCLI " [Get builddir-sys]/lib/vfs1.4.1/libvfs1.4.1.a"
      set MYGUI "[Get builddir-sys]/lib/libtk8.6.a"
      set MYVQ "[Get builddir-sys]/lib/vqtcl4.1/libvqtcl4.1.a [Get builddir-sys]/lib/libtclstub8.6.a"
    }
    if {[Get -threads] in {--enable-threads --enable-threads=yes {}}} {
      set MYKITVQ "thread2.8.9 tdbc1.1.7 itcl4.2.4 sqlite3.44.2 tdbcmysql1.1.7 tdbcodbc1.1.7 tdbcpostgres1.1.7"
      set MYKITMK "thread2.8.9 tdbc1.1.7 itcl4.2.4 sqlite3.44.2 tdbcmysql1.1.7 tdbcodbc1.1.7 tdbcpostgres1.1.7"
    } else {
      set MYKITVQ "tdbc1.1.7 itcl4.2.4 sqlite3.44.2 tdbcmysql1.1.7 tdbcodbc1.1.7 tdbcpostgres1.1.7"
      set MYKITMK "tdbc1.1.7 itcl4.2.4 sqlite3.44.2 tdbcmysql1.1.7 tdbcodbc1.1.7 tdbcpostgres1.1.7"
    }
    foreach my [Get kit] {
      Run make MYCLI=$MYCLI MYGUI=$MYGUI MYVQ=$MYVQ MYKITVQ=$MYKITVQ MYMK=$MYMK MYKITMK=$MYKITMK MYKITBI=[Get bi] all-$my
    }
  }
  Install {foreach my [Get kit] {Run make install-$my}}
  Clean {Run make clean}
}
#@endverbatim
# @defgroup memchan
#@verbatim
Package memchan2.3 {
  Source {Wget http://prdownloads.sourceforge.net/memchan/Memchan2.3.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {Run make binaries}
  Install {
    Run make install-binaries
    Libdir Memchan2.3
  }
  Clean {Run make clean}
}
#@endverbatim
## @defgroup mentry
#@verbatim
Package mentry3.10 {
  Require {Use wcb3.5}
  Source {Wget http://www.nemethi.de/mentry/mentry3.10.tar.gz}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup mk4tcl
# 14/04/2024 Updated 
#@verbatim
Package mk4tcl2.4.9.7 {
  Source {
    #Wget https://github.com/jcw/metakit/tarball/2.4.9.7
    #Wget https://www.equi4.com/pub/mk/metakit-2.4.9.7.tar.gz
    Wget https://github.com/jnorthrup/metakit/archive/refs/heads/master.zip
    #Tgz [Get builddir-sys]/../sources/mk4tcl2.4.9.7
    #file delete -force [Get builddir-sys]/../sources/mk4tcl2.4.9.7
  }
}
  #Source {Wget http://equi4.com/pub/mk/metakit-2.4.9.7.tar.gz}
#@endverbatim
## @defgroup mk4tcl
# @bug Configure: CXXFLAGS wrong
# @bug Configure: include SunOS cc with problems on wide int
#@verbatim
Package mk4tcl2.4.9.7-static {
  Source {Link mk4tcl2.4.9.7}
  Configure {
    Patch [Get srcdir]/unix/Makefile.in 46 {CXXFLAGS = $(CXX_FLAGS)} {CXXFLAGS = -DSTATIC_BUILD $(CXX_FLAGS)}
    if {$::tcl_platform(os) == "SunOS" && [Get CC] == "cc"} {
      Patch [Get srcdir]/tcl/mk4tcl.h 9 "#include <tcl.h>\n\n" "#include <tcl.h>\n#undef TCL_WIDE_INT_TYPE\n"
    }
    Config [Get srcdir-sys]/unix --disable-shared --with-tcl=[Get builddir-sys]/include
  }
  Make {Run make tcl}
  Install {
    Run make install
    Libdir Mk4tcl
  }
}
#@endverbatim
## @defgroup nap
#@verbatim
Package nap7.0.0 {
  Source {Cvs tcl-nap.cvs.sourceforge.net:/cvsroot/tcl-nap -r nap-7-0-0 tcl-nap}
  Configure {Config [Get srcdir-sys]/[Get sys]}
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup nsf
# @bug tclCompile.h not found
#@verbatim
Package nsf2.0.0 {
  Source {Wget http://prdownloads.sourceforge.net/next-scripting/nsf2.0.0.tar.gz}
  Configure {
    Patch [Get srcdir]/Makefile.in 213 \
{INCLUDES	= @PKG_INCLUDES@ @TCL_INCLUDES@ @NSF_BUILD_INCLUDE_SPEC@
} "INCLUDES	= @PKG_INCLUDES@ @TCL_INCLUDES@ @NSF_BUILD_INCLUDE_SPEC@ -I@TCL_SRC_DIR@/generic -I[Get srcdir-sys]/generic
"
    Config [Get srcdir-sys]
  }
  Make {
#    Run make genstubs
    Run make
  }
  Install {Run make install}
  Clean {Run make clean}
}
Package nsf2.0b5 {
  Source {Wget http://prdownloads.sourceforge.net/next-scripting/nsf2.0b5.tar.gz}
  Configure {
    Patch [Get srcdir]/Makefile.in 195 \
{		  TCLLIBPATH="$(top_builddir) ${srcdir} $(TCLLIBPATH)"} \
{		  TCLLIBPATH="${srcdir} $(top_builddir) $(TCLLIBPATH)"}
    Patch [Get srcdir]/Makefile.in 201 \
{INCLUDES	= @PKG_INCLUDES@ @TCL_INCLUDES@ @NSF_BUILD_INCLUDE_SPEC@
} {INCLUDES	= @PKG_INCLUDES@ @TCL_INCLUDES@ @NSF_BUILD_INCLUDE_SPEC@ -I@TCL_SRC_DIR@/generic
}
    Config [Get srcdir-sys]
  }
  Make {Run make genstubs
    Run make
  }
  Install {Run make install}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup pdf4tcl
#@verbatim
Package pdf4tcl0.8.4 {
  Source {Wget http://prdownloads.sourceforge.net/pdf4tcl/pdf4tcl084.tar.gz}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup ral
#@verbatim
Package ral0.11.7 {
  Source {Wget http://prdownloads.sourceforge.net/tclral/tclral-0.11.7.tar.gz}
  Configure {
    Config [Get srcdir-sys]
  }
  Make {Run make binaries libraries}
  Install {Run make install-binaries install-libraries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup rbc
#@verbatim
Package rbc0.1 {
  Source {Svn https://svn.code.sf.net/p/rbctoolkit/code/trunk/rbc -r 49}
  Configure {
    proc MY {f} {
      set fd [open $f r];set c [read $fd];close $fd;
      regsub -all tkpWinRopModes $c tkpWinRopMode1 c
      regsub -all interp->result $c Tcl_GetString(Tcl_GetObjResult(interp)) c
      set fd [open $f w];puts $fd $c;close $fd;
    }
    MY [Get srcdir]/generic/rbcGrLine.c
    MY [Get srcdir]/generic/rbcTile.c
    MY [Get srcdir]/generic/rbcWinDraw.c
    MY [Get srcdir]/generic/rbcVecMath.c
    rename MY {}
    if {[Get sys] eq {unix}} {
      file attributes [Get srcdir]/tclconfig/install-sh -permissions u+x
    }
    Config [Get srcdir-sys]
  }
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup sdx
# Updated 14/04/2023
#@verbatim
Package sdx.kit {
  #Source {Wget http://prdownloads.sourceforge.net/kbskit/kbs/0.4.9/sdx-20110317.tgz}
  Source {Wget https://chiselapp.com/user/aspect/repository/sdx/uv/sdx-20110317.kit}
  Configure {}
  Install {file copy -force [Get srcdir]/sdx-20110317.kit [Get builddir]/bin/sdx.kit}
}

#sdx tool command
Package sdx {
  Require {Use sdx.kit}
  Source {Link sdx.kit}
  Configure {
	file copy -force [Get srcdir]/sdx-20110317.kit [Get builddir]/sdx/sdx.kit
  }
  Install {
	Kit sdx.kit -vq-cli
  }
}

#@endverbatim
## @defgroup snack
#@verbatim
Package snack2.2 {
  Source {Wget http://www.speech.kth.se/snack/dist/snack2.2.10.tar.gz}
  Configure {Config [Get srcdir-sys]/[Get sys] -libdir=[Get builddir-sys]/lib --includedir=[Get builddir-sys]/include}
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup tablelist
#@verbatim
Package tablelist6.21 {
  Source {Wget http://www.nemethi.de/tablelist/tablelist6.21.tar.gz}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup tcl
#@verbatim
Package tcl8.5 {
  Source {Wget http://prdownloads.sourceforge.net/tcl/tcl8.5.19-src.tar.gz}
  Configure {Config [Get srcdir-sys]/[Get sys]}
  Make {Run make}
  Install {Run make install-binaries install-libraries install-private-headers}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tcl
#@verbatim
Package tcl8.5-static {
  Source {Link tcl8.5}
  Configure {Config [Get srcdir-sys]/[Get sys] --disable-shared}
  Make {Run make}
  Install {Run make install-binaries install-libraries install-private-headers}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tcl
#@verbatim
Package tcl8.6 {
  Source {Wget https://sourceforge.net/projects/tcl/files/Tcl/8.6.14/tcl8.6.14-src.tar.gz}
  Configure {Config [Get srcdir-sys]/[Get sys]}
  Make {Run make}
  Install {Run make install install-private-headers}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tcl
#@verbatim
Package tcl8.6-static {
  Source {Link tcl8.6}
  Configure {Config [Get srcdir-sys]/[Get sys] --disable-shared}
  Make {Run make}
  Install {
    Run make install install-private-headers
#TODO siehe kbskit8.6
    if {[Get sys] eq {win}} {
      file copy -force [Get builddir]/tcl8.6-static/libtclstub86.a [Get builddir]/lib/libtclstub86s.a
      file copy -force [Get builddir]/tcl8.6-static/libtcl86.a [Get builddir]/lib/libtcl86s.a
    }
  }
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tcllib
#@verbatim
Package tcllib1.21 {
  Source {Wget http://prdownloads.sourceforge.net/tcllib/tcllib-1.21.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {}
  Install {Run make install-libraries}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tcloo
#@verbatim
Package tcloo0.6 {
  Source {Wget http://prdownloads.sourceforge.net/tcl/TclOO1.0.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {Run make}
  Install {
    Run make install install-private-headers
    Libdir TclOO1.0
  }
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tclx
#@verbatim
Package tclx8.4 {
  Source {Cvs tclx.cvs.sourceforge.net:/cvsroot/tclx -D 2010-10-28 tclx}
  Configure {Config [Get srcdir-sys]}
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup tdom
#@verbatim
Package tdom0.8.3 {
  Source {#Wget https://github.com/downloads/tDOM/tdom/tDOM-0.8.3.tgz
    Wget https://github.com/tDOM/tdom/tarball/8667ce5
    Tgz [glob -nocomplain [Get builddir-sys]/../sources/8667ce5*]
    file delete -force [glob -nocomplain [Get builddir-sys]/../sources/8667ce5*]
  }
  Configure {Config [Get srcdir-sys]}
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}

#@endverbatim
## @defgroup thread
#@verbatim
Package thread2.8.0 {
  Source {Wget http://prdownloads.sourceforge.net/tcl/thread2.8.0.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup thread
#@verbatim
Package thread2.8.0-static {
  Source {Link thread2.8.0}
  Configure {Config [Get srcdir-sys] --disable-shared}
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup thread
#@verbatim
Package thread2.8.9 {
  Source {Wget http://downloads.sourceforge.net/tcl/thread2.8.0.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup thread
#@verbatim
Package thread2.8.9-static {
  Source {Link thread2.8.9}
  Configure {Config [Get srcdir-sys] --disable-shared}
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup tk
#@verbatim
Package tk8.5 {
  Require {Use tcl8.5}
  Source {Wget http://prdownloads.sourceforge.net/tcl/tk8.5.19-src.tar.gz}
  Configure {Config [Get srcdir-sys]/[Get sys]}
  Make {Run make}
  Install {Run make install install-private-headers}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tk
#@verbatim
Package tk8.5-static {
  Require {Use tcl8.5-static}
  Source {Link tk8.5}
  Configure {Config [Get srcdir-sys]/[Get sys] --disable-shared}
  Make {Run make}
  Install {Run make install install-private-headers}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tk
#@verbatim
Package tk8.6 {
  Require {Use tcl8.6}
  Source {Wget https://sourceforge.net/projects/tcl/files/Tcl/8.6.14/tk8.6.14-src.tar.gz}
  Configure {
    if {$::tcl_platform(os) == "Darwin"} {
      set tkopt --enable-aqua
    } else {
      set tkopt ""
    }
    Config [Get srcdir-sys]/[Get sys] {*}$tkopt
  }
  Make {Run make}
  Install {Run make install install-private-headers}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tk
#@verbatim
Package tk8.6-static {
  Require {Use tcl8.6 tcl8.6-static}
  Source {Link tk8.6}
  Configure {
    if {$::tcl_platform(os) == "Darwin"} {
      set tkopt --enable-aqua
    } else {
      set tkopt ""
    }
    Config [Get srcdir-sys]/[Get sys] --disable-shared {*}$tkopt
  }
  Make {Run make}
  Install {Run make install install-private-headers
    if {[Get sys] eq {win}} {
      file copy -force [Get builddir]/tk8.6-static/libtkstub86.a [Get builddir]/lib/libtkstub86s.a
      file copy -force [Get builddir]/tk8.6-static/libtk86.a [Get builddir]/lib/libtk86s.a
    }
  }
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tkcon
#@verbatim
Package tkcon {
  Source {Cvs tkcon.cvs.sourceforge.net:/cvsroot/tkcon -D 2014-12-01 tkcon}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup tkdnd
#@verbatim
Package tkdnd2.7 {
  Source {Wget http://prdownloads.sourceforge.net/tkdnd/TkDND/TkDND%202.7/tkdnd2.7-src.tar.gz}
  Configure {
    # fix bogus garbage collection flag
    Patch [Get srcdir]/configure 8673 
    {    PKG_CFLAGS="$PKG_CFLAGS -DMAC_TK_COCOA -std=gnu99 -x objective-c -fobjc-gc"} {\
    PKG_CFLAGS="$PKG_CFLAGS -DMAC_TK_COCOA -std=gnu99 -x objective-c"}
    Config [Get srcdir-sys]
  }
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
  Test {Run make test}
}
Package tkdnd2.8 {
  Source {Wget http://prdownloads.sourceforge.net/tkdnd/TkDND/TkDND%202.8/tkdnd2.8-src.tar.gz}
  Configure {
    # fix bogus garbage collection flag
    Patch [Get srcdir]/configure 6148 {    PKG_CFLAGS="$PKG_CFLAGS -DMAC_TK_COCOA -std=gnu99 -x objective-c -fobjc-gc"} {\
    PKG_CFLAGS="$PKG_CFLAGS -DMAC_TK_COCOA -std=gnu99 -x objective-c"}
    Config [Get srcdir-sys]
  }
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tklib
# @todo  Source {Wget http://core.tcl.tk/tklib/tarball/tklib-0.6.tar.gz?uuid=tklib-0-6}
#@verbatim
#TODO  Source {Wget https://github.com/tcltk/tklib/archive/841659f114803b4c9dc186704af6a7f64515c45c.zip}
Package tklib0.6 {
  Source {Wget https://core.tcl.tk/tklib/tarball/tklib-0.6.tar.gz?uuid=tklib-0-6}
  Configure {Config [Get srcdir-sys]}
  Make {}
  Install {Run make install-libraries}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup tksqlite
#@verbatim
Package tksqlite0.5.13 {
  Require {Use kbskit8.6 sdx.kit tktable2.10 treectrl2.4.1 img1.4.6}
  Source {Wget http://reddog.s35.xrea.com/software/tksqlite-0.5.13.tar.gz}
  Configure {
    Kit {source $::starkit::topdir/tksqlite.tcl} Tk
  }
  Make {Kit tksqlite sqlite3.44.2 tktable2.10 treectrl2.4.1 img1.4.6}
  Install {Kit tksqlite -vq-gui}
  Clean {file delete -force tksqlite.vfs}
  Test {Kit tksqlite}
}
#@endverbatim
## @defgroup tkpath
#@verbatim
Package tkpath0.3.3 {
  Source {Wget http://prdownloads.sourceforge.net/kbskit/kbs/0.4.9/tkpath0.3.3.tgz}
  Configure {
    file copy -force [Get srcdir]/../tk8.6/win/tkWinDefault.h [Get builddir]/include
    file copy -force [Get srcdir]/../tk8.6/unix/tkUnixDefault.h [Get builddir]/include
    file copy -force [Get srcdir]/../tk8.6/macosx/tkMacOSXDefault.h [Get builddir]/include
    Config [Get srcdir-sys]
  }
  Make {Run make binaries libraries}
  Install {Run make install-binaries install-libraries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup tktable
#@verbatim
Package tktable2.10 {
  Source {Cvs tktable.cvs.sourceforge.net:/cvsroot/tktable -r tktable-2-10-0 tktable}
  Configure {
    Patch [Get srcdir]/generic/tkTable.h 21 {#include <tk.h>} {#include <tkInt.h>}
    Config [Get srcdir-sys]
  }
  Make {Run make binaries}
  Install {
    Run make install-binaries
    Libdir Tktable2.10
  }
  Clean {Run make clean}
}
#@endverbatim
## @defgroup tls
#@verbatim
Package tcltls1.7.22 {
  Source {Wget https://core.tcl-lang.org/tcltls/uv/tcltls-1.7.22.tar.gz}
  Configure {
    # Patch [Get srcdir]/Makefile.in 13 \
    #   {PACKAGE_INSTALL_DIR = $(TCL_PACKAGE_PATH)/tcltls$(PACKAGE_VERSION)} \
    #   {PACKAGE_INSTALL_DIR = $(TCL_PACKAGE_PATH)/tls$(PACKAGE_VERSION)}
    Config [Get srcdir-sys]  --enable-ssl-fastpath --with-tcl=[Get builddir-sys]/tcl8.6}
  Make {Run make}
  Install {Run make install}
  Clean {Run make clean}
  Test {Run make test}
}
#@endverbatim
## @defgroup treectrl
# @todo Error in configure: tk header default.h not found
#@verbatim
Package treectrl2.4.1 {
  Source {Wget http://prdownloads.sourceforge.net/sourceforge/tktreectrl/tktreectrl-2.4.1.tar.gz}
  Configure {
	# fix bogus garbage collection flag
    Patch [Get srcdir]/configure 6430 {    PKG_CFLAGS="$PKG_CFLAGS -DMAC_TK_COCOA -std=gnu99 -x objective-c -fobjc-gc"} {\
    PKG_CFLAGS="$PKG_CFLAGS -DMAC_TK_COCOA -std=gnu99 -x objective-c"}
	# fix wrong detection of Tk private headers
    Patch [Get srcdir]/configure 5492 {	-f "${ac_cv_c_tkh}/tkWinPort.h"; then} {""; then}
    Patch [Get srcdir]/configure 5495 {	-f "${ac_cv_c_tkh}/tkUnixPort.h"; then} {""; then}
    Config [Get srcdir-sys]
  }
  Make {Run make}
  Install {Run make install-binaries install-libraries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup trofs
#@verbatim
Package trofs0.4.6 {
  Source {Wget http://math.nist.gov/~DPorter/tcltk/trofs/trofs0.4.6.tar.gz}
  Configure {
    Patch [Get srcdir]/Makefile.in 148 \
{DEFS		= @DEFS@ $(PKG_CFLAGS)} \
{DEFS		= @DEFS@ $(PKG_CFLAGS) -D_USE_32BIT_TIME_T}
    Config [Get srcdir-sys]
  }
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
Package trofs0.4.9 {
  Source {Wget http://math.nist.gov/~DPorter/tcltk/trofs/trofs0.4.9.tar.gz}
  Configure {
    Config [Get srcdir-sys]
  }
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup udp
#@verbatim
Package udp1.0.8 {
  Source {Cvs tcludp.cvs.sourceforge.net:/cvsroot/tcludp -r tcludp-1_0_8 tcludp}
  Configure {
    if {[Get sys] eq {unix}} {
      file attributes [Get srcdir]/tclconfig/install-sh -permissions u+x
    }
    Config [Get srcdir-sys]
  }
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
Package udp1.0.11 {
  Source {Wget http://prdownloads.sourceforge.net/sourceforge/tcludp/1.0.11/tcludp-1.0.11.tar.gz}
  Configure {
    Config [Get srcdir-sys]
  }
  Make {Run make binaries}
  Install {Run make install-binaries}
  Clean {Run make clean}
}


Package vfs1.4.2 {
  Source {Wget https://core.tcl-lang.org/tclvfs/zip/8cdab08997/tclvfs-8cdab08997.zip}
  Configure {
    Config [Get srcdir-sys] --with-tclinclude=[Get builddir-sys]/include
  }
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}

Package vfs1.4.2-static {
  Source {Link vfs1.4.2}
  Configure {
    Config [Get srcdir-sys] --disable-shared --with-tclinclude=[Get builddir-sys]/include}
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}



#@endverbatim
## @defgroup vfs
#@verbatim
Package vfs1.4 {
  Source {Wget http://prdownloads.sourceforge.net/kbskit/kbs/0.4.9/vfs1.4.tgz}
  Configure {
    Config [Get srcdir-sys] --with-tclinclude=[Get builddir-sys]/include
  }
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}

#@endverbatim
## @defgroup vfs
#@verbatim
Package vfs1.4-static {
  Source {Link vfs1.4}
  Configure {
    Config [Get srcdir-sys] --disable-shared --with-tclinclude=[Get builddir-sys]/include}
  Make {Run make}
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup vqtcl
#@verbatim
Package vqtcl4.1 {
  Source {Wget http://prdownloads.sourceforge.net/kbskit/kbs/0.4.9/vqtcl4.1.tgz}
}
#@endverbatim
## @defgroup vqtcl
# @bug Configure: big endian problem
#@verbatim
Package vqtcl4.1-static {
  Source {Link vqtcl4.1}
  Configure {Config [Get srcdir-sys] --disable-shared}
  Make {
    set MYFLAGS "-D__[exec uname -p]__"
    Run make PKG_CFLAGS=$MYFLAGS
  }
  Install {Run make install-binaries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup wcb
#@verbatim
Package wcb3.5 {
  Source {Wget http://www.nemethi.de/wcb/wcb3.5.tar.gz}
  Configure {}
  Install {Tcl}
}
#@endverbatim
## @defgroup xotcl
#@verbatim
Package xotcl1.6.8 {
  Source {Wget http://media.wu-wien.ac.at/download/xotcl-1.6.8.tar.gz}
  Configure {Config [Get srcdir-sys]}
  Make {Run make binaries libraries}
  Install {Run make install-binaries install-libraries}
  Clean {Run make clean}
}
#@endverbatim
## @defgroup zlib
#@verbatim
Package zlib1.2.8 {
  Source {Wget http://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.gz}
}
#@endverbatim
## @defgroup zlib
#@verbatim
Package zlib1.2.8-static {
  Source {Link zlib1.2.8}
  Configure {
    eval file copy [glob [Get srcdir]/*] .
    if {$::tcl_platform(platform) ne {windows}} {
      set MYFLAGS "[Get TCL_EXTRA_CFLAGS] [Get TCL_CFLAGS_OPTIMIZE]"
      Run env CC=[Get CC] CFLAGS=$MYFLAGS ./configure --prefix=[Get builddir-sys] --eprefix=[Get builddir-sys]
    }
  }
  Make {
    if {$::tcl_platform(platform) eq {windows}} {
      Run env BINARY_PATH=[Get builddir]/bin INCLUDE_PATH=[Get builddir]/include LIBRARY_PATH=[Get builddir]/lib make -fwin32/Makefile.gcc
    } else {
      Run make
    }
  }
  Install {
    if {$::tcl_platform(platform) eq {windows}} {
      Run env BINARY_PATH=[Get builddir]/bin INCLUDE_PATH=[Get builddir]/include LIBRARY_PATH=[Get builddir]/lib make -fwin32/Makefile.gcc install
    } else {
      file mkdir [file join [Get builddir]/share/man]
      Run make install
    }
  }
  Clean {Run make clean}
}
#@endverbatim
## @defgroup tango
#@verbatim
Package tango0.8.90 {
  Source {
    Wget http://tango.freedesktop.org/releases/tango-icon-theme-0.8.90.tar.gz
  }
}
#@endverbatim
## @defgroup silkicons
#@verbatim
Package silkicons1.3 {
  Source {Wget http://www.famfamfam.com/lab/icons/silk/famfamfam_silk_icons_v013.zip}
}
#@endverbatim
##@verbatim
Package vectcl0.2 {
   Require {Use tcl8.6}
   Source {Wget https://github.com/auriocus/VecTcl/archive/v0.2.tar.gz}
   Configure {
     Config [Get srcdir-sys]
   }
   Make {Run make}
   Install {Run make install}
   Clean {Run make clean}
   Test {Run make test}
}
#@endverbatim
#@verbatim
Package ukaz0.2 {
   Source {Wget https://github.com/auriocus/ukaz/archive/v0.2.tar.gz}
   Configure {}
   Install {Tcl}
}
#@endverbatim
#@verbatim
Package vectcltk0.2 {
   Require {Use tk8.6 vectcl0.2}
   Source {Link vectcl0.2}
   Configure {
     Config [Get srcdir-sys]/TkBridge
   }
   Make {Run make}
   Install {Run make install}
   Clean {Run make clean}
   Test {Run make test}
}

#@endverbatim
## @defgroup kkgkit
#@verbatim
# kkgkit is a copy of kbskit0.4 with changed tcl.rc and tclkit.ico
# rbc0.1 rbcGrAxis.c DEF_NUM_TICKS 10 (old=4)
# tk8.6/generic/ttk/ttkProgress.c patched
# tk8.6/library/ttk/vistaTheme.tcl patched
Package kkgkit0.2 {
  Require {
    Use sdx.kit
    Use tk8.6-static tk8.6 vfs1.4-static rbc0.1 tkpath0.3.3 pdf4tcl0.8.4 tkdnd2.8
    if {[lsearch -glob [Get kit] {vq*}] != -1} { Use vqtcl4.1-static }
  }
  Source {Script {}}
  Configure {Config [Get srcdir-sys] --disable-shared}
  Make {
    if {$::tcl_platform(platform) == "windows"} {
      set MYCLI "[Get builddir-sys]/lib/libtcl86s.a"
      append MYCLI " [Get builddir-sys]/lib/vfs1.4.1/vfs141.a"
      set MYGUI "[Get builddir-sys]/lib/libtk86s.a"
      set MYVQ "[Get builddir-sys]/lib/vqtcl4.1/vqtcl41.a [Get builddir-sys]/lib/libtclstub86s.a"
    } else {
      set MYCLI "[Get builddir-sys]/lib/libtcl8.6.a"
      append MYCLI " [Get builddir-sys]/lib/vfs1.4.1/libvfs1.4.1.a"
      set MYGUI "[Get builddir-sys]/lib/libtk8.6.a"
      set MYVQ "[Get builddir-sys]/lib/vqtcl4.1/libvqtcl4.1.a [Get builddir-sys]/lib/libtclstub8.6.a"
    }
    if {[Get -threads] in {--enable-threads --enable-threads=yes {}}} {
      set MYKITVQ "thread2.8.9 tdbc1.1.7 sqlite3.44.2 tdbcodbc1.0.4 rbc0.1 tkpath0.3.3 pdf4tcl0.8.4 tkdnd2.8"
    } else {
      set MYKITVQ "tdbc1.1.7 sqlite3.44.2 tdbcodbc1.0.4 rbc0.1 tkpath0.3.3 pdf4tcl0.8.4 tkdnd2.8"
    }
    file delete -force [Get builddir]/lib/tk8.6/demos
    file delete -force [Get builddir]/lib/rbc0.1/demos
    foreach my [Get kit] {
      Run make MYCLI=$MYCLI MYGUI=$MYGUI MYVQ=$MYVQ MYKITVQ=$MYKITVQ all-$my
    }
  }
  Install {foreach my [Get kit] {Run make install-$my}}
  Clean {Run make clean}
}
#@endverbatim
## @}
}

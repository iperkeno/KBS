#! /bin/sh
##
# @file kbs.tcl
#	Kitgen Build System
# @mainpage
# @synopsis{kbs.tcl ?-option? .. ?command? ..}
#
# For available options and commands see help() or type './kbs.tcl help'.
# Online documentation can be found at http://wiki.tcl.tk/18146
#
# The following common commands are supported:
#	- @b help	see help()
#	- @b doc	see doc()
#	- @b license	see license()
#	- @b config	see config()
#	- @b gui	see gui()
#
# The following package related commands are supported:
#	- @b require	see require()
#	- @b sources	see sources()
#	- @b make	see make()
#	- @b install	see install()
#	- @b clean	see clean()
#	- @b test	see test()
#	- @b distclean	see distclean()
#
# Tcl/Tk software building environment.
# Build of starpacks, starkits, binary extensions and other software.
# Already existing package definitions can be found under Package.
#
# @examples
# @call{get brief help text,./kbs.tcl
#tclsh ./kbs.tcl}
# @call{get full documentation in ./doc/kbs.html,./kbs.tcl doc}
# @call{start in graphical mode,./kbs.tcl gui}
# @call{build batteries included kbskit interpreter,./kbs.tcl -r -vq-bi install kbskit8.5}
# @call{get list of available packages,./kbs.tcl list}
#
# @author <jcw@equi4.com> Initial ideas and kbskit sources
# @author <r.zaumseil@freenet.de> kbskit TEA extension and development
#
# @version 0.4.9
#
# @copyright 
#	Call './kbs.tcl license' or search for 'set ::kbs(license)' in this file
#	for information on usage and redistribution of this file,
#	and for a DISCLAIMER OF ALL WARRANTIES.
#
# Startup code:
#@verbatim

# check startup dir containing current file\
if test ! -r ./kbs.tcl ; then \
  echo "Please start from directory containing the file 'kbs.tcl'"; exit 1 ;\
fi;

# bootstrap for building wish.. \
if test "`pwd`" = "/" ; then \
PREFIX=/`uname` ;\
else \
PREFIX=`pwd`/`uname` ;\
fi ;\
TKOPT="" ;\
case `uname` in \
  MINGW*) DIR="win"; EXE="${PREFIX}/bin/tclsh86s.exe" ;; \
  Darwin*) DIR="unix"; EXE="${PREFIX}/bin/tclsh8.6" ; TKOPT="--enable-aqua" ;; \
  *) DIR="unix"; EXE="${PREFIX}/bin/tclsh8.6" ;; \
esac ;\
if test ! -d sources ; then mkdir sources; fi;\
if test ! -x ${EXE} ; then \
  if test ! -d sources/tcl8.6 ; then \
    ( cd sources && wget http://prdownloads.sourceforge.net/tcl/tcl8.6.6-src.tar.gz && gunzip -c tcl8.6.6-src.tar.gz | tar xf - && rm tcl8.6.6-src.tar.gz && mv tcl8.6.6 tcl8.6 ) ; \
  fi ;\
  if test ! -d sources/tk8.6 ; then \
    ( cd sources && wget http://prdownloads.sourceforge.net/tcl/tk8.6.6-src.tar.gz && gunzip -c tk8.6.6-src.tar.gz | tar xf - && rm tk8.6.6-src.tar.gz && mv tk8.6.6 tk8.6 ) ; \
  fi ;\
  mkdir -p ${PREFIX}/tcl ;\
  ( cd ${PREFIX}/tcl && ../../sources/tcl8.6/${DIR}/configure --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX} && make install-binaries install-libraries ) ;\
  rm -rf ${PREFIX}/tcl ;\
  mkdir -p ${PREFIX}/tk ;\
  ( cd ${PREFIX}/tk && ../../sources/tk8.6/${DIR}/configure --enable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX} --with-tcl=${PREFIX}/lib $TKOPT && make install-binaries install-libraries ) ;\
fi ;\
exec ${EXE} "$0" ${1+"$@"}

#@endverbatim
#===============================================================================
catch {wm withdraw .};# do not show toplevel in command line mode

##	Array variable with static informations.
#	- @b version	current version and version of used kbskit
#	- @b license	license information
variable ::kbs
set ::kbs(version) {0.4.9};# current version and version of used kbskit

#===============================================================================

##	This namespace contain the external callable functions.
namespace eval ::kbs {
  namespace export help version kbs list gui
  namespace export require source configure make install clean distclean
}
#-------------------------------------------------------------------------------

#source kbs-license.tcl    ;# load KBS license definition
set ::kbs(license) [read [open "kbs-license" r]]


##	Display license information.
# @examples
# @call{display license information,./kbs.tcl license}
proc ::kbs::license {} {
  puts $::kbs(license)
}
#-------------------------------------------------------------------------------

source kbs-help.tcl       ;# load KBS help definition

##	Display usage help message.
# @note	This is also the default action if no command was given.
# @examples
# @call{display usage help message,./kbs.tcl help}
proc ::kbs::help {} {
  puts "[::kbs::build::Get application]"
  puts $::kbs(help)
}
#-------------------------------------------------------------------------------

##	Create documentation from source file.
# @examples
# @call{create public documentation,./kbs.tcl doc}
proc ::kbs::doc {} {
  set myPwd [pwd]
  if {![file readable kbs.tcl]} {error "missing file ./kbs.tcl"}
  file mkdir doc
  set myFd [open Doxyfile w]
  puts $myFd "PROJECT_NUMBER		= [clock format [clock seconds] -format {%Y%m%d}]"
  puts $myFd {
PROJECT_NAME		= "Kitgen Build System"
OUTPUT_DIRECTORY	= ./doc
JAVADOC_AUTOBRIEF	= YES
QT_AUTOBRIEF		= YES
ALIASES			=
ALIASES += copyright="\par Copyright:"
ALIASES += examples="\par Examples:"
ALIASES += synopsis{1}="\par Synopsis:\n@verbatim \1 @endverbatim"
ALIASES += call{2}="\1 @verbatim \2 @endverbatim"
EXTRACT_ALL		= NO
INPUT			= kbs.tcl
SOURCE_BROWSER		= YES
INLINE_SOURCES		= YES
STRIP_CODE_COMMENTS	= NO
GENERATE_TREEVIEW	= YES
GENERATE_LATEX    = NO
}
  close $myFd
  exec $::kbs::build::_(exec-doxygen)
}
#-------------------------------------------------------------------------------

##	Display names and values of configuration variables useable with 'Get'.
# @examples
# @call{display used values,./kbs.tcl config}
proc ::kbs::display-config {} {
  foreach myName [lsort [array names ::kbs::build::_]] {
    puts [format {%-20s = %s} "\[Get $myName\]" [::kbs::build::Get $myName]]
  }
}

#===============================================================================
source kbs-gui.tcl

##	Start graphical user interface.
# @examples
# @call{simple start with default options,./kbs.tcl gui}
# 
# @param[in] args	currently not used
proc ::kbs::gui {args} {
  ::kbs::gui::_init $args
}
#-------------------------------------------------------------------------------

##	Print available packages.
# @examples
# @call{list all packages starting with 'kbs',./kbs.tcl list kbs\*}
# @call{list all definitions of packages starting with 'kbs',./kbs.tcl list kbs\* Package}
# @call{list specific definition parts of packages starting with 'kbs',./kbs.tcl list kbs\* Require Source}
# 
# @param[in] pattern	global search pattern for packages name (default '*')
# @param[in] args	which part should be printed (default all)
proc ::kbs::list {{pattern *} args} {
  if {$args eq {}} {
    puts [lsort -dict [array names ::kbs::build::packagescript $pattern]]
  } else {
    foreach myPkg [lsort -dict [array names ::kbs::build::packagescript $pattern]] {
      set myName	""
      set myVersion	""
      foreach myChar [split $myPkg {}] {
      if {$myVersion == "" && [string match {[A-Za-z_} $myChar]} {
        append myName $myChar
        } else {
        append myVersion $myChar
        }
      }
      puts "## @page	$myName\n# @version	$myVersion\n#@verbatim\nPackage $myPkg {"
      foreach {myCmd myScript} $::kbs::build::packagescript($myPkg) {
        if {$args eq {Package} || [lsearch $args $myCmd] >= 0} {
          puts "  $myCmd {$myScript}"
        }
      }
      puts "}\n#@endverbatim\n#-------------------------------------------------------------------------------"
    }
  }
}
#-------------------------------------------------------------------------------

##	Call the 'Require' part of the package definition.
#	Can be used to show dependencies of packages.
# @examples
# @call{show dependencies of package,./kbs.tcl -r require kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::require {args} {
  ::kbs::build::_init {Require} $args
}
#-------------------------------------------------------------------------------

##	Call the 'Require' and 'Source' part of the package definition
#	to get the sources of packages.
#	Sources are installed under './sources/'.
# @examples
# @call{get the sources of a package,./kbs.tcl sources kbskit8.5}
# @call{get the sources of a package and its dependencies,./kbs.tcl -r sources kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::sources {args} {
  ::kbs::build::_init {Require Source} $args
}
#-------------------------------------------------------------------------------

##	Call the 'Require', 'Source' and 'Configure' part of the package
#	definition. The configuration is done in 'makedir'.
# @examples
# @call{configure the package,./kbs.tcl configure kbskit8.5}
# @call{configure the package and its dependencies,./kbs.tcl -r configure kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::configure {args} {
  ::kbs::build::_init {Require Source Configure} $args
}
#-------------------------------------------------------------------------------

##	Call the 'Require', 'Source', 'Configure' and 'Make' part of the
#	package definition. The build is done in 'makedir'.
# @examples
# @call{make the package,./kbs.tcl make kbskit8.5}
# @call{make the package and its dependencies,./kbs.tcl -r make kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::make {args} {
  ::kbs::build::_init {Require Source Configure Make} $args
}
#-------------------------------------------------------------------------------

##	Call the 'Require', 'Source', 'Make' and 'Test' part of the package
#	definition. The testing starts in 'makedir'
# @examples
# @call{test the package,./kbs.tcl test kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::test {args} {
  ::kbs::build::_init {Require Source Make Test} $args
}
#-------------------------------------------------------------------------------

##	Call the 'Require', 'Source', 'Configure', 'Make' and 'Install' part of
#	the package definition. The install dir is 'builddir'.
# @examples
# @call{install the package,./kbs.tcl install kbskit8.5}
# @call{install the package and its dependencies,./kbs.tcl -r install kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::install {args} {
  ::kbs::build::_init {Require Source Configure Make Install} $args
}
#-------------------------------------------------------------------------------

##	Call the 'Clean' part of the package definition.
#	The clean starts in 'makedir'.
# @examples
# @call{clean the package,./kbs.tcl clean kbskit8.5}
# @call{clean the package and its dependencies,./kbs.tcl -r clean kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::clean {args} {
  ::kbs::build::_init {Clean} $args
}
#-------------------------------------------------------------------------------

##	Remove the 'makedir' of the package so everything can be rebuild again.
#	This is necessary if there are problems in the configuration part of
#	the package.
# @examples
# @call{remove the package,./kbs.tcl distclean kbskit8.5}
# @call{remove the package and its dependencies,./kbs.tcl -r distclean kbskit8.5}
# 
# @param[in] args	list of packages
proc ::kbs::distclean {args} {
  # save old body
  set myBody [info body ::kbs::build::Source]
  proc ::kbs::build::Source [info args ::kbs::build::Source] {
    set myDir [Get makedir]
    if {[file exist $myDir]} {
      puts "=== Distclean: $myDir"
      file delete -force $myDir
    }
  }
  ::kbs::build::_init {Require Source} $args
  # restore old body
  proc ::kbs::build::Source [info args ::kbs::build::Source] $myBody
}

#===============================================================================
##	Contain internally used functions and variables.
namespace eval ::kbs::build {
  namespace export Run Get  Require Source Configure Make Install Clean 
  namespace export Patch PatchFile Test

##	Internal variable containing top level script directory.
  variable maindir [file normalize [file dirname [info script]]]

##	Internal variable with parsed package definitions from *.kbs files.
#       'Include' parts are resolved.
  variable packages

##	Internal variable with original package definitions from *.kbs files.
  variable packagescript

##	Internal variable containing current package name.
  variable package

##	Internal variable containing list of already prepared packages.
  variable ready [list]

##	If set (-i or -ignore switch) then proceed in case of errors.
# @examples
# @call{try to build all given packages,
#./kbs.tcl -i install bwidget\* mentry\*
#./kbs.tcl -ignore install bwidget\* mentry\*
# }
  variable ignore
  set ignore 0

##	If set (-r or -recursive switch) then all packages under 'Require'
#	are also used.
# @examples
# @call{build all packages recursively,
#./kbs.tcl -r install kbskit8.5
#./kbs.tcl -recursive install kbskit8.5
# } 
  variable recursive
  set recursive 0

##	If set (-v or -verbose switch) then all stdout will be removed.
#
# @examples
# @call{print additional information while processing,
#./kbs.tcl -v -r install bwidget\*
#./kbs.tcl -verbose -r install bwidget\*
# }
  variable verbose
  set verbose 0

##	Define startup kbs package definition file.
#	Default is empty and use only internal definitions.
# @examples
# @call{start with own package definition file,./kbs.tcl -pkgfile=/my/package/file list}
  variable pkgfile
  set pkgfile {}

##	The array variable '_' contain usefull information of the current building
#	process. All variables are provided with default values.
#	Changing of the default values can be done in the following order:
#	- file '$(HOME)/.kbsrc' and file './kbsrc' -- Lines starting with '#'
#	  are treated as comments and removed. All other lines are concatenated
#	  and used as command line arguments.
#	- environment variable 'KBSRC' -- The contents of this variable is used
#	  as command line arguments.
#	- command line 
#	It is also possible to set values in the 'Package' definition file
#	outside the 'Package' definition (p.e. 'set ::kbs::build::_(CC) g++').
# @examples
# @call{build debugging version,./kbs.tcl -CC=/my/cc --enable-symbols install tclx8.4}
# @call{create kbsmk8.5-[cli|dyn|gui] interpreter,./kbs.tcl -mk install kbskit8.5}
# @call{create kbsvq8.5-bi interpreter with packages,./kbs.tcl -vq-bi -bi="tclx8.4 tdom0.8.2" install kbskit8.5}
# @call{get list of available packages with,./kbs.tcl list}
# 
  variable _
  if {[info exist ::env(CC)]} {;# used compiler
    set _(CC)		$::env(CC)
  } else {
    set _(CC)		{gcc}
  }
  if {$::tcl_platform(platform) eq {windows}} {;# configuration system subdir
    set _(sys)		{win}
  } else {
    set _(sys)		{unix}
  }
  set _(exec-make)	  [lindex "[auto_execok gmake] [auto_execok make] make" 0]
  set _(exec-cvs)	    [lindex "[auto_execok cvs] cvs" 0]
  set _(exec-svn)	    [lindex "[auto_execok svn] svn" 0]
  set _(exec-tar)	    [lindex "[auto_execok tar] tar" 0]
  set _(exec-gzip)	  [lindex "[auto_execok gzip] gzip" 0]
  set _(exec-bzip2)	  [lindex "[auto_execok bzip2] bzip2" 0]
  set _(exec-git)	    [lindex "[auto_execok git] git" 0]
  set _(exec-unzip)	  [lindex "[auto_execok unzip] unzip" 0]
  set _(exec-wget)	  [lindex "[auto_execok wget] wget" 0]
  set _(exec-curl)	  [lindex "[auto_execok curl] curl" 0]
  set _(exec-autoconf) [lindex "[auto_execok autoconf] autoconf" 0]
  set _(exec-patch)	  [lindex "[auto_execok patch] patch" 0]
  set _(exec-doxygen)	[lindex "[auto_execok doxygen] doxygen" 0]
  set _(kitcli)		    {}
  set _(kitdyn)		    {}
  set _(kitgui)       {}
  set _(kit)		      [list];# list of interpreters to build
  set _(bi)		        [list];# list of packages for batteries included builds
  set _(staticstdcpp)	1;# build with static libstdc++
  set _(makedir)	    {};# package specific build dir
  set _(makedir-sys)	{};# package and system specific build dir
  set _(srcdir)		    {};# package specific source dir
  set _(srcdir-sys)	  {};# package and system specific source dir
  set _(builddir)	    [file join $maindir build[string map {{ } {}} $::tcl_platform(os)]]
  set _(builddir-sys)	$_(builddir)
  set _(application)	"Kitgen build system ($::kbs(version))";# application name
}   ;# end of ::kbs::build
#-------------------------------------------------------------------------------

##	Return platfrom specific file name p.e. windows C:\... -> /...
# @param[in] file	file name to convert
proc ::kbs::build::_sys {file} {
  if {$::tcl_platform(platform) eq {windows} && [string index $file 1] eq {:}} {
    return "/[string tolower [string index $file 0]][string range $file 2 end]"
  } else {
    return $file
  }
}

##  Not used
proc ::kbs::build::nativepath {p} {
	variable _
	if {$_(sys) eq "win"} {
		return [exec cygpath -w $p]
	} else {
		return $p
	}
}

#-------------------------------------------------------------------------------

## Initialize variables with respect to given configuration options and commands.
#	Process command in separate interpreter.
#
# @param[in] used	list of available commands
# @param[in] list	list of packages
proc ::kbs::build::_init {used pck_list} {
  variable packages
  variable package
  variable ignore
  variable interp

  # reset to clean state
  variable ready	[list]
  variable _
  array unset _ TCL_*
  array unset _ TK_*

  # create interpreter with used commands, not used are void functions.
  lappend used Run Get Patch PatchFile
  set interp [interp create]
  foreach myProc [namespace export] {
    if {$myProc in $used} {
      interp alias $interp $myProc {} ::kbs::build::$myProc
    } else {
      $interp eval [list proc $myProc [info args ::kbs::build::$myProc] {}]
    }
  }
  # now process command
  foreach myPattern $pck_list {
    set myTargets [array names packages $myPattern]
    if {[llength $myTargets] == 0} {
      return -code error "no targets found for pattern: '$myPattern'"
    }
    foreach package $myTargets {
      set _(makedir) [file join $_(builddir) $package]
      set _(makedir-sys) [file join $_(builddir-sys) $package]
      puts "=== Package eval: $package"
      if {[catch {$interp eval $packages($package)} myMsg]} {
        if {$ignore == 0} {
          interp delete $interp
	        set interp {}
          return -code error "=== Package failed for: $package\n$myMsg"
        }
        puts "=== Package error: $myMsg"
      }
      puts "=== Package done: $package"
    }
  }
  interp delete $interp
  set interp {}
}
#-------------------------------------------------------------------------------

##	The 'Package' command is available in definition files.
#	All 'Package' definitions will be saved for further use.
# @synopsis{Package name script}
#
# @param[in] name	unique name of package
# @param[in] script	contain one or more of the following definitions.
#		The common functions 'Run', 'Get' and 'Patch' can be used in
#		every 'script'. For a detailed description and command specific
#		additional functions look in the related commands.
#	'Require script'   -- define dependencies
#	'Source script'    -- method to get sources
#	'Configure script' -- configure package
#	'Make script'      -- build package
#	'Install script'   -- install package
#	'Clean script'     -- clean package
#	Special commands:
#	'Include package'  -- include current 'package' script. The command
#	use the current definitions (snapshot semantic).
proc ::kbs::build::Package {name script} {
  variable packages
  variable packagescript

  set packagescript($name) $script
  array set myTmp $script
  if {[info exists myTmp(Include)]} {
    array set myScript $packages($myTmp(Include))
  }
  if {[info exist packages($name)]} {
    array set myScript $packages($name)
  }
  array set myScript $script
  set packages($name) {}
  foreach myCmd {Require Source Configure Make Install Clean Test} {
    if {[info exists myScript($myCmd)]} {
      append packages($name) [list $myCmd $myScript($myCmd)]\n
    }
  }
}
#-------------------------------------------------------------------------------

##	Evaluate the given script.
#	Add additional packages with the 'Use' function.
# @synopsis{Require script}
#
#  @param script	containing package dependencies.
#	Available functions are: 'Run', 'Get', 'Patch'
#	'Use ?package..?' -- see Require-Use()
proc ::kbs::build::Require {script} {
  variable recursive
  if {$recursive == 0} return
  variable verbose
  variable interp
  variable package

  puts "=== Require $package"
  if {$verbose} {puts $script}
  interp alias $interp Use {} ::kbs::build::Require-Use
  $interp eval $script
  foreach my {Use} {interp alias $interp $my}
}

#-------------------------------------------------------------------------------

##	Define dependencies used with '-r' switch.
#	The given 'Package's in args will then be recursively called.
# @synopsis{Use ?package? ..}
#
# @param[in] args	one or more 'Package' names
proc ::kbs::build::Require-Use {args} {
  variable packages
  variable ready
  variable package
  variable ignore
  variable interp
  variable _
  puts "=== Require $args"

  set myPackage $package
  set myTargets [list]
  foreach package $args {
    # already loaded
    if {[lsearch $ready $package] != -1} continue
    # single target name
    if {[info exist packages($package)]} {
      set _(makedir) [file join $_(builddir) $package]
      set _(makedir-sys) [file join $_(builddir-sys) $package]
      puts "=== Require eval: $package"
      array set _ {srcdir {} srcdir-sys {}}
      if {[catch {$interp eval $packages($package)} myMsg]} {
        puts "=== Require error: $package\n$myMsg"
        if {$ignore == 0} {
          return -code error "Require failed for: $package"
        }
        foreach my {Link Cvs Svn Git Tgz Tbz2 Zip Http Wget Script Kit Tcl Libdir} {
          interp alias $interp $my;# clear specific procedures
        }
      }
      puts "=== Require done: $package"
      lappend ready $package
      continue
    }
    # nothing found
    return -code error "Require not found: $package"
  }
  set package $myPackage
  set _(makedir) [file join $_(builddir) $package]
  set _(makedir-sys) [file join $_(builddir-sys) $package]
  puts "=== Require leave: $args"
}
#-------------------------------------------------------------------------------

##	Procedure to build source tree of current 'Package' definition.
# @synopsis{Source script}
#
# @param[in] script	one or more of the following functions to get the sources
#		of the current package. The sources should be placed under
#		'./sources/'.
#	Available functions are: 'Run', 'Get', 'Patch'
#	'Cvs path ...' - call 'cvs -d path co -d 'srcdir' ...'
#	'Svn path'     - call 'svn co path 'srcdir''
#	'Http path'    - call 'http get path', unpack *.tar.gz, *.tar.bz2,
#			 *.tgz or *.tbz2 files
#	'Wget file'    - call 'curl file', unpack *.tar.gz *.tar.bz2,
#			  *.tgz  or *.tbz2 files
#	'Tgz file'     - call 'tar xzf file'
#	'Tbz2 file'    - call 'tar xjf file'
#	'Zip file'     - call 'unzip file'
#	'Link package' - use sources from "package"
#	'Script text'  - eval 'text'
proc ::kbs::build::Source {script} {
  variable interp
  variable package
  variable _

  ::kbs::gui::_state -running "" -package $package
  foreach my {Script Http Wget Link Cvs Svn Git Tgz Tbz2 Zip} {
    interp alias $interp $my {} ::kbs::build::Source- $my
  }
  array set _ {srcdir {} srcdir-sys {}}
  $interp eval $script
  foreach my {Script Http Wget Link Cvs Svn Git Tgz Tbz2 Zip} {
    interp alias $interp $my
  }
  if {$_(srcdir) eq {}} {
    return -code error "missing sources of package '$package'"
  }
  set _(srcdir-sys) [_sys $_(srcdir)]
}

#-------------------------------------------------------------------------------
##	Process internal 'Source' commands.
# @synopsis{
#	Link dir
#	Script tcl-script
#	Cvs path args
#	Svn args
#	Git args
#	Http url
#	Wget file
#	Tgz file
#	Tbz2 file
#	Zip file}
#
# @param[in] type	one of the valid source types, see Source().
# @param[in] args	depending on the given 'type' 
proc ::kbs::build::Source- {type args} {
  variable maindir
  variable package
  variable verbose
  variable pkgfile
  variable _

  cd [file join $maindir sources]
  switch -- $type {
    Link {
      if {$args == $package} {return -code error "wrong link source: $args"}
      set myDir [file join $maindir sources $args]
      if {![file exists $myDir]} {
        puts "=== Source $type $package"
        cd $maindir
        if {[catch {
          #exec [pwd]/kbs.tcl sources $args >@stdout 2>@stderr
          if {$verbose} {
            Run [info nameofexecutable] [pwd]/kbs.tcl -pkgfile=$pkgfile -builddir=$_(builddir) -v sources $args
          } else {
            Run [info nameofexecutable] [pwd]/kbs.tcl -pkgfile=$pkgfile -builddir=$_(builddir) sources $args
          }
        } myMsg]} {
          file delete -force $myDir
          if {$verbose} {puts $myMsg}
        }
      }
    } Script {
      set myDir [file join $maindir sources $package]
      if {![file exists $myDir]} {
        puts "=== Source $type $package"
        if {[catch {eval $args} myMsg]} {
          file delete -force $myDir
          if {$verbose} {puts $myMsg}
        }
      }
    } Cvs {
      set myDir [file join $maindir sources $package]
      if {![file exists $myDir]} {
        set myPath [lindex $args 0]
        set args [lrange $args 1 end]
        if {$args eq {}} { set args [file tail $myPath] }
        if {[string first @ $myPath] < 0} {set myPath :pserver:anonymous@$myPath}
        puts "=== Source $type $package"
	      if {[catch {Run $_(exec-cvs) -d $myPath -z3 co -P -d $package {*}$args} myMsg]} {
          file delete -force $myDir
          if {$verbose} {puts $myMsg}
        }
      }
    } Svn {
      set myDir [file join $maindir sources $package]
        if {![file exists $myDir]} {
        puts "=== Source $type $package"
        if {[catch {Run $_(exec-svn) co {*}$args $package} myMsg]} {
          file delete -force $myDir
          if {$verbose} {puts $myMsg}
        }
      }
    } Git {
		set myDir [file join $maindir sources $package]
		set args [lassign $args op]

		if {$op == "clone"} {
			if {[file exists $myDir]} {
				set op pull 
				set args {}
			} else { 
				puts "=== Source $type $package"
				if {[catch {Run $_(exec-git) clone {*}$args $package} myMsg]} {
					file delete -force $myDir
					if {$verbose} {puts $myMsg}
				}
			}

			# signal successful git clone 
			set op {}
			set args {}

		}

		if {$op ne {}} {
			puts "=== Source update $type $package git $op {*}$args"
			if {[catch {
				set myOldpwd [pwd]
				cd $package
				Run $_(exec-git) $op {*}$args
				cd $myOldpwd
			} myMsg]} {
				catch {cd $myOldpwd}
				puts "=== Source update failed $type $package (ignored)"
				#file delete -force $myDir
				if {$verbose} {puts $myMsg}
			}
		} 
    } Http - Wget {
      set myDir [file join $maindir sources $package]
      if {![file exists $myDir]} {
        if {[llength $args] == 1} {
        set myFile [file normalize ./[file tail $args]]
      		} else {
            set myFile [file normalize ./[lindex $args end]]
            set args [lrange $args 0 end-1]
          }  
		
        puts "=== Source $type $package"
        if {[catch {
          Run $_(exec-curl)  --retry 5 --retry-connrefused -L -o $myFile {*}$args
          # unpack if necessary
          switch -glob $myFile {
            *.tgz - *.tar.gz - *.tgz?uuid=* - *.tar.gz?uuid=* {
              Source- Tgz $myFile
              file delete $myFile
            } *.tbz - *.tar.bz2 - *.tbz?uuid=* - *.tar.bz2?uuid=* {
              Source- Tbz2 $myFile
              file delete $myFile
            } *.zip - *.zip?uuid=* {
              Source- Zip $myFile
              file delete $myFile
            } *.kit {
              if {$::tcl_platform(platform) eq {unix}} {
                file attributes $myFile -permissions u+x
              }
              if {$myFile ne $myDir} {
                file mkdir $myDir
	        file rename $myFile $myDir
              }
            }
          }
        } myMsg]} {
          file delete -force $myDir $myFile
          if {$verbose} {puts $myMsg}
        }
      }
    } Tgz - Tbz2 - Zip {
      set myDir [file join $maindir sources $package]
      if {![file exists $myDir]} {
        puts "=== Source $type $package"
        if {[catch {
          file delete -force $myDir.tmp
          file mkdir $myDir.tmp
          cd $myDir.tmp
          if {$type eq {Tgz}} {Run $_(exec-gzip) -dc $args | $_(exec-tar) xf -}
          if {$type eq {Tbz2}} {Run $_(exec-bzip2) -dc $args | $_(exec-tar) xf -}
          if {$type eq {Zip}} {Run $_(exec-unzip) $args}
          cd [file join $maindir sources]
          set myList [glob $myDir.tmp/*]
          if {[llength $myList] == 1 && [file isdir $myList]} {
            file rename $myList $myDir
            file delete $myDir.tmp
          } else {
            file rename $myDir.tmp $myDir
          }
        } myMsg]} {
          file delete -force $myDir.tmp $myDir
          if {$verbose} {puts $myMsg}
        }
      }
    } default {
      return -code error "wrong type '$type'"
    }
  }
  if {[file exists $myDir]} {
    set _(srcdir) $myDir
  }
}
#-------------------------------------------------------------------------------

##	If 'makedir' not exist create it and eval script.
# @synopsis{Configure script}
#
# @param[in] script	tcl script to evaluate with one or more of the following
#		functions to help configure the current package
#	Available functions are: 'Run', 'Get', 'Patch'
#	'Kit ?main.tcl? ?pkg..?' -- see Configure-Kit()
proc ::kbs::build::Configure {script} {
  variable verbose
  variable interp

  set myDir [Get makedir]
  if {[file exist $myDir]} return
  puts "=== Configure $myDir"
  if {$verbose} {puts $script}
  foreach my {Config Kit} {
    interp alias $interp $my {} ::kbs::build::Configure-$my
  }
  file mkdir $myDir
  $interp eval [list cd $myDir]
  $interp eval $script
  foreach my {Config Kit} {interp alias $interp $my}
}

#-------------------------------------------------------------------------------
##	Call 'configure' with options.
# @examples
#	Configure [Get builddir-sys]/configure --enabled-shared=no
# @param [in] path	Path to configure script
# @param [in] args	Additional configure arguments
proc ::kbs::build::Configure-Config {path args} {
  variable _

  # collect available options
  set myOpts ""
  foreach l [split [exec env $path/configure --help] \n] {
    set l [string trimleft $l]
    if {[string range $l 0 8] == "--enable-"} {
      set myOpt [lindex [split $l " \t="] 0]
      set myOpt [string range [lindex [split $l " \t="] 0] 8 end]
      if {[info exists _($myOpt)]} {
        append myOpts " $_($myOpt)"
      }
    } elseif {[string range $l 0 12] == "--exec-prefix"} {
      append myOpts " --exec-prefix=[Get builddir-sys]"
    } elseif {[string range $l 0 7] == "--prefix"} {
      append myOpts " --prefix=[Get builddir-sys]"
    } elseif {[string range $l 0 16] == "--with-tclinclude"} {
    } elseif {[string range $l 0 9] == "--with-tcl"} {
      append myOpts " --with-tcl=[Get builddir-sys]/lib"
    } elseif {[string range $l 0 15] == "--with-tkinclude"} {
    } elseif {[string range $l 0 8] == "--with-tk"} {
      append myOpts " --with-tk=[Get builddir-sys]/lib"
    }
  }
  #TODO CFLAGS
  Run env CC=[Get CC] TCLSH_PROG=[Get builddir-sys]/bin/tclsh85 WISH_PROG=[Get builddir-sys]/bin/wish $path/configure {*}$myOpts {*}$args
}
##	This function create a 'makedir'/main.tcl with:
#	- common startup code
#	- require statement for each package in 'args' argument
#	- application startup from 'maincode' argument
# @synopsis{Kit maincode args}
# @examples
#	Package tksqlite0.5.8 ..
# 
# @param[in] maincode	startup code
# @param[in] args	additional args
proc ::kbs::build::Configure-Kit {maincode args} {
  variable _

  if {[file exists [file join [Get srcdir-sys] main.tcl]]} {
    return -code error "'main.tcl' existing in '[Get srcdir-sys]'"
  }
  # build standard 'main.tcl'
  set myFd [open main.tcl w]
  puts $myFd {#!/usr/bin/env tclkit
# startup
if {[catch {
  package require starkit
  if {[starkit::startup] eq "sourced"} return
}]} {
  namespace eval ::starkit { variable topdir [file dirname [info script]] }
  set auto_path [linsert $auto_path 0 [file join $::starkit::topdir lib]]
}
# used packages};# end of puts
  foreach myPkg $args {
    puts $myFd "package require $myPkg"
  }
  puts $myFd "# start application\n$maincode"
  close $myFd
}
#-------------------------------------------------------------------------------

##	Evaluate script in 'makedir'.
# @synopsis{Make script}
#
# @param[in] script	tcl script to evaluate with one or more of the following
#		functions to help building the current package
#	Available functions are: 'Run', 'Get', 'Patch'
#	'Kit name ?pkglibdir..?' -- see Make-Kit()
proc ::kbs::build::Make {script} {
  variable verbose
  variable interp

  set myDir [Get makedir]
  if {![file exist $myDir]} {
    return -code error "missing make directory: '$myDir'"
  }
  puts "=== Make $myDir"
  if {$verbose} {puts $script}
  interp alias $interp Kit {} ::kbs::build::Make-Kit
  $interp eval [list cd $myDir]
  $interp eval $script
  foreach my {Kit} {interp alias $interp $my}
}
#-------------------------------------------------------------------------------

##	The procedure links the 'name.vfs' in to the 'makedir' and create
#	foreach name in 'args' a link from 'builddir'/lib in to 'name.vfs'/lib.
#	The names in 'args' may subdirectories under 'builddir'/lib. 
#	In the 'name.vfs'/lib the leading directory parts are removed.
#	The same goes for 'name.vfs'.
#	- Kit name ?librarydir ..?
#	  Start in 'makedir'. Create 'name.vfs/lib'.
#	  When existing link 'main.tcl' to 'name.vfs'.
#	  Link everything from [Srcdir] into 'name.vfs'.
#	  Link all package library dirs in ''makedir'/name.vfs'/lib
# @synopsis{Kit name args}
# @examples
#	Package tksqlite0.5.8 ..
# 
# @param[in] name	name of vfs directory (without extension) to use
# @param[in] args	additional args
proc ::kbs::build::Make-Kit {name args} {
  variable _

  #TODO 'file link ...' does not work under 'msys'
  set myVfs $name.vfs
  file delete -force $myVfs
  file mkdir [file join $myVfs lib]
  if {[file exists main.tcl]} {
    file copy main.tcl $myVfs
  }
  foreach myPath [glob -nocomplain -directory [Get srcdir] -tails *] {
    if {$myPath in {lib CVS}} continue
    Run ln -s [file join [Get srcdir-sys] $myPath] [file join $myVfs $myPath]
  }
  foreach myPath [glob -nocomplain -directory [Get srcdir] -tails lib/*] {
    Run ln -s [file join [Get srcdir-sys] $myPath] [file join $myVfs $myPath]
  }
  foreach myPath $args {
    Run ln -s [file join [Get builddir-sys] lib $myPath]\
	[file join $myVfs lib [file tail $myPath]]
  }
}
#-------------------------------------------------------------------------------

##	Eval script in 'makedir'.
# @synopsis{Install script}
#
# @param[in] script	tcl script to evaluate with one or more of the following
#		functions to install the current package.
#	Available functions are: 'Run', 'Get', 'Patch'
#	'Libdir dirname' -- see Install-Libdir()
#	'Kit name args'  -- see Install-Kit()
#	'Tcl ?package?'  -- see Install-Tcl()
proc ::kbs::build::Install {script} {
  variable verbose
  variable interp

  set myDir [Get makedir]
  if {![file exist $myDir]} {
    return -code error "missing make directory: '$myDir'"
  }
  puts "=== Install $myDir"
  if {$verbose} {puts $script}
  foreach my {Kit Tcl Libdir License} {
    interp alias $interp $my {} ::kbs::build::Install-$my
  }
  $interp eval [list cd $myDir]
  $interp eval $script
  foreach my {Kit Tcl Libdir License} {interp alias $interp $my}
}
#-------------------------------------------------------------------------------

##	Move given 'dir' in 'builddir'tcl/lib to package name.
#	This function is necessary to install all packages with the same
#	naming convention (lower case name plus version number).
# @synopsis{Libdir dirname}
#
# @param[in] dirname	original package library dir,
#		not conforming lower case with version number
proc ::kbs::build::Install-Libdir {dirname} {
  variable verbose
  variable package

  set myLib [Get builddir]/lib
  if {[file exists $myLib/$dirname]} {
    if {$verbose} {puts "$myLib/$dirname -> $package"}
    # two steps to distinguish under windows lower and upper case names
    file delete -force $myLib/$dirname.Libdir
    file rename $myLib/$dirname $myLib/$dirname.Libdir
    file delete -force $myLib/$package
    file rename $myLib/$dirname.Libdir $myLib/$package
  } else {
    if {$verbose} {puts "skipping: $myLib/$dirname -> $package"}
  }
}
#-------------------------------------------------------------------------------

##	Without 'option' wrap kit and move to 'builddir'/bin otherwise with:
#	- @b -mk-cli create starpack with 'kbsmk*-cli*' executable
#	- @b -mk-dyn create starpack with 'kbsmk*-dyn*' executable
#	- @b -mk-gui create starpack with 'kbsmk*-gui*' executable
#	- @b -vq-cli create starpack with 'kbsvq*-cli*' executable
#	- @b -vq-dyn create starpack with 'kbsvq*-dyn*' executable
#	- @b -vq-gui create starpack with 'kbsvq*-gui*' executable
#	- @b ... create starpack with given option as executable
# @synopsis{Kit name args}
#
# @examples
#	Package tksqlite0.5.8 ..
# 
# @param[in] name	name of vfs directory (without extension) to use
# @param[in] args	additional args
# SOURCE
proc ::kbs::build::Install-Kit {name args} {
  variable _

  set myTmp [file join [Get builddir] bin]
  if {$args eq {-mk-cli}} {
    set myRun [glob $myTmp/kbsmk*-cli*]
  } elseif {$args eq {-mk-dyn}} {
    set myRun [glob $myTmp/kbsmk*-dyn*]
  } elseif {$args eq {-mk-gui}} {
    set myRun [glob $myTmp/kbsmk*-gui*]
  } elseif {$args eq {-vq-cli}} {
    set myRun [glob $myTmp/kbsvq*-cli*]
  } elseif {$args eq {-vq-dyn}} {
    set myRun [glob $myTmp/kbsvq*-dyn*]
  } elseif {$args eq {-vq-gui}} {
    set myRun [glob $myTmp/kbsvq*-gui*]
  } else {
    set myRun $args
  }
  set myExe {}
  foreach myExe [glob $myTmp/kbs*-cli* $myTmp/kbs*-dyn* $myTmp/kbs*-gui*] {
    if {$myExe ne $myRun} break
  }
  if {$myExe eq {}} { return -code error "no interpreter in '$myTmp'" }

  # if the input is already a kit, unwrap first to get vfs
  if {[regexp {^(.*)\.kit$} $name -> basename]} {
	# sdx refuses to overwrite the .vfs dir, so first remove it
	file delete -force $basename.vfs
    Run $myExe [file join [Get builddir] bin sdx.kit] unwrap $name
	set name $basename
  }

  if {$myRun eq {}} {
    Run $myExe [file join [Get builddir] bin sdx.kit] wrap $name
    file rename -force $name [file join [Get builddir] bin $name.kit]
  } else {
    Run $myExe [file join [Get builddir] bin sdx.kit] wrap $name -runtime {*}$myRun
    if {$_(sys) eq {win}} {
      file rename -force $name [file join [Get builddir] bin $name.exe]
    } else {
      file rename -force $name [file join [Get builddir] bin]
    }
  }
}
#-------------------------------------------------------------------------------

##	Command to install tcl only packages.
#	Used in 'Install' part of 'Package' definitions.
# @synopsis{Tcl ?pkgname?}
#
# @examples
#	Package mentry-3.1 ..
# 
# @param[in] pkgname	install name of package, if missing then build from [Get srcdir]
# @param[in] subdir     source directory under [Get srcdir], default empty
proc ::kbs::build::Install-Tcl {{pkgname {}} {subdir {}}} {
  if {$pkgname eq {}} {
    set myDst [file join [Get builddir] lib [file tail [Get srcdir]]]
  } else {
    set myDst [file join [Get builddir] lib $pkgname]
  }
  file delete -force $myDst
  file copy -force [Get srcdir]/$subdir $myDst
  if {![file exists [file join $myDst pkgIndex.tcl]]} {
    foreach {myPkg myVer} [split [file tail $myDst] -] break;
    if {$myVer eq {}} {set myVer 0.0}
    set myRet "package ifneeded $myPkg $myVer \"\n"
    foreach myFile [glob -tails -directory $myDst *.tcl] {
      append myRet "  source \[file join \$dir $myFile\]\n"
    }
    set myFd [open [file join $myDst pkgIndex.tcl] w]
    puts $myFd "$myRet  package provide $myPkg $myVer\""
    close $myFd
  }
}
#-------------------------------------------------------------------------------

##	Command to install license file
proc ::kbs::build::Install-License {path {name {}}} {
	if {$name eq {}} {
		set name [file tail [Get makedir]]
	}
	set srcfn [file join [Get srcdir] $path]
	set destdir [file join [Get builddir] licenses]
	set destfn [file join $destdir license.terms.$name]
	file mkdir $destdir
	file copy -force $srcfn $destfn
}

#-------------------------------------------------------------------------------

##	Eval script in 'makedir'.
# @synopsis{Test script}
#
# @param[in] script	tcl script to evaluate with one or more of the following
#		functions to help testing the current package
#		Available functions are: 'Run', 'Get', 'Patch'
#		'Kit name args' -- see Test-Kit()
proc ::kbs::build::Test {script} {
  variable verbose
  variable interp

  set myDir [Get makedir]
  if {![file exist $myDir]} return
  puts "=== Test $myDir"
  if {$verbose} {puts $script}
  interp alias $interp Kit {} ::kbs::build::Test-Kit
  $interp eval [list cd $myDir]
  $interp eval $script
  foreach my {Kit} {interp alias $interp $my}
}
#-------------------------------------------------------------------------------

##	Run kit file with given command line 'args'
# @synopsis{Kit mode name args}
#
# @examples
#	Package tksqlite0.5.8 ..
# 
# @param[in] name	name of vfs directory (without extension) to use
# @param[in] args	additional args
proc ::kbs::build::Test-Kit {name args} {
  variable _

  set myExe [file join [Get builddir] bin $name]
  if {[file exists $myExe]} {
    Run $myExe {*}$args
  } else {
    set myTmp [file join [Get builddir] bin]
    set myTmp [glob $myTmp/kbs*-gui* $myTmp/kbs*-dyn* $myTmp/kbs*-cli*]
    Run [lindex $myTmp 0] $myExe.kit {*}$args
  }
}
#-------------------------------------------------------------------------------

##	Eval script in 'makedir'.
# @synopsis{Clean script}
#
# @param[in] script	tcl script to evaluate with one or more of the following
#		functions to help cleaning the current package.
#		Available functions are: 'Run', 'Get', 'Patch'
proc ::kbs::build::Clean {script} {
  variable verbose
  variable interp

  set myDir [Get makedir]
  if {![file exist $myDir]} return
  puts "=== Clean $myDir"
  if {$verbose} {puts $script}
  $interp eval [list cd $myDir]
  $interp eval $script
}
#-------------------------------------------------------------------------------

##	Return value of given variable name.
#	If 'var' starts with 'TCL_' tclConfig.sh will be parsed for TCL_*
#	variables. If 'var' starts with 'TK_' tkConfig.sh will be parsed for
#	TK_* variables.
# @synopsis{Get var}
#
# @param[in] var	name of variable.
proc ::kbs::build::Get {var} {
  variable _

  if {[string index $var 0] eq {-}} {
    if {![info exists _($var)]} return
  } elseif {[string range $var 0 3] eq {TCL_} && ![info exists _(TCL_)]} {
    set myScript ""
    set myFd [open [file join $_(builddir) lib tclConfig.sh] r]
    set myC [read $myFd]
    close $myFd
    foreach myLine [split $myC \n] {
      if {[string range $myLine 0 3] ne {TCL_}} continue
      set myNr [string first = $myLine]
      if {$myNr == -1} continue
      append myScript "set _([string range $myLine 0 [expr {$myNr - 1}]]) "
      incr myNr 1
      append myScript [list [string map {' {}} [string range $myLine $myNr end]]]\n
    }
    eval $myScript
    set _(TCL_) 1
  } elseif {[string range $var 0 2] eq {TK_} && ![info exists _(TK_)]} {
    set myScript ""
    set myFd [open [file join $_(builddir) lib tkConfig.sh] r]
    set myC [read $myFd]
    close $myFd
    foreach myLine [split $myC \n] {
      if {[string range $myLine 0 2] ne {TK_}} continue
      set myNr [string first = $myLine]
      if {$myNr == -1} continue
      append myScript "set _([string range $myLine 0 [expr {$myNr - 1}]]) "
      incr myNr 1
      append myScript [list [string map {' {}} [string range $myLine $myNr end]]]\n
    }
    eval $myScript
    set tkConfig 1
  }
  return $_($var)
}
#-------------------------------------------------------------------------------

##	Patch files.
# @synopsis{Patch file lineoffste oldtext newtext}
#
# @examples
#	Patch [Get srcdir]/Makefile.in 139\
#        {INCLUDES       = @PKG_INCLUDES@ @TCL_INCLUDES@}\
#        {INCLUDES       = @TCL_INCLUDES@}
# 
# @param[in] mode	mode of patch operation, one of file,text,inline
# @param[in] args	arguments depending on 'mode'
#   - file patchfile patchargs
#   - text patchtext patchargs
#     - patchtext
#     - patchargs
#   - inline file lineoffset oldtext newtext
#     - file		name of file to patch
#     - lineoffset	start point of patch, first line is 1
#     - oldtext		part of file to replace
#     - newtext		replacement text
proc ::kbs::build::Patch {file lineoffset oldtext newtext} {
  variable verbose

  set myFd [open $file r]
  set myC [read $myFd]
  close $myFd
  # find oldtext
  set myIndex 0
  for {set myNr 1} {$myNr < $lineoffset} {incr myNr} {;# find line
    set myIndex [string first \n $myC $myIndex]
    if {$myIndex == -1} {
      return -code error "failed Patch: '$file' at $lineoffset -> eof at line $myNr"
    }
    incr myIndex
  }
  # set begin and rest of string
  set myTest [string range $myC $myIndex end]
  set myC [string range $myC 0 [incr myIndex -1]]
  # test for newtext; patch already applied
  set myIndex [string length $newtext]
  if {[string compare -length $myIndex $newtext $myTest] == 0} {
    if {$verbose} {puts "patch line $lineoffset exists"}
    return
  }
  # test for oldtext; patch todo
  set myIndex [string length $oldtext]
  if {[string compare -length $myIndex $oldtext $myTest] != 0} {
    if {$verbose} {puts "---old version---:\n$oldtext\n---new version---:\n[string range $myTest 0 $myIndex]"}
    return -code error "failed Patch: '$file' at $lineoffset"
  }
  # apply patch
  append myC $newtext[string range $myTest $myIndex end]
  set myFd [open $file w]
  puts $myFd $myC
  close $myFd
  if {$verbose} {puts "applied Patch: '$file' at $lineoffset"}
}
#-------------------------------------------------------------------------------

##	Patch files with external patch command.
#	The patch will be applied in the source directory of the current package.
# @synopsis{Patchexec patch options}
#
# @examples
#	Patchexec {...} -p0
#
# @param[in] patch	contents of patchfile
# @param[in] options	options for patch command
proc ::kbs::build::Patchexec {patch args} {
  variable _
  variable verbose

  set wd [pwd]
  cd $_(srcdir)
  set cmd [list $_(exec-patch) {*}$args -i $patchfile]
  if {$::tcl_platform(platform) eq "windows"} {
    exec {*}$cmd >__dev__null__ 2>@stderr
  } else {
    exec {*}$cmd >/dev/null 2>@stderr
  }
  cd $wd
  if {$verbose} {
    puts "applied patch: {*}$cmd"
  }
}
#-------------------------------------------------------------------------------

##	Apply a patch in unified diff format
# @synopsis{PatchApply directory striplevel patch}
#
# @examples
#	PatchApply [Get srcdir] 1 {
#.... here comes the output from diff -ru ...
# }
# @param[in] dir        root directory of the patch, usually srcdir
# @param[in] striplevel number of path elements to be removed from the diff header
# @param[in] patch      output of diff -ru

proc ::kbs::build::PatchFile {striplevel patchfile} {
	set dir [Get srcdir]
	set fd [open [file join [Get basedir] $patchfile]]
	fconfigure $fd -encoding binary
	PatchApply $dir $striplevel [read $fd]
	close $fd
}

proc ::kbs::build::PatchApply {dir striplevel patch} {
	set patchlines [split $patch \n]
	set inhunk false
	set oldcode {}
	set newcode {}
	
	for {set lineidx 0} {$lineidx<[llength $patchlines]} {incr lineidx} {
		set line [lindex $patchlines $lineidx]
		if {[string match diff* $line]} {
			# a diff block starts. Next two lines should be
			# --- oldfile date time TZ
			# +++ newfile date time TZ
			incr lineidx
			set in [lindex $patchlines $lineidx]
			incr lineidx
			set out [lindex $patchlines $lineidx]

			if {![string match ---* $in] || ![string match +++* $out]} {
				puts $in
				puts $out
				return -code error "Patch not in unified diff format, line $lineidx $in $out"
			}

			# the quoting is compatible with list
			lassign $in -> oldfile
			lassign $out -> newfile

			set fntopatch [file join $dir {*}[lrange [file split $oldfile] $striplevel end]]
			set inhunk false
			#puts "Found diffline for $fntopatch"
			continue
		}

		# state machine for parsing the hunks
		set typechar [string index $line 0]
		set codeline [string range $line 1 end]
		switch $typechar {
			@ {
				if {![regexp {@@\s+\-(\d+),(\d+)\s+\+(\d+),(\d+)\s+@@} $line \
					-> oldstart oldlen newstart newlen]} {
					return code -error "Erroneous hunk in line $lindeidx, $line"
				}
				# adjust line numbers for 0-based indexing
				incr oldstart -1
				incr newstart -1
				#puts "New hunk"
				set newcode {}
				set oldcode {}
				set inhunk true
			}
			- { # line only in old code
				if {$inhunk} {
					lappend oldcode $codeline
				}
			}
			+ { # line only in new code
				if {$inhunk} {
					lappend newcode $codeline
				}
			}
			" " { # common line
				if {$inhunk} {
					lappend oldcode $codeline
					lappend newcode $codeline
				}
			}
			default {
				# puts "Junk: $codeline";
				continue
			}
		}
		# test if the hunk is complete
		if {[llength $oldcode]==$oldlen && [llength $newcode]==$newlen} {
			set hunk [dict create \
				oldcode $oldcode \
				newcode $newcode \
				oldstart $oldstart \
				newstart $newstart]
			#puts "hunk complete: $hunk"
			set inhunk false
			dict lappend patchdict $fntopatch $hunk
		}
	}

	# now we have parsed the patch. Apply
	dict for {fn hunks} $patchdict {
		puts "Patching file $fn"
		if {[catch {open $fn} fd]} {
			set orig {}
		} else {
			set orig [split [read $fd] \n]
		}
		close $fd

		set patched $orig

		set fail false
		set already_applied false
		set hunknr 1
		foreach hunk $hunks {
			dict with hunk {
				set oldend [expr {$oldstart+[llength $oldcode]-1}]
				set newend [expr {$newstart+[llength $newcode]-1}]
				# check if the hunk matches
				set origcode [lrange $orig $oldstart $oldend]
				if {$origcode ne $oldcode} {
					set fail true
					puts "Hunk #$hunknr failed"
					# check if the patch is already applied
					set origcode_applied [lrange $orig $newstart $newend]
					if {$origcode_applied eq $newcode} {
						set already_applied true
						puts "Patch already applied"
					} else {
						puts "Expected:\n[join $oldcode \n]"
						puts "Seen:\n[join $origcode \n]"
					}
					break
				}
				# apply patch
				set patched [list {*}[lrange $patched 0 $newstart-1] {*}$newcode {*}[lrange $orig $oldend+1 end]]
			}
			incr hunknr
		}

		if {!$fail} {
			# success - write the result back
			set fd [open $fn w]
			puts -nonewline $fd [join $patched \n]
			close $fd
		}
	}
}
#-------------------------------------------------------------------------------

##	The procedure call the args as external command with options.
#	The procedure is available in all script arguments.
#	If the 'verbose' switch is on the 'args' will be printed.
# @synopsis{Run args}
#
# @param[in] args	containing external command
proc ::kbs::build::Run {args} {
  variable _
  variable verbose
  if {[info exists _(exec-[lindex $args 0])]} {
    set args [lreplace $args 0 0 $_(exec-[lindex $args 0])]
  }

  if {$verbose} {
    ::kbs::gui::_state -running $args
    puts $args
    exec {*}$args >@stdout 2>@stderr
  } else {
    ::kbs::gui::_state;# keep gui alive
    if {$::tcl_platform(platform) eq {windows}} {
      exec {*}$args >NUL: 2>@stderr
    } else {
      exec {*}$args >/dev/null 2>@stderr
    }
  }
}
#-------------------------------------------------------------------------------

##	Configure application with given command line arguments.
#
# @param[in] args	option list
proc ::kbs::build::_configure {args} {
  variable maindir
  variable pkgfile
  variable ignore
  variable recursive
  variable verbose
  variable _

  set _(basedir) [file normalize [file dirname [info script]]]
  set myOpts {}
  # read configuration files
  foreach myFile [list [file join $::env(HOME) .kbsrc] [file join $maindir kbsrc]] {
    if {[file readable $myFile]} {
      puts "=== Read configuration file '$myFile'"
      set myFd [open $myFile r]
      append myOpts [read $myFd]\n
      close $myFd
    }
  }
  # read configuration variable
  if {[info exists ::env(KBSRC)]} {
    puts "=== Read configuration variable 'KBSRC'"
    append myOpts $::env(KBSRC)
  }
  # add all found configuration options to command line
  foreach myLine [split $myOpts \n] {
    set myLine [string trim $myLine]
    if {$myLine eq {} || [string index $myLine 0] eq {#}} continue
    set args "$myLine $args"
  }
  # start command line parsing
  set myPkgfile {}
  set myIndex 0
  foreach myCmd $args {
    switch -glob -- $myCmd {
      -pkgfile=* {
        set myPkgfile [file normalize [string range $myCmd 9 end]]
      } -builddir=* {
	      set myFile [file normalize [string range $myCmd 10 end]]
        set _(builddir) $myFile
      } -bi=* {
        set _(bi) [string range $myCmd 4 end]
      } -CC=* {
        set _(CC) [string range $myCmd 4 end]
      } -i - -ignore {
        set ignore 1
      } -r - -recursive {
        set recursive 1
      } -v - -verbose {
	      set verbose 1
      } --enable-* {
        set _([string range [lindex [split $myCmd {=}] 0] 8 end]) $myCmd
      } --disable-* {
        set _([string range $myCmd 9 end]) $myCmd
      } -make=* {
        set _(exec-make) [string range $myCmd 6 end]
      } -cvs=* {
        set _(exec-cvs) [string range $myCmd 5 end]
      } -svn=* {
        set _(exec-svn) [string range $myCmd 5 end]
      } -tar=* {
        set _(exec-tar) [string range $myCmd 5 end]
      } -gzip=* {
        set _(exec-gzip) [string range $myCmd 6 end]
      } -bzip2=* {
        set _(exec-bzip2) [string range $myCmd 7 end]
      } -unzip=* {
        set _(exec-unzip) [string range $myCmd 7 end]
      } -wget=* {
        set _(exec-wget) [string range $myCmd 6 end]
      } -curl=* {
        set _(exec-curl) [string range $myCmd 6 end]
      } -doxygen=* {
        set _(exec-doxygen) [string range $myCmd 9 end]
      } -kitcli=* {
        set _(kitcli) [string range $myCmd 8 end]
      } -kitdyn=* {
        set _(kitdyn) [string range $myCmd 8 end]
      } -kitgui=* {
        set _(kitgui) [string range $myCmd 8 end]
      } -kitgui=* {
      } -mk {
        lappend _(kit) mk-cli mk-dyn mk-gui
      } -mk-cli {
        lappend _(kit) mk-cli
      } -mk-dyn {
        lappend _(kit) mk-dyn
      } -mk-gui {
        lappend _(kit) mk-gui
      } -mk-bi {
        lappend _(kit) mk-bi
      } -staticstdcpp {
        set _(staticstdcpp) 1
      } -vq {
        lappend _(kit) vq-cli vq-dyn vq-gui
      } -vq-cli {
        lappend _(kit) vq-cli
      } -vq-dyn {
        lappend _(kit) vq-dyn
      } -vq-gui {
        lappend _(kit) vq-gui
      } -vq-bi {
        lappend _(kit) vq-bi
      } -* {
        return -code error "wrong option: '$myCmd'"
      } default {
        set args [lrange $args $myIndex end]
        break
      }
    }
    incr myIndex
  }
  set _(builddir-sys) [_sys $_(builddir)]
  set _(kit) [lsort -unique $_(kit)];# all options only once
  if {$_(kit) eq {}} {set _(kit) {vq-cli vq-dyn vq-gui}};# default setting
  foreach my {cli dyn gui} {;# default settings
    if {$_(kit$my) eq {}} {
      set _(kit$my) [lindex [lsort [glob -nocomplain [file join $_(builddir) bin kbs*${my}*]]] 0]
    }
  }
  file mkdir [file join $_(builddir) bin] [file join $maindir sources]
  file mkdir [file join $_(builddir) lib]
  if {![file readable [file join $_(builddir) lib64]]} {
    file link [file join $_(builddir) lib64] [file join $_(builddir) lib]
  }
  # read kbs configuration file
  if {$myPkgfile ne {}} {
    puts "=== Read definitions from '$myPkgfile'"
    source $myPkgfile
    set pkgfile $myPkgfile
  }
  return $args
}

#===============================================================================

source kbs-pkg-db.tcl

#===============================================================================
##	Parse the command line in search of options.
#	Process the command line to call one of the '::kbs::*' functions
#
# @param[in] argv	list of provided command line arguments
proc ::kbs_main {argv} {
  # parse options
  if {[catch {::kbs::build::_configure {*}$argv} argv]} {
    puts stderr "Option error (try './kbs.tcl' to get brief help): $argv"
    exit 1
  }

  # try to execute command
  set cmd [lindex $argv 0]

  if {[info commands ::kbs::$cmd] ne ""} {
    if {[catch {::kbs::$cmd {*}[lrange $argv 1 end]} ErrMsg]} {
      puts stderr "Error in execution of '$cmd [lrange $argv 1 end]':\n$ErrMsg"
      exit 1
    }
    if {$cmd != "gui"} {
      exit 0
    }
  } elseif {$cmd eq {}} {
    ::kbs::help
    exit 0
  } else {
    set myList {}
    #lists all commands in namespace'::kbs'
    foreach KnownCmd [lsort [info commands ::kbs::*]] { 
      lappend CmdList [namespace tail $KnownCmd]
    }
    puts stderr "'$cmd' not found, should be one of: [join $CmdList {, }]"
    exit 1
  }
}
#-------------------------------------------------------------------------------

# start application
if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {
  ::kbs_main $argv
}
#===============================================================================
# vim: set syntax=tcl

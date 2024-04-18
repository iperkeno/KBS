##	Definition of usage help message.
# @note	This is also the default action if no command was given.
# @examples
# @call{display usage help message,./kbs.tcl help}
set ::kbs(help) {
Usage: kbs.tcl ?options? command ?args?

options (configuration variables are available with \[Get ..\]):
  -pkgfile=?file?   contain used Package definitions
                    (default is empty and use only internal definitions)
  -builddir=?dir?   set used building directory containing all package
                    specific 'makedir' (default is './build\$tcl_platform(os)')
  -i -ignore        ignore errors and proceed (default is disabled)
  -r -recursive     recursive Require packages (default is disabled)
  -v -verbose       display running commands and command output
  -CC=?command?     set configuration variable 'CC'
                    (default is 'gcc' or existing environment variable 'CC')
  -bi=?package ..?  set configuration variable 'bi' (default is '')
                    to list of packages for use in batteries included builds
  --enable-*
  --disable-*       set configuration variable '-*'
  
  Used external programs (default values are found with 'auto_execok'):
  -make=?command?   set configuration variable 'exec-make'
                    (default is first found 'gmake' or 'make')
  -cvs=?command?    set configuration variable 'exec-cvs' (default is 'cvs')
  -svn=?command?    set configuration variable 'exec-svn' (default is 'svn')
  -tar=?command?    set configuration variable 'exec-tar' (default is 'tar')
  -gzip=?command?   set configuration variable 'exec-gzip' (default is 'gzip')
  -bzip2=?command?  set configuration variable 'exec-bzip2' (default is 'bzip2')
  -git=?command?    set configuration variable 'exec-git' (default is 'git')
  -unzip=?command?  set configuration variable 'exec-unzip' (default is 'unzip')
  -wget=?command?   set configuration variable 'exec-wget' (default is 'wget')
  -patch=?command?  set configuration variable 'exec-patch' (default is 'patch')
  -doxygen=?command? set configuration variable 'exec-doxygen'
                    (default is 'doxygen') you need at least version 1.7.5
  
  Used interpreter in package scripts (default first found in '[::kbs::config::Get builddir]/bin')
  -kitcli=?command? set configuration variable 'kitcli' (default 'kbs*cli*')
  -kitdyn=?command? set configuration variable 'kitdyn' (default 'kbs*dyn*')
  -kitgui=?command? set configuration variable 'kitgui' (default 'kbs*gui*')
  
  Mk4tcl based 'tclkit' interpreter build options:
  -mk               add 'mk-cli|dyn|gui' to variable 'kit'
  -mk-cli           add 'mk-cli' to variable 'kit'
  -mk-dyn           add 'mk-dyn' to variable 'kit'
  -mk-gui           add 'mk-gui' to variable 'kit'
  -mk-bi            add 'mk-bi' to variable 'kit'
  -staticstdcpp     build with static libstdc++
  
  Vqtcl based 'tclkit lite' interpreter build options:
  -vq               add 'vq-cli|dyn|gui' to variable 'kit'
  -vq-cli           add 'vq-cli' to variable 'kit'
  -vq-dyn           add 'vq-dyn' to variable 'kit'
  -vq-gui           add 'vq-gui' to variable 'kit'
  -vq-bi            add 'vq-bi' to variable 'kit'
  If no interpreter option is given '-vq' will be asumed.

additional variables for use with \[Get ..\]):
  application       name of application including version number
  builddir          common build dir (can be set with -builddir=..)
  makedir           package specific dir under 'builddir'
  srcdir            package specific source dir under './sources/'
  builddir-sys
  makedir-sys
  srcdir-sys        system specific version (p.e. windows C:\\.. -> /..)
  sys               TEA specific platform subdir (win, unix)
  TCL*              TCL* variables from tclConfig.sh, loaded on demand
  TK*               TK* variables from tkConfig.sh, loaded on demand

command:
  help              this text
  doc               create program documentation (./doc/kbs.html)
  license           display license information
  config            display used values of configuration variables
  gui               start graphical user interface
  list ?pattern? .. list packages matching pattern (default is *)
                    Trailing words print these parts of the definition too.
  require pkg ..    return call trace of packages
  sources pkg ..    get package source files (under sources/)
  configure pkg ..  create 'makedir' (in 'builddir') and configure package
  make pkg ..       make package (in 'makedir')
  install pkg ..    install package (in 'builddir')
  test pkg ..       test package
  clean pkg ..      remove make targets
  distclean pkg ..  remove 'makedir'
'pkg' is used for glob style matching against available packages
(Beware, you need to hide the special meaning of * like foo\\*)

Startup configuration:
  Read files '\$(HOME)/.kbsrc' and './kbsrc'. Lines starting with '#' are
  treated as comments and removed. All other lines are concatenated and
  used as command line arguments.
  Read environment variable 'KBSRC'. The contents of this variable is used
  as command line arguments.

The following external programs are needed:
  * C-compiler, C++ compiler for metakit based programs (see -CC=)
  * make with handling of VPATH variables (gmake) (see -make=)
  * cvs, svn, tar, gzip, unzip, wget to get and extract sources
    (see -cvs= -svn= -tar= -gzip= -unzip= -wget= options)
  * msys (http://sourceforge.net/project/showfiles.php?group_id=10894) is
    used to build under Windows. You need to put the kbs-sources inside
    the msys tree (/home/..).
}
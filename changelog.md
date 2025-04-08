# KBS Changelog

## V 0.4.9

[20250321] 
  - added command "target-sys" to specify buid target: unix/win, default is _(sys)
  - kbs-gui: added ttk::notebook tabs to divide and organize build options from program variables
  - kbskit8.6: rename "configure.in" to "configure.ac"
  - kbskit8.6: updated tcl.m4 from vfs, this version handle correctly the target os.
  - kbskit8.6: in "configure.ac" commented TEA_ENABLE_SHARED to allow windows crossbuild 
  - kbskit8.6: clear definition of build steps for win/unix and static/dynamic

[20240501] Integrated changes "from KBS-aurious"
  - Added *PatchFile* to Apply a patch in unified diff format.
  - Added *Install-License*
  - PKG *vfs* updated to version 1.4.2
  - rename proc ::kbs::config to ::kbs::display-config, modified the help content.
  - refactoring kbs::config to kbs::build 
  - removed *tdbc1.1.7 sqlite3.44.2 tdbcmysql1.1.7 tdbcodbc1.1.7 tdbcpostgres1.1.7* from default build of kbskit8.6
  - added *--disable-stubs -with-tcl8* to Package vfs1.4.2
  - updated kbskit make with vfs1.4.2
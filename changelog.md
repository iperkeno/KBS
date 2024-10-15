# KBS Changelog

## V 0.4.9

[20240501] Integrated changes "from KBS-aurious"
  - Added *PatchFile* to Apply a patch in unified diff format.
  - Added *Install-License*
  - PKG *vfs* updated to version 1.4.2
  - rename proc ::kbs::config to ::kbs::display-config, modified the help content.
  - refactoring kbs::config to kbs::build 
  - removed *tdbc1.1.7 sqlite3.44.2 tdbcmysql1.1.7 tdbcodbc1.1.7 tdbcpostgres1.1.7* from default build of kbskit8.6
  - added *--disable-stubs -with-tcl8* to Package vfs1.4.2
  - updated kbskit make with vfs1.4.2
##	Contain variables and function of the graphical user interface.
namespace eval ::kbs::gui {
#-------------------------------------------------------------------------------

##	Containing internal gui state values.
  variable _
  set _(-command) {};# currently running command
  set _(-package) {};# current package 
  set _(-running) {};# currently executed command in 'Run'
  set _(widgets) [list];# list of widgets to disable if command is running
}

#-------------------------------------------------------------------------------
##	Build and initialize graphical user interface.
#
# @param[in] args	currently ignored
proc ::kbs::gui::_init {args} {
  variable _

  package require Tk

  grid rowconfigure . 5 -weight 1
  grid columnconfigure . 1 -weight 1

  set w .nb
  grid [::ttk::notebook $w] -row 1 -column 1 -sticky ew

  #---------------------------------------- select options tab 
  set w .nb.opt
  .nb add [frame $w] -text "Options"
  set w .nb.opt.sel
  grid [::ttk::labelframe $w -text {Select options} -padding 3]\
	-row 2 -column 1 -sticky ew

  grid columnconfigure $w 1 -weight 1
  grid columnconfigure $w 2 -weight 1
  grid columnconfigure $w 3 -weight 1

  grid [::ttk::checkbutton $w.1 -text -ignore -onvalue 1 -offvalue 0 -variable ::kbs::build::ignore]\
	-row 1 -column 1 -sticky ew
  grid [::ttk::checkbutton $w.2 -text -recursive -onvalue 1 -offvalue 0 -variable ::kbs::build::recursive]\
	-row 1 -column 2 -sticky ew
  grid [::ttk::checkbutton $w.3 -text -verbose -onvalue 1 -offvalue 0 -variable ::kbs::build::verbose]\
	-row 1 -column 3 -sticky ew

  lappend _(widgets) $w.1 $w.2 $w.3

  # toggle options
  set w .nb.opt.tgl
  grid [::ttk::labelframe $w -text {Toggle options} -padding 3]\
	-row 3 -column 1 -sticky ew
  grid columnconfigure $w 3 -weight 1
  grid columnconfigure $w 6 -weight 1

  set c 0
  set r 1
  set i 0
  foreach myOpt {-shared -symbols -64bit -64bit-vis -xft -corefoundation -aqua -framework} {
    grid [::ttk::label $w.[incr i] -text $myOpt= -anchor e]\
	-row $r -column [incr c] -sticky ew
    grid [::ttk::checkbutton $w.[incr i] -width 17\
	-onvalue --enable$myOpt -offvalue --disable$myOpt\
	-variable ::kbs::build::_($myOpt)\
	-textvariable ::kbs::build::_($myOpt)]\
	-row $r -column [incr c] -sticky ew
    lappend _(widgets) $w.$i
    if {$c >= 4} {
      set c 0
      incr r
    }
  }

  # kit build options
  set w .nb.opt.kit
  grid [::ttk::labelframe $w -text {Kit build options} -padding 3]\
	-row 4 -column 1 -sticky ew
  grid columnconfigure $w 2 -weight 1

  grid [::ttk::label $w.1 -text {'kit'} -anchor e]\
	-row 1 -column 1 -sticky ew
  grid [::ttk::combobox $w.2 -state readonly -textvariable ::kbs::build::_(kit) -values {mk-cli mk-dyn mk-gui mk-bi {mk-cli mk-dyn mk-gui} vq-cli vq-dyn vq-gui vq-bi {vq-cli vq-dyn vq-gui} {mk-cli mk-dyn mk-gui vq-cli vq-dyn vq-gui}}]\
	-row 1 -column 2 -sticky ew
  grid [::ttk::label $w.3 -text -bi= -anchor e]\
	-row 2 -column 1 -sticky ew
  grid [::ttk::entry $w.4 -textvariable ::kbs::build::_(bi)]\
	-row 2 -column 2 -sticky ew
  grid [::ttk::button $w.5 -text {set '-bi' with selected packages} -command {::kbs::gui::_set_bi} -padding 0]\
	-row 3 -column 2 -sticky ew

  # packages
  set w .nb.opt.pkg
  grid [::ttk::labelframe $w -text {Available Packages} -padding 3]\
	-row 5 -column 1 -sticky ew
  grid rowconfigure $w 1 -weight 1
  grid columnconfigure $w 1 -weight 1

  grid [::listbox $w.lb -yscrollcommand "$w.2 set" -selectmode extended]\
	-row 1 -column 1 -sticky nesw
  eval $w.lb insert end [lsort -dict [array names ::kbs::build::packages]]
  grid [::ttk::scrollbar $w.2 -orient vertical -command "$w.lb yview"]\
	-row 1 -column 2 -sticky ns

  # commands
  set w .nb.opt.cmd
  grid [::ttk::labelframe $w -text Commands -padding 3]\
	-row 6 -column 1 -sticky ew
  grid columnconfigure $w 1 -weight 1
  grid columnconfigure $w 2 -weight 1
  grid columnconfigure $w 3 -weight 1
  grid columnconfigure $w 4 -weight 1
  grid [::ttk::button $w.1 -text sources -command {::kbs::gui::_command sources}]\
	-row 1 -column 1 -sticky ew
  grid [::ttk::button $w.2 -text configure -command {::kbs::gui::_command configure}]\
	-row 1 -column 2 -sticky ew
  grid [::ttk::button $w.3 -text make -command {::kbs::gui::_command make}]\
	-row 1 -column 3 -sticky ew
  grid [::ttk::button $w.4 -text install -command {::kbs::gui::_command install}]\
	-row 1 -column 4 -sticky ew
  grid [::ttk::button $w.5 -text test -command {::kbs::gui::_command test}]\
	-row 2 -column 1 -sticky ew
  grid [::ttk::button $w.6 -text clean -command {::kbs::gui::_command clean}]\
	-row 2 -column 2 -sticky ew
  grid [::ttk::button $w.7 -text distclean -command {::kbs::gui::_command distclean}]\
	-row 2 -column 3 -sticky ew
  grid [::ttk::button $w.8 -text EXIT -command {exit}]\
	-row 2 -column 4 -sticky ew

  lappend _(widgets) $w.1 $w.2 $w.3 $w.4 $w.5 $w.6 $w.7 $w.8

  # status
  set w .nb.opt.state
  grid [::ttk::labelframe $w -text {Status messages} -padding 3]\
	-row 7 -column 1 -sticky ew
  grid columnconfigure $w 2 -weight 1

  grid [::ttk::label $w.1_1 -anchor w -text Command:]\
	-row 1 -column 1 -sticky ew
  grid [::ttk::label $w.1_2 -anchor w -relief sunken -textvariable ::kbs::gui::_(-command)]\
	-row 1 -column 2 -sticky ew
  grid [::ttk::label $w.2_1 -anchor w -text Package:]\
	-row 2 -column 1 -sticky ew
  grid [::ttk::label $w.2_2 -anchor w -relief sunken -textvariable ::kbs::gui::_(-package)]\
	-row 2 -column 2 -sticky nesw
  grid [::ttk::label $w.3_1 -anchor w -text Running:]\
	-row 3 -column 1 -sticky ew
  grid [::ttk::label $w.3_2 -anchor w -relief sunken -textvariable ::kbs::gui::_(-running) -wraplength 300]\
	-row 3 -column 2 -sticky ew

  #---------------------------------------------- variables tab
  set w .nb.var
  .nb add [frame $w] -text "Variables"
  # grid [::ttk::labelframe $w -text {Option variables} -padding 3]\
	# -row 1 -column 1 -sticky ew
  # grid columnconfigure $w 2 -weight 1

  grid [::ttk::label $w.1 -anchor e -text {-pkgfile=}]\
	-row 1 -column 1 -sticky ew
  grid [::ttk::label $w.2 -anchor w -relief ridge -textvariable ::kbs::build::pkgfile]\
	-row 1 -column 2 -sticky ew

  grid [::ttk::label $w.4 -anchor e -text {-builddir=}]\
	-row 2 -column 1 -sticky ew
  grid [::ttk::label $w.5 -anchor w -relief ridge -textvariable ::kbs::build::_(builddir)]\
	-row 2 -column 2 -sticky ew
  grid [::ttk::button $w.6 -width 3 -text {...} -command {::kbs::gui::_set_builddir} -padding 0]\
	-row 2 -column 3 -sticky ew

  grid [::ttk::label $w.7 -anchor e -text {-CC=}]\
	-row 3 -column 1 -sticky ew
  grid [::ttk::entry $w.8 -textvariable ::kbs::build::_(CC)]\
	-row 3 -column 2 -sticky ew
  grid [::ttk::button $w.9 -width 3 -text {...} -command {::kbs::gui::_set_exec CC {Select C-compiler}} -padding 0]\
	-row 3 -column 3 -sticky ew
  lappend _(widgets) $w.6 $w.8 $w.9

  set myRow 3
  set myW 9
  foreach myCmd [lsort [array names ::kbs::build::_ exec-*]] {
    set myCmd [string range $myCmd 5 end]
    incr myRow
    grid [::ttk::label $w.[incr myW] -anchor e -text "-${myCmd}="]\
	-row $myRow -column 1 -sticky ew
    grid [::ttk::entry $w.[incr myW] -textvariable ::kbs::build::_(exec-$myCmd)]\
	-row $myRow -column 2 -sticky ew
    lappend _(widgets) $w.$myW
    grid [::ttk::button $w.[incr myW] -width 3 -text {...} -command "::kbs::gui::_set_exec exec-${myCmd} {Select '${myCmd}' program}" -padding 0]\
	-row $myRow -column 3 -sticky ew
    lappend _(widgets) $w.$myW
  }

  #----------------------------------------- Display windows
  wm title . [::kbs::build::Get application]
  wm protocol . WM_DELETE_WINDOW {exit}
  wm deiconify .
}
#----------------------------------------------------------END ::kbs::gui::_init 

##	Set configuration variable 'builddir'.
proc ::kbs::gui::_set_builddir {} {
  set myDir [tk_chooseDirectory -parent . -title "Select 'builddir'"\
	-initialdir $::kbs::build::_(builddir)]
  if {$myDir eq {}} return
  file mkdir [file join $myDir bin]
  set ::kbs::build::_(builddir) $myDir
  set ::kbs::build::_(builddir-sys) [::kbs::build::_sys $myDir]
}
#-------------------------------------------------------------------------------

##	Set configuration variable of given 'varname'.
#
# @param[in] varname	name of configuration variable to set
# @param[in] title	text to display as title of selection window
proc ::kbs::gui::_set_exec {varname title} {
  set myFile [tk_getOpenFile -parent . -title $title\
	-initialdir [file dirname $::kbs::build::_($varname)]]
  if {$myFile eq {}} return
  set ::kbs::build::_($varname) $myFile
}
#-------------------------------------------------------------------------------

##	Set configuration variable 'bi'.
proc ::kbs::gui::_set_bi {} {
  set my [list]
  foreach myNr [.nb.opt.pkg.lb curselection] {
    lappend my [.nb.opt.pkg.lb get $myNr]
  }
  set ::kbs::build::_(bi) $my
}
#-------------------------------------------------------------------------------

##	Function to process currently selected packages and provide
#	feeedback results.
#
# @param[in] cmd	selected command from gui
proc ::kbs::gui::_command {cmd} {
  variable _

  set mySelection [.nb.opt.pkg.lb curselection]
  if {[llength $mySelection] == 0} {
    tk_messageBox -parent . -type ok -title {No selection} -message {Please select at least one package from the list.}
    return
  }
  foreach myW $_(widgets) { $myW configure -state disabled }
  set myCmd ::kbs::$cmd
  foreach myNr $mySelection {
    lappend myCmd [.nb.opt.pkg.lb get $myNr]
  }
  ::kbs::gui::_state -running "" -package "" -command "'$myCmd' ..."
  if {![catch {console show}]} {
    set myCmd "consoleinterp eval $myCmd"
  }
  if {[catch {{*}$myCmd} myMsg]} {
    tk_messageBox -parent . -type ok -title {Execution failed} -message "'$cmd ' failed!\n$myMsg" -icon error
    ::kbs::gui::_state -command "'$cmd ' failed!"
  } else {
    tk_messageBox -parent . -type ok -title {Execution finished} -message "'$cmd ' successfull." -icon info
    ::kbs::gui::_state -running "" -package "" -command "'$cmd ' done."
  }
  foreach myW $_(widgets) { $myW configure -state normal }
}
#-------------------------------------------------------------------------------

##	Change displayed state informations and update application.
# @param[in] args	list of option-value pairs with:
#   -running 'text' - text to display in the 'Running:' state
#   -package 'text' - text to display in the 'Package:' state
#   -command 'text' - text to display in the 'Command:' state
proc ::kbs::gui::_state {args} {
  variable _

  array set _ $args
  update
}
#-------------------------------------------------------------------------------

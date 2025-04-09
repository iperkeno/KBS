#=======================================================================#
# SCRIPT  : viewIcons.tcl                                               #
# PURPOSE : Display icons from icon library.                            #
# AUTHOR  : Adrian Davis (adrian@satisoft.com).                         #
#-----------------------------------------------------------------------#
# HISTORY : Mar02 1.00.00 - First release.                              #
#         : Jul02 1.01.00 - Adds clipboard and columns facilities.      #
#         : Feb09 1.02.00 - Fix Tcl/Tk 8.5 font problem.                #
#         : Jul13 2.00.00 - Updated for ICONS version 2.                #
#=======================================================================#

#=======================================================================#
# Name      : initInfo                                                  #
# Purpose   : Initialise icon info lookup.                              #
# Parameters: Item     : Item to which "IconName" applies.              #
#           : IconName : Name of icon.                                  #
#=======================================================================#

proc initInfo {Item IconName} {
   global INFO

   set INFO($Item) $IconName

   bind $Item <Button-1> {clipInfo %W}
   bind $Item <Enter>    {delayInfo %W}
   bind $Item <Leave>    {cancelInfo}
}

#=======================================================================#
# Name      : delayInfo                                                 #
# Purpose   : Set delay for icon info.                                  #
# Parameters: Item : Item to which help applies.                        #
#=======================================================================#

proc delayInfo {Item} {
   global INFO

   cancelInfo
   set INFO(Delay) [after 200 [list showInfo $Item]]
}

#=======================================================================#
# Name      : cancelInfo                                                #
# Purpose   : Cancel icon info.                                         #
# Parameters: None.                                                     #
#=======================================================================#

proc cancelInfo {} {
   global INFO

   if {[info exists INFO(Delay)]} {
      after cancel $INFO(Delay)
      unset INFO(Delay)
   }
   wm withdraw .infoWindow
}

#=======================================================================#
# Name      : showInfo                                                  #
# Purpose   : Show icon info.                                           #
# Parameters: Item : Item to which info applies.                        #
#=======================================================================#

proc showInfo {Item} {
   global ICON INFO

   set IconName $INFO($Item)

   .infoWindow.name   configure -text [lindex $ICON($IconName) 0]
   .infoWindow.groups configure -text [lindex $ICON($IconName) 1]
   .infoWindow.type   configure -text [lindex $ICON($IconName) 2]
   .infoWindow.size   configure -text [lindex $ICON($IconName) 3]

   set InfoX [expr [winfo rootx $Item] + 10]
   set InfoY [expr [winfo rooty $Item] + [winfo height $Item]]
 
   wm geometry  .infoWindow +$InfoX+$InfoY
   wm deiconify .infoWindow

   raise .infoWindow

   unset INFO(Delay)
}

#=======================================================================#
# Name      : primaryTransfer                                           #
# Purpose   : Primary Transfer handler for Unix "clipboard".            #
# Parameters: offset & maxChars : Both ignored in this application.     #
#=======================================================================#
 
proc primaryTransfer {offset maxChars} {
   global COMMAND

   return $COMMAND
}

#=======================================================================#
# Name      : lostSelection                                             #
# Purpose   : Clear COMMAND when selection is lost.                     #
# Parameters: None.                                                     #
#=======================================================================#
 
proc lostSelection {} {
   global COMMAND

   set COMMAND ""
}

#=======================================================================#
# Name      : clipInfo                                                  #
# Purpose   : Copy the icon data to the clipboard                       #
# Parameters: Item : Item to which clip applies.                        #
#=======================================================================#
 
proc clipInfo {Item} {
   global COMMAND INFO LIBRARY PLATFORM
 
   set IconName  $INFO($Item)
   set Data      {}
   set DataWidth 59

   set IconData [::icons::icons query -file $LIBRARY -items d $IconName]

   while {[string length $IconData] > 0} {
      append Data "   [string range $IconData 0 $DataWidth]\n"
      set IconData [string range $IconData [expr {$DataWidth + 1}] end]
   }

   set COMMAND "image create photo $IconName -data \{\n[string trimright $Data]\n\}\n"

   clipboard clear
   clipboard append $COMMAND

   if {$PLATFORM eq "unix"} {
      selection handle -selection PRIMARY "." primaryTransfer
      selection own    -selection PRIMARY -command lostSelection "."
   }

   bell
}

#=======================================================================#
# Name      : layoutResize                                              #
# Purpose   : Set scrolling region size.                                #
# Parameters: None.                                                     #
#=======================================================================#

proc layoutResize {} {

   set Box   [.display.icons bbox all]
   set Width [expr {[winfo width .controls] - [winfo width .display.yscrollbar] - 8}]

   .display.icons configure -width $Width -scrollregion $Box -xscrollincrement 0.1i -yscrollincrement 0.1i
}

#=======================================================================#
# Name      : selectIcons                                               #
# Purpose   : Display icons file selection dialog.                      #
# Parameters: None.                                                     #
#=======================================================================#

proc selectIcons {} {
   global INITIALDIR LIBRARY MODE

   set OldLibrary $LIBRARY

   if {$MODE eq "library"} {
      set LIBRARY [tk_getOpenFile -initialdir $INITIALDIR -initialfile tkIcons -title "Select Icon Library" -filetypes {{"Icon Libraries" {tkIcons*}} {"All Files" {*}}}]
   } else {
      set LIBRARY [tk_chooseDirectory -initialdir $INITIALDIR -title "Select Icon Folder"] 
   }
   
   if {$LIBRARY eq ""} {
      set LIBRARY $OldLibrary
   }

   displayIcons
}

#=======================================================================#
# Name      : displayIcons                                              #
# Purpose   : Display icons from selected library.                      #
# Parameters: None.                                                     #
#=======================================================================#

proc displayIcons {} {
   global COLUMNS GROUPS ICON ICONS LIBRARY

   set Column 0
   set Limit  [expr {$COLUMNS - 1}]
   set Row    0

   if {! [file exists $LIBRARY]} {
      tk_messageBox -icon warning -message "File does not exist" -title "viewIcons"
      return
   }

   set Cursor [. cget -cursor]
   . configure -cursor watch

   ::icons::icons delete $ICONS
   destroy .display.icons.layout.grid
   frame   .display.icons.layout.grid
   pack    .display.icons.layout.grid

   set ICONS [::icons::icons create -file $LIBRARY -group $GROUPS]

   foreach IconInfo [::icons::icons query -file $LIBRARY -group $GROUPS] {
      set IconName        [lindex $IconInfo 0]
      set ICON($IconName) $IconInfo

      label .display.icons.layout.grid.$Column:$Row -image ::icon::$IconName
      grid  .display.icons.layout.grid.$Column:$Row -column $Column -row $Row -padx 3 -pady 3
      grid  columnconfigure .display.icons.layout.grid.$Column:$Row $Column

      initInfo .display.icons.layout.grid.$Column:$Row $IconName

      if {$Column == $Limit} {
         set Column 0
         set Row [expr {$Row + 1}]
      } else {
         set Column [expr {$Column + 1}]
      }
   }  

   . configure -cursor $Cursor
}

#=======================================================================#
# Name      : setColumns                                                #
# Purpose   : Set number of columns to be displayed.                    #
# Parameters: Columns : Number of columsn to be displayed.              #
#=======================================================================#

proc setColumns {Columns} {
   global COLUMNS

   set COLUMNS $Columns

   for {set Button 6} {$Button <= 20} {incr Button +2} {
      .controls.columns.$Button configure -relief raised
   }

   .controls.columns.$COLUMNS configure -relief sunken

   displayIcons
}

#=======================================================================#
# Name      : setMode                                                   #
# Purpose   : Set mode (libaray -or- folder).                           #
# Parameters: None.                                                     #
#=======================================================================#

proc setMode {} {
   global INITIALDIR MODE LIBRARY
   
   if {$MODE eq "library"} {
      set MODE    "folder"
      set LIBRARY $INITIALDIR
      .controls.libraryLabel configure -text "Folder"
      .controls.groupsLabel  configure -text "Files"
   } else  {
      set MODE    "library"
      set LIBRARY [file join $INITIALDIR tkIcons]
      .controls.libraryLabel configure -text "Library"
      .controls.groupsLabel  configure -text "Group"

   }
}

#=======================================================================#
# Main code.                                                            #
#=======================================================================#
lappend auto_path .
package require icons 2.0

#-----------------------------------------------------------------------#
# Read command-line parameters.                                         #
#-----------------------------------------------------------------------#

if {[llength $argv] > 0} {
   set INITIALDIR [lindex $argv 0]
} else {
   set INITIALDIR [info library]
}

#-----------------------------------------------------------------------#
# Initialise font.                                                      #
#-----------------------------------------------------------------------#

set PLATFORM $tcl_platform(platform)

if {$PLATFORM eq "unix"} {
   option add *HighlightThickness 0
}

#-----------------------------------------------------------------------#
# Initialise Globals.                                                   #
#-----------------------------------------------------------------------#

label .dummy

set COLUMNS  14
set COMMAND  ""
set FONT     [.dummy cget -font]
set BOLDFONT "[font actual $FONT] -weight bold"
set GROUPS   "*"
set ICONS    {}
set LIBRARY  [file join $INITIALDIR tkIcons]
set MODE     library

#-----------------------------------------------------------------------#
# Create main display window/frames.                                    #
#-----------------------------------------------------------------------#

frame .controls
#frame .controls.columns
frame .controls.line1 -height 2 -borderwidth 1 -relief sunken
frame .controls.line2 -height 2 -borderwidth 1 -relief sunken

label  .controls.libraryLabel -font $BOLDFONT -text "Library"
label  .controls.groupsLabel  -font $BOLDFONT -text "Groups"
label  .controls.columnsLabel -font $BOLDFONT -text "Columns"

ttk::entry   .controls.library      -width 50 -textvariable LIBRARY
ttk::entry   .controls.groups       -width 50 -textvariable GROUPS
ttk::spinbox .controls.columns      -width 2  -textvariable COLUMNS -from 6 -to 20 -increment 2 -command displayIcons
ttk::button  .controls.browse       -text "Browse" -command selectIcons
ttk::button  .controls.view         -text "View"   -command displayIcons
ttk::button  .controls.exit         -text "Exit"   -command exit

grid .controls.libraryLabel -row 0 -column 0 -padx 4 -sticky w
grid .controls.library      -row 0 -column 1
grid .controls.browse       -row 0 -column 2 -padx 4 -pady 2 -sticky ew
grid .controls.line1        -row 1 -column 0 -pady 2 -columnspan 3 -sticky ew
grid .controls.groupsLabel  -row 2 -column 0 -padx 4 -sticky w
grid .controls.groups       -row 2 -column 1
grid .controls.view         -row 2 -column 2 -padx 4 -pady 2 -sticky ew
grid .controls.line2        -row 3 -column 0 -pady 2 -columnspan 3 -sticky ew
grid .controls.columnsLabel -row 4 -column 0 -padx 4 -sticky w
grid .controls.columns      -row 4 -column 1 -pady 2 -sticky w
grid .controls.exit         -row 4 -column 2 -padx 4 -pady 2 -sticky ew

pack .controls

bind .controls.library <Return> displayIcons
bind .controls.groups  <Return> displayIcons
bind .controls.libraryLabel <ButtonRelease-1> setMode 

frame     .display -borderwidth 2 -relief sunken
scrollbar .display.xscrollbar -command ".display.icons xview" -orient horizontal
scrollbar .display.yscrollbar -command ".display.icons yview" -orient vertical
canvas    .display.icons -xscrollcommand ".display.xscrollbar set" -yscrollcommand ".display.yscrollbar set"
pack      .display.yscrollbar -side right  -fill y
pack      .display.xscrollbar -side bottom -fill x
pack      .display.icons      -side left   -fill both -expand yes

frame     .display.icons.layout
pack      .display.icons.layout

.display.icons create window 0 0 -anchor nw -window .display.icons.layout

bind .display.icons.layout <Configure> "layoutResize"

pack .display -expand yes -fill both

wm title . "viewIcons"

layoutResize

wm resizable . 0 1

#-----------------------------------------------------------------------#
# Create "window" for icon info.                                        #
#-----------------------------------------------------------------------#

toplevel .infoWindow -background lightyellow -borderwidth 1 -relief solid

label .infoWindow.nameLabel   -background lightyellow -font $BOLDFONT -justify left -text "Name"
label .infoWindow.groupsLabel -background lightyellow -font $BOLDFONT -justify left -text "Groups"
label .infoWindow.typeLabel   -background lightyellow -font $BOLDFONT -justify left -text "Type"
label .infoWindow.sizeLabel   -background lightyellow -font $BOLDFONT -justify left -text "Size"
label .infoWindow.name        -background lightyellow -justify left
label .infoWindow.groups      -background lightyellow -justify left
label .infoWindow.type        -background lightyellow -justify left
label .infoWindow.size        -background lightyellow -justify left

grid  .infoWindow.nameLabel   -row 0 -column 0 -sticky w
grid  .infoWindow.name        -row 0 -column 1 -sticky w
grid  .infoWindow.groupsLabel -row 1 -column 0 -sticky w
grid  .infoWindow.groups      -row 1 -column 1 -sticky w
grid  .infoWindow.typeLabel   -row 2 -column 0 -sticky w
grid  .infoWindow.type        -row 2 -column 1 -sticky w
grid  .infoWindow.sizeLabel   -row 3 -column 0 -sticky w
grid  .infoWindow.size        -row 3 -column 1 -sticky w

wm overrideredirect .infoWindow 1
wm withdraw .infoWindow

#=======================================================================#
# End of script: viewIcons.tcl                                          #
#=======================================================================#

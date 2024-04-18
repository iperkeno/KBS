#=======================================================================#
# SCRIPT : icons.tcl                                                    #
# PURPOSE: Create icon images from contents of icon library file or     #
#        : directory.                                                   #
# AUTHOR : Adrian Davis                                                 #
# VERSION: 2.0                                                          #
# DATE   : 01/07/2013                                                   #
#-----------------------------------------------------------------------#
# HISTORY: 1.0 ??/??/???? - First release.                              #
#        : 1.2 ??/??/???? - ????                                        #
#        : 2.0 01/07/2013 - Adds support for directories of icon images.#
#-----------------------------------------------------------------------#
# NAME                                                                  #
#    icons                                                              #
# SYNOPSIS                                                              #
#    icons mode ?arg arg ...?                                           #
# DESCRIPTION                                                           #
#    icons create ?option value ...? ?iconlist?                         #
#    icons delete ?iconlist?                                            #
#    icons query ?option value ...? ?iconlist?                          #
# OPTIONS                                                               #
#    -file                                                              #
#    -group                                                             #
#    -items                                                             #
#=======================================================================#

package require Tk    8.5
package provide icons 2.0

#=======================================================================#
# Export the public interface.                                          #
#=======================================================================#

namespace eval ::icons:: {
   namespace export icons
}

#=======================================================================#
# PROC   : ::icons::icons                                               #
# PURPOSE: Exported command.                                            #
#=======================================================================#

proc ::icons::icons {args} {

   # Check for a simple error.
   if {[llength $args] < 2} {
      error "ERROR: Wrong number of Args"
   }

   # Set defaults for options.
   set file      tkIcons
   set groupList {}
   set iconList  {}
   set items     ngts

   set mode [lindex $args 0]

   # If there are an even number of arguments there cannot be
   # a set of option/value pairs. In this case assume the last
   # argument is an "iconlist".
   if {[expr {[llength $args] % 2}] == 0} {
      set iconList [lindex [lrange $args end end] 0]
      set lastArg  [expr {[llength $args] - 2}]
   } else {
      set lastArg  [expr {[llength $args] - 1}]
   }

   # Read/validate option/value pairs.
   foreach {option value} [lrange $args 1 $lastArg] {
      switch -- $option {
         -file   {set file $value}
         -group  {set groupList $value}
         -items  {set items $value}
         default {error "ERROR: Invalid option ($option)"}
      }
   }

   # If file is not a directory assume processing
   # icon images from icon library.
   if {! [file isdirectory $file]} {
      # ...Check for file. If file does not exist in
      # specified path check if the file exists relative
      # to the "library" path.
      if {! [file exists $file]} {
         if {[file exists [file join [info library] $file]]} {
            set file [file join [info library] $file]    
         } else {
            if {[string compare $mode delete] != 0} {
               error "ERROR: Invalid file ($file)"
            }
         }
      }
   }

   # Call appropriate procedure according to specified mode.
   switch -- $mode {
      create  {create $file $groupList $iconList}
      delete  {delete $iconList}
      query   {query $file $groupList $items $iconList}
      default {error "ERROR: Invalid mode ($mode)"}
   }

}

#=======================================================================#
# PROC   : ::icons::create                                              #
# PURPOSE: Create specified icons.                                      #
#=======================================================================#

proc ::icons::create {file groupList iconList} {

   set iconCreate {}

   # If "file" is a directory assume processing icon
   # images from files in the specified directory.
   if {[file isdirectory $file]} {
      
      # If a group list is specified then create icons
      # from files matching the groupList glob pattern.
      if {[llength $groupList] == 1} {
         foreach iconFile [glob -nocomplain -directory $file -types f $groupList{.png,.gif}] {
            set iconName [file tail [file rootname $iconFile]]
            image create photo ::icon::$iconName -file $iconFile
            lappend iconCreate $iconName
         }
      } else {
         foreach iconName $iconList {
            # Check for PNG, GIF and exact name match files.
            foreach imageType {.png .gif {}} {
               if {[file exists [file join $file $iconName$imageType]]} {
                  image create photo ::icon::$iconName -file [file join $file $iconName$imageType]
                  lappend iconCreate $iconName
                  break
               }
            }   
         }
      }
      
      return $iconCreate
   }

   # If "file" is a file assume processing icon
   # images from an icon library.
   set iconLibrary    [open $file r]
   set iconMatchCount 0

   # If no groups have been specified it is possible to
   # exit this procedure when all specified icons have
   # been created. Set flag and initialise counter.
   if {[llength $groupList] == 0} {
      set iconListCount [llength $iconList]
      set iconOnly      1
   } else {
      set iconListCount 0
      set iconOnly      0
   }

   # Read the contents of the icon library file.
   while {[gets $iconLibrary iconInfoRecord] >= 0} {
      set iconInfo    [split $iconInfoRecord :]
      set iconItem(n) [lindex $iconInfo 0]
      set iconItem(g) [lindex $iconInfo 1]
      set iconItem(d) [lindex $iconInfo 4]
      set createMatch  0

      # If the icon name -or- one of the icon groups
      # match, set "match" flag.
      if {[lsearch $iconList $iconItem(n)] > -1} {
         set  createMatch 1
         incr iconMatchCount
      } else {
         foreach group $groupList {
            if {[lsearch $iconItem(g) $group] > -1} {
               set createMatch 1
            }
         }
      }

      # If "match" flag set, create image for icon and append name
      # to list of icons created.
      if {$createMatch} {
         image create photo ::icon::$iconItem(n) -data $iconItem(d)
         lappend iconCreate $iconItem(n)
      }

      unset iconItem

      # If no groups have been specified, exit procedure
      # if all specified icons have been created.
      if {$iconOnly} {
         if {$iconListCount == $iconMatchCount} {
            close  $iconLibrary
            return $iconCreate
         }
      }
   }

   close  $iconLibrary
   return $iconCreate
}

#=======================================================================#
# PROC   : ::icons::delete                                              #
# PURPOSE: Delete specified icons.                                      #
#=======================================================================#

proc ::icons::delete {iconList} {

   # Delete image for each of the specified icons.
   foreach icon $iconList {
      image delete ::icon::$icon
   }
}

#=======================================================================#
# PROC   : ::icons::query                                               #
# PURPOSE: Procedure to return specified contents of icon library file. #
#=======================================================================#

proc ::icons::query {file groupList items iconList} {

   set iconQuery {}

   # If "file" is a directory assume processing icon
   # images from files in the specified directory.
   
   if {[file isdirectory $file]} {
      
      # If a group list is specified then query icons
      # from files matching the groupList glob pattern.
      if {[llength $groupList] == 1} {
         foreach iconFile [glob -nocomplain -directory $file -types f $groupList{.png,.gif}] {
            set iconItems   {}
            set iconName    [file tail [file rootname $iconFile]]
            set iconItem(n) $iconName
            set iconItem(g) "N/A"
            set iconItem(t) [string map {.png PNG .gif GIF} [file extension $iconFile]]
            
            # Size and data information only available if icon image has been created.
            if {[lsearch [image names] ::icon::$iconName] < 0} {
               set iconItem(s) "Not avialable"
               set iconItem(d) "Not available"
            } else {
               set iconItem(s) "[image width ::icon::$iconName] [image height ::icon::$iconName]"
               if {$::tcl_version >= 8.6} {
                  set iconItem(d) [binary encode base64 [::icon::$iconName data -format $iconItem(t)]]
               } else {
                  set iconItem(d) "**Option requires Tcl 8.6 or greater**"
               }
            }

            foreach item [split $items {}] {
               lappend iconItems $iconItem($item)
            }
            lappend iconQuery $iconItems
            unset iconItem
         }
      } else {
         foreach iconName $iconList {
            
            # Check for PNG, GIF and exact name match files.
            foreach imageType {.png .gif {}} {
               if {[file exists [file join $file $iconName$imageType]]} {
                  set iconItems   {}
                  set iconItem(n) $iconName
                  set iconItem(g) "N/A"
                  set iconItem(t) [string map {.png PNG .gif GIF} $imageType]
                  
                  # Size and data information only available if icon image has been created.
                  if {[lsearch [image names] ::icon::$iconName] < 0} {
                     set iconItem(s) "Not avialable"
                     set iconItem(d) "Not available"
                  } else {
                     set iconItem(s) "[image width ::icon::$iconName] [image height ::icon::$iconName]"
                     if {$::tcl_version >= 8.6} {
                        set iconItem(d) [binary encode base64 [::icon::$iconName data -format $iconItem(t)]]
                     } else {
                        set iconItem(d) "**Option requires Tcl 8.6 or greater**"
                     }
                  }
                  break
               }
            }
            foreach item [split $items {}] {
               lappend iconItems $iconItem($item)
            }
            lappend iconQuery $iconItems
            unset iconItem
         }
      }
      
      return $iconQuery  
   }

   # If "file" is a file assume processing icon
   # images from an icon library.

   set iconLibrary    [open $file r]
   set iconMatchCount 0

   # If no groups have been specified it is possible to
   # exit this procedure when all specified icons have
   # been found. Set flag and initialise counter.
   if {[llength $groupList] == 0} {
      set iconListCount [llength $iconList]
      set iconOnly      1
   } else {
      set iconListCount 0
      set iconOnly      0
   }

   # Read the contents of the icon library file.
   while {[gets $iconLibrary iconInfoRecord] >= 0} {
      set iconInfo    [split $iconInfoRecord :]
      set iconItem(n) [lindex $iconInfo 0]
      set iconItem(g) [lindex $iconInfo 1]
      set iconItem(t) [lindex $iconInfo 2]
      set iconItem(s) [lindex $iconInfo 3]
      set iconItem(d) [lindex $iconInfo 4]
      set iconItems   {}
      set queryMatch  0

      # If the icon name -or- one of the icon groups
      # match, set "match" flag.
      if {[lsearch $iconList $iconItem(n)] > -1} {
         set  queryMatch 1
         incr iconMatchCount
      } else {
         foreach group $groupList {
            if {[lsearch $iconItem(g) $group] > -1} {
               set queryMatch 1
            }
         }
      }

      # If match flag set, append each of the specified
      # items to the items list, then append completed
      # items list to the result list.
      if $queryMatch {
         foreach item [split $items {}] {
            lappend iconItems $iconItem($item)
         }
         lappend iconQuery $iconItems
      }

      unset iconItem

      # If no groups have been specified, exit procedure
      # if all specified icons have been found.
      if $iconOnly {
         if {$iconListCount == $iconMatchCount} {
            close  $iconLibrary
            return $iconQuery
         }
      }
   }

   close  $iconLibrary
   return $iconQuery
}

#=======================================================================#
# End of Script: icons.tcl                                              #
#=======================================================================#

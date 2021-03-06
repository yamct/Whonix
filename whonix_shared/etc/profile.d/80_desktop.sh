#!/bin/bash

## Whonix /etc/profile.d/80_desktop.sh

if [ ! "$(tty)" = "/dev/tty1" ]; then
   return 0
else
   for i in /etc/whonix.d/*; do
      if [ -f "$i" ]; then
         ## If the last character is a ~, ignore that file,
         ## because it was created by some editor,
         ## which creates backup files.
         if [ "${i: -1}" = "~" ]; then
            continue
         fi
         source "$i"
      fi
   done

   ## Sanity Tests, Defaults, Debugging
   if [ -z "$whonixdesktop_debug" ]; then
      whonixdesktop_debug=0
   fi
   if [ "$whonixdesktop_debug" = 1 ]; then
      set -x
   fi
   if [ -z "$whonixdesktop_display_manager" ]; then
      whonixdesktop_display_manager=kdm
   fi
   if [ -z "$whonixdesktop_minium_ram" ]; then
      whonixdesktop_minium_ram=500
   fi
   if [ -z "$whonixdesktop_start_display_manager" ]; then
      whonixdesktop_start_display_manager=1
   fi
   if [ -z "$whonixdesktop_skip_ram_test" ]; then
      whonixdesktop_skip_ram_test=0
   fi
   if [ -z "$whonixdesktop_wait" ]; then
      whonixdesktop_wait=1
   fi
   if [ -z "$whonixdesktop_wait_seconds" ]; then
      whonixdesktop_wait_seconds=10
   fi
   if [ -z "$whonixdesktop_autostart_decision_feature" ]; then
      whonixdesktop_autostart_decision_feature=1
   fi
   
   if [ ! "$whonixdesktop_autostart_decision_feature" = "1" ]; then
      if [ "$whonixdesktop_debug" = 1 ]; then  
         echo "/etc/profile.d/80_desktop.sh INFO: whonixdesktop_autostart_decision_feature is not set to 1, doing nothing."
      fi
      return 0
   fi

   which "$whonixdesktop_display_manager" >/dev/null
   ret="$?"

   if [ ! "$ret" = "0" ]; then
      if [ "$whonixdesktop_debug" = 1 ]; then
         echo "/etc/profile.d/80_desktop.sh INFO: display manager \
$whonixdesktop_display_manager configured in /etc/whonix.d/ \
configuration folder does not exist. Not starting a desktop environment."
      fi
      return 0
   fi

   ## There is a /etc/sudoers.d/kdm exception for this.
   sudo service "$whonixdesktop_display_manager" status >/dev/null
   ret="$?"

   if [ "$ret" = "0" ]; then
      if [ "$whonixdesktop_debug" = 1 ]; then
         echo "/etc/profile.d/80_desktop.sh INFO: \
Not starting kdm, already running."
      fi
      ## return, not exit, because this file gets sourced (not executed)
      ## by /etc/profile.
      return 0
   fi

   if [ "$whonixdesktop_debug" = 1 ]; then
      temp="/etc/profile.d/80_desktop.sh INFO: $(/bin/date) | \
      whoami: $(/usr/bin/whoami) | caller: $0 | path: $PATH"
      echo "$x"
      echo "$x" >> /var/log/whonixdesktop
      chown user:user /var/log/whonixdesktop
      chmod g+w /var/log/whonixdesktop
      chmod o+w /var/log/whonixdesktop
   fi

   ## Check how much RAM the system has in total.
   ## Thanks to:
   ## http://stackoverflow.com/a/10277712
   total_ram="$(free -m | sed  -n -e '/^Mem:/s/^[^0-9]*\([0-9]*\) .*/\1/p')"

   if [ "$whonixdesktop_wait" = 0 ]; then
      return 0
   fi

   if [ "$whonixdesktop_start_display_manager" = 0 ]; then
      if [ "$whonixdesktop_debug" = 1 ]; then
         echo "/etc/profile.d/80_desktop.sh INFO: \
whonixdesktop_start_display_manager is set to 0 in /etc/whonix.d/ \
configuration folder, not starting a desktop environment."
      fi
      return 0
   fi

   if [ ! "$whonixdesktop_skip_ram_test" = "1" ]; then
      if [ "$total_ram" -lt "$whonixdesktop_minium_ram" ]; then
         echo "/etc/profile.d/80_desktop.sh INFO: Not starting login manager \
(graphical desktop environment) ($whonixdesktop_display_manager), \
because there is only "$total_ram" MB total RAM. (A minimum of \
"$whonixdesktop_minium_ram" MB total RAM is configured in /etc/whonix.d/ \
configuration folder.)"
         return 0
      fi
   fi

   echo "/etc/profile.d/80_desktop.sh INFO: Starting login manager \
(graphical desktop environment) "$whonixdesktop_display_manager" in \
"$whonixdesktop_wait_seconds" seconds, unless you abort using ctrl + c. \
This can be disabled or configured in /etc/whonix.d/ configuration folder."

   sleep "$whonixdesktop_wait_seconds"

   ## There is a /etc/sudoers.d/kdm exception for this.
   sudo /usr/sbin/service "$whonixdesktop_display_manager" start
   ret="$?"

   if [ "$whonixdesktop_debug" = 1 ]; then
      set +x
   fi

fi

## End of Whonix /etc/profile.d/80_desktop.sh

#!/bin/bash

###REQUIREMENTS:
# download, compile and install xprintidle,
#available from "http://www.dtek.chalmers.se/~henoch/text/xprintidle.html"
# install gxmessage

# the user running this script must have sudo access to the "shutdown" command without passwd
# u can do this by adding "%wheel ALL=(ALL) NOPASSWD: /sbin/shutdown" for gentoo
# change "wheel" to "users" if the user doesn't have wheel access

###VARIABLES

## Settings
#required idletime in milliseconds before shutting down(1hr=3600000ms)
reqidletime=30000

#maximum 1 minute load average for shutdown (scales from 1-32...)
#(This needs some work,it doesn't work behind the comma, and is
#interpreted as a integer atm)
# maxloadavg=1

#programs that should prohibit shutdown
# programs="mplayer ktorrent emerge cc"



##Needed Variables
#measures the current loadavg
# loadavg=0
#the current measured idletime
idletime=0
#variable that lists each seperate program in the $programs array
# each=""

## Status Flags(important internal variables)
#flag to check if the load is too high or not, 1 means too high
# loadstatus=0
#flag to check if the idletime needed to shutdown is aqcuired, 1 means shutdown
idleack=0



### SHUTDOWN CHECK LOOP
#check if idletime is acquired, if it is, just quit(system will aready be shutting down)
while [ $idleack -lt 1 ] ; do
   # sleep time( this script only needs to run once in a while ofcourse :)
   sleep 30

   #check the current idletime(in milliseconds)
   idletime=$(xprintidle)
   #setting $idleack flag, depending on the current idletime
   if [ $idletime -gt $reqidletime ]; then
      idleack=1
   else
      idleack=0
   fi
   # Starting shutdown check
   if [ $idleack = 1 ]; then
      #check the current 1 min loadaverage
      # loadavg=$(cat /proc/loadavg | cut -c 1)
      #checking if 1min loadavg is exceeding max loadavg allowed
      # if [ $loadavg -lt $maxloadavg ]; then
         #setting status to allowed
         # loadstatus=0
      # else
         #setting status to disallowed to reboot
         # loadstatus=1
      # fi

      #checking if the load is ok
      # if [ $loadstatus = 0 ]; then
            #running prohibition program check for each program
            # for each in $programs ; do
               # progcheck=$(ps aux | grep -i $each | wc -l)
               # if [ $progcheck = "2" ]; then
                  # idleack=0
               # fi
            # done
         # if [ $idleack = 1 ]; then
            # check=$(gxmessage -center -print -timeout 10 -buttons "CANCEL:1" The system has been idle to for $idletime ms and will shutdown in 60 seconds, press cancel to abort)
            # if [ "$check" = "CANCEL" ]; then
               #reset idleack to fix the loop(if it remains to 1, the loop will exit)
               # idleack=0
            # else
               # sudo shutdown -h now
            gnome-screensaver-command -l -a
            # fi
         # fi
      # fi
   fi
done

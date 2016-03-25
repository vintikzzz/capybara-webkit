#!/bin/bash

PIDFILE=$XVFB_PIDFILE

case $1 in
   start)
       Xvfb $DISPLAY -ac -screen 0 $XVFB_RES -nolisten tcp &
       # Get its PID and store it
       echo $! > ${PIDFILE}
   ;;
   stop)
      kill `cat ${PIDFILE}`
      # Now that it's killed, don't forget to remove the PID file
      rm ${PIDFILE}
   ;;
   *)
      echo "usage: run_xvfb.sh {start|stop}" ;;
esac
exit 0

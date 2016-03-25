#!/bin/bash
case $1 in
  start)
    cd $APP_DIR
    # Launch your program as a detached process
    bundle exec rake >> $WEBKIT_LOG 2>&1 &
  ;;
  stop)
    kill `cat $PIDFILE`
  ;;
  *)
    echo "usage: run_server.sh {start|stop}" ;;
esac
exit 0

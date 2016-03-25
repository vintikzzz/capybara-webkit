touch $WEBKIT_LOG
envsubst < monitrc.template > /etc/monit/monitrc
tail -f $WEBKIT_LOG &
monit -I

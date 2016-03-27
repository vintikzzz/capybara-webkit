touch $WEBKIT_LOG
touch $MONIT_LOG
tail -f $WEBKIT_LOG &
tail -f $MONIT_LOG &
envsubst < monitrc.template > /etc/monit/monitrc
monit -I

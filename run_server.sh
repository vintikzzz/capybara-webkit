touch $WEBKIT_LOG
tail -f $WEBKIT_LOG &
god -c god.rb -D

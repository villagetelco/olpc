#!/bin/sh

# /www/cgi-bin/config/config-sub-olpc.sh
# This script saves the settings when the OLPC page is submitted

# Build the new script file
#---------------------------------------------------
cat > /tmp/conf-save.sh << EOF

#!/bin/sh

# Set default values for checkboxes and buttons

BUTTON="0"
NETACCESS="0"
ENUSBMODEM="0"
MULTICLASS="0"

# Get Field-Value pairs from QUERY_STRING enironment variable
# set by the form GET action
# Cut into individual strings: Field=Value

`echo $QUERY_STRING | cut -d \& -f 1`
`echo $QUERY_STRING | cut -d \& -f 2`
`echo $QUERY_STRING | cut -d \& -f 3`
`echo $QUERY_STRING | cut -d \& -f 4`
`echo $QUERY_STRING | cut -d \& -f 5`
`echo $QUERY_STRING | cut -d \& -f 6`
`echo $QUERY_STRING | cut -d \& -f 7`
`echo $QUERY_STRING | cut -d \& -f 8`
`echo $QUERY_STRING | cut -d \& -f 9`
`echo $QUERY_STRING | cut -d \& -f 10`
`echo $QUERY_STRING | cut -d \& -f 11`
`echo $QUERY_STRING | cut -d \& -f 12`
`echo $QUERY_STRING | cut -d \& -f 13`
`echo $QUERY_STRING | cut -d \& -f 14`
`echo $QUERY_STRING | cut -d \& -f 15`


# Refresh screen without saving 
if [ \$BUTTON = "Refresh" ]; then
	exit
fi

# Get logged in user
LOGINUSER=`cat /tmp/auth.txt`

# Change password, save the result, prepare status message, set web auth on.
rm /tmp/passwordstatus.txt
if [ \$BUTTON = "Set+Password" ]; then
	date > /tmp/setpassword.txt
	(echo \$PASSWORD1; sleep 1; echo \$PASSWORD2) | passwd \$LOGINUSER >> /tmp/setpassword.txt
	cat /tmp/setpassword.txt | grep change > /tmp/passwordstatus.txt
	echo ". Reboot to activate web UI Authentication" >> /tmp/passwordstatus.txt
	uci set secn.http.pw_preset="1"
	uci set secn.http.auth="checked"
	uci commit secn
	exit
fi


# Write TimeZone into /etc/TZ
echo \$TZ > /etc/TZ
uci set system.@system[0].timezone=\$TZ
uci commit system

# Save settings
uci set olpc.setup.class=\$CLASS
uci set olpc.setup.mode=\$MODE
uci set olpc.setup.netaccess=\$NETACCESS
uci set olpc.setup.enusbmodem=\$ENUSBMODEM
uci set olpc.setup.ssidprefix=\$SSIDPREFIX
uci set olpc.setup.ssid=\$SSID
uci set olpc.setup.passphrase=\$PASSPHRASE
uci set olpc.setup.multiclass=\$MULTICLASS

# Commit the settings 
uci commit olpc


# Create new config files
/etc/init.d/config_olpc > /dev/null
/etc/init.d/config_secn > /dev/null
/etc/init.d/config_secn-2 > /dev/null
# Make sure file writing is complete
sleep 2

# Save and Reboot
if [ \$BUTTON = "Reboot" ]; then
  # Output the reboot screen
  echo -en "Content-type: text/html\r\n\r\n"
  cat /www/cgi-bin/config/html/reboot.html
  touch /tmp/reboot			# Set rebooting flag
  /sbin/reboot -d 10		# Reboot after delay
fi

EOF
#-------------------------------------------------


# Make the file executable and run it to update the config settings
# Catch any error messages
chmod +x /tmp/conf-save.sh     > /dev/null
/tmp/conf-save.sh

# Check if rebooting
if [ -f /tmp/reboot ]; then
	exit
fi 

# Build the configuration screen and send it back to the browser.
/www/cgi-bin/secn-olpc

# Clean up temporary files
###rm /tmp/conf-save.sh           > /dev/null
###rm /tmp/config.html            > /dev/null


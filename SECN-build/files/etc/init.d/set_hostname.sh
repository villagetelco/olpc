#!/bin/sh

CLASS=`uci get olpc.setup.class`
MODE=`uci get olpc.setup.mode`

HOST="OLPC"$CLASS

# Set the host name
if [ $MODE = "Master" ];then
  HOST=$HOST
elif [ $MODE = "Slave-1" ];then
  HOST=$HOST"SL1"
elif [ $MODE = "Slave-2" ];then
  HOST=$HOST"SL2"
elif [ $MODE = "Slave-3" ];then
  HOST=$HOST"SL3"
fi

# Add Slaves to /etc/hosts
OCTET123=`uci show network.lan.ipaddr | cut -d = -f 2 | cut -d . -f 1,2,3`
echo "127.0.0.1 localhost"              > /etc/hosts
echo $OCTET123".254"" OLPC"$CLASS      >> /etc/hosts
echo $OCTET123".241"" OLPC"$CLASS"SL1" >> /etc/hosts
echo $OCTET123".242"" OLPC"$CLASS"SL2" >> /etc/hosts
echo $OCTET123".243"" OLPC"$CLASS"SL3" >> /etc/hosts

# Set the hostname
uci set system.@system[0].hostname=$HOST
uci commit system

# Set the hostname as the Common Name in the SSL certificate for the web server.
uci set uhttpd.px5g.commonname=$HOST
uci commit uhttpd

# Set the system hostname
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname



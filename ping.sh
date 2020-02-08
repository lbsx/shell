#!/bin/bash
ping_func(){
	IP=$1
	ping -c 1 -w 1 $IP  >/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo  $IP
	fi
}
gateway=$1
for i in {1..254};do
	IP=${gateway:-10.14.97}.$i
	#IP=rdvdesk$i.hikvision.com
	ping_func $IP &

done
# waiting ping finished.
while true;do
	if ! ps aux|grep "ping -c 1 -w 1" |grep -v grep >/dev/null ;then
		break
	fi
	sleep 1
done
exit 0

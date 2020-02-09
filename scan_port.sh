#!/bin/bash
ip=$1
start=${2:-1}
end=${3:-65535}
if [ -z $ip ];then 
	read -p "please input ip:" ip
	exit 1
fi

CMD="nc -w 1 -z"

scan_func(){
	ip=$1
	port=$2
	$CMD $ip $port 
	if [[ $? -eq 0 ]];then
		echo $port | tee  port.txt
	fi
}

waiting(){
# waiting finished
while true;do
	if ! ps aux|grep "$CMD" |grep -v grep >/dev/null;then
		break
	fi
	sleep 1
done
}

echo -n > port.txt
count=0
for port in `seq $start $end`;do
	scan_func $ip $port &
	let count++
	if [ $count -eq 100 ];then
		waiting
		count=0
	fi
done
waiting
exit 0

#!/bin/bash
#echo "Welcome to use ${BASH_SOURCE}"
log_info(){
	echo -n "[`date \"+%Y-%m-%d %H:%M:%S\"`] [${BASH_SOURCE}][$BASH_LINENO]:"
	echo $*
}
log_exec(){
	echo -n "[`date \"+%Y-%m-%d %H:%M:%S\"`] [${BASH_SOURCE}][$BASH_LINENO]"
	echo "[cmd]:${@}"
	$*
}
remote_exec(){
	if [[ $1 == custom* ]];then
		shift
		IP=${1:-"192.168.122.164"}
		shift
		PASSWD=${1:-"wu"}
		shift
	fi
	if [ "x${IP}x" == "xx" -o "x${PASSWD}x" == "xx" ];then
		echo -e "remote_exec function usage: \n\t1. IP=192.168.0.2; PASSWD=xxx\n\t   remote_exec some_cmd\n\t2. remote_exec custom 192.168.0.2 passwd some_cmd
		"
		exit 1
	fi
	CMD=$@
	expect -c "
		set timeout 20
		spawn ssh root@$IP $CMD
		expect {
			\"(yes/no)?\"
				{
					send \"yes\n\"
					expect \"assword:\"	{send \"$PASSWD\n\"}
				}
			\"*assword:\"
				{
					send \"$PASSWD\n\"
				}
		} 
		expect eof
	"
}
# remote_exec custom "192.168.122.164" "wu" touch expect.txt

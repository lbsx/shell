#!/bin/bash
# https://www.linuxbabe.com/ubuntu/shadowsocks-libev-proxy-server-ubuntu
set -e 
download_link=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.3.4/shadowsocks-libev-3.3.4.tar.gz

if which apt;then
    VERSION=$(cat /etc/os-release  |grep -Po "PRETTY_NAME=.*\(\K\w+")
    sed -i  "$a deb http://ftp.de.debian.org/debian $VERSION main" /etc/apt/sources.list
    apt update

    apt install -y build-essential libpcre3-dev asciidoc libmbedcrypto* libmbedtls-dev libsodium-dev libc-ares-dev libev-dev 
else
   yum groupinstall -y development tools
   yum install -y epel-release
   yum update
   yum install -y pcre-devel xmlto libblockdev-crypto-devel asciidoc c-ares-devel libev-devel libblockdev-crypto-devel libsodium-devel mbedtls-devel
   
fi

ip=$(ip a |grep inet|grep brd | grep -oP "inet \K([0-9]{1,3}[.]){3}[0-9]{1,3}")
cat >config.json <<EOF 
{
    "server":"$ip",
    "mode":"tcp_and_udp",
    "server_port":443,
    "password":"a29fdsafsafjklmf",
    "timeout":60,
    "method":"aes-192-cfb"
}
EOF

# download shadowsock file

wget $download_link
tar_file=${download_link##*/}
tar xzf $tar_file
echo $tar_file
cd ${tar_file%.*.*}
echo "current dir:$(pwd)"
./configure
make 
make install 
cd ..

# change TCP Congestion Avoidance Algorithm 
# check linux kernel veresion > 4.9
set +e
kernel_version=$(uname -r |cut -d- -f1)
greater_num=$(echo "4.9 $kernel_version" |tr " " "\n"|sort -rV|head -1)
if [[ $greater_num == $kernel_version ]];then
    sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
    sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
    echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1
    
    param=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
    if [[ $param == bbr ]];then
    	echo "INFO: Setting TCP BBR completed..."
    fi
    
else
    echo "ERROR: Your kernel version is less than 4.9, can't set bbr algorithm"
fi

nohup ss-server -c config.json

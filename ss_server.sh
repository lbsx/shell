#!/bin/bash

download_link=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v3.3.4/shadowsocks-libev-3.3.4.tar.gz


apt install -y libpcre3-dev asciidoc libmbedcrypto3 libmbedtls-dev libsodium-dev libc-ares-dev libev-dev 
sed -i  '$a deb http://ftp.de.debian.org/debian buster main' /etc/apt/sources.list
apt update
ip=$(ip a |grep inet|grep brd | grep -oP "inet \K([0-9]{1,3}[.]){3}[0-9]{1,3}")
cat >>config.json <<EOF 
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
if [ $? -eq 0 ];then
	make 
	make install 
fi
nohup ss-server -c config.json

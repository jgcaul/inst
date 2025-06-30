###############

silent() { "$@" >/dev/null 2>&1; }

echo "Installing Dependencies"
silent apt-get update -y
silent apt-get install -y curl sudo mc
echo "Installed Dependencies"

cd /root

mirror=$1
arch=$([[ "$(arch)" == "aarch64" ]] && echo _arm64)
[[ -z "$mirror" ]] && mirror=http://106.52.32.20/gitea/minlearn/inst/raw/branch/master/_build/appp
mkdir -p download
[[ ! -f download/tmp.tar.gz ]] && wget --no-check-certificate $mirror/gost/gost$arch.tar.gz -O download/tmp.tar.gz

mkdir -p app/gost
tar -xzvf download/tmp.tar.gz -C app/gost gost # --strip-components=1

cat > /lib/systemd/system/gost.service << 'EOL'
[Unit]
Description=this is gost service,please change the token then daemon-reload it
After=network.target nss-lookup.target
Wants=network.target nss-lookup.target
Requires=network.target nss-lookup.target

[Service]
Type=simple
ExecStart=/root/app/gost/gost -C /root/app/gost/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOL

cat > /root/app/gost/config.json << 'EOL'
{
    "Debug": true,
    "Retries": 0,
    "ServeNodes": [
           "tcp://:13389/xxx.xxx.xxx.xxx:3389"
    ]
}
EOL

cat > /root/ip.sh << 'EOL'
read -p "give a ip:" ip </dev/tty
date=xxx.xxx.xxx.xxx
sed -i s#${date}#${ip}#g /root/app/gost/config.json
systemctl restart gost
EOL
chmod +x /root/ip.sh


systemctl enable -q --now gost


echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############

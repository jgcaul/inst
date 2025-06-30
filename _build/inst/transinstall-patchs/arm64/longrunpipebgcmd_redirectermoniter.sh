#!/bin/sh

. /usr/share/debconf/confmodule
debconf-loadtemplate my_script /longrunpipebgcmd_redirectermoniter.templates

corefiles=$1
DEBMIRROR=`echo "$corefiles" | awk -F ',' '{ print $1}'`
TARGETDDURL=`echo "$corefiles" | awk -F ',' '{ print $2}'`
UNZIP=`echo "$corefiles" | awk -F ',' '{ print $3}'`

hd=$2
# exit 0 is important when there is more than 1 block,it may failed
hdinfo=`[ \`echo "$hd"|grep "nonlinux"\` ] && echo \`lsblk -d -n -o NAME | grep -E '^(sd|vd|nvme|xvd)' | head -n 1 | sed 's|^|/dev/|'\` || { [ \`echo "$hd"|grep "sd\|vd\|xvd\|nvme"\` ] && echo /dev/"$hd" || ( for i in \`lsblk -d -n -o NAME | grep -E '^(sd|vd|nvme|xvd)'  | sed 's|^|/dev/|'\`;do [ \`sfdisk --disk-id $i|sed s/0x// |grep -ix $hd \` ] && echo $i;done|head -n1;exit 0; ); }`
# busybox sh dont support =~
hdinfoname=`[ \`echo "$hdinfo"|grep -Eo "nvme"\` ] && echo $hdinfo"p" || echo $hdinfo`
logger -t minlearnadd preddtime hdinfoname:$hdinfoname

nicinfo=$3

instctlinfo=$4
CTLPT=`echo "$instctlinfo" | awk -F ':' '{ print $1}'`
CTLIP=`echo "$instctlinfo" | awk -F ':' '{ print $2}'`
logger -t minlearnadd instctl port info:$CTLPT ip info:$CTLIP

passwordinfo=$5
logger -t minlearnadd password info:$passwordinfo

netinfo=$6
# dhcp only slipstreamed to targetos, in di initramfs always use fixed static netcfgs because dhcp not smart enough always
ISDHCP=`[ \`echo "$netinfo"|grep -Eo "dhcp"\` ] && echo 1 || echo 0`
staticnetinfo=`echo "$netinfo"|sed s/,dhcp//g`
IP=`[ -n "$staticnetinfo" ] && echo "$staticnetinfo" | awk -F ',' '{ print $1}'`
MASK=`[ -n "$staticnetinfo" ] && echo "$staticnetinfo" | awk -F ',' '{ print $2}'`
GATE=`[ -n "$staticnetinfo" ] && echo "$staticnetinfo" | awk -F ',' '{ print $3}'`
IPTYPE=`[ -n "$IP" ] && [ \`echo "$IP"|grep ":"\` ] && echo v6 || echo v4`
logger -t minlearnadd preddtime IP:$IP,MASK:$MASK,GATE:$GATE,IPTYPE:$IPTYPE,ISDHCP:$ISDHCP

PIPECMDSTR='wget -qO- --no-check-certificate '\"$DEBMIRROR/_build/inst/transinstall-patchs/arm64/tools_arm64.tar.gz\"'|tar -zxf - -C / --no-overwrite-dir --keep-directory-symlink;wget -q --no-check-certificate '\"$TARGETDDURL\"' -O p4/tmp.iso 2>> /var/log/progress & pid=`expr $! + 0`;echo $pid'
logger -t minlearnadd preddtime PIPECMDSTR:"$PIPECMDSTR"




post(){

           [ "$CTLIP" != '' -a "$CTLPT" != '' ] && [ "$CTLIP" != '0.0.0.0' -o "$CTLPT" != 80 ] && cp /bin/rathole p4/onekeydevdesk/01-core/bin/rathole && echo -e "[client]\n\
remote_addr = \"$CTLIP:2333\"\n\
default_token = \"default_token_if_not_specify\"\n\
heartbeat_timeout = 30\n\
retry_interval = 3\n\
[client.services.$CTLPT]\n\
local_addr = \"127.0.0.1:8006\"" > p4/onekeydevdesk/01-core/etc/rathole.toml && cat > p4/onekeydevdesk/01-core/etc/init.d/rathole <<'EOF' && chmod +x p4/onekeydevdesk/01-core/etc/init.d/rathole && chroot p4/onekeydevdesk/01-core update-rc.d rathole defaults
#!/bin/bash
### BEGIN INIT INFO
# Provides:          rathole
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: rathole service
# Description:       Initializes and manages the rathole service
### END INIT INFO

# Path to the rathole binary and configuration file
RATHOLE_EXEC="/bin/rathole"
RATHOLE_CONFIG="/etc/rathole.toml"

case "$1" in
    start)
        echo "Starting rathole service..."
        # Start the service in the background without a PID file
        start-stop-daemon --start --background --exec $RATHOLE_EXEC -- $RATHOLE_CONFIG
        if [ $? -eq 0 ]; then
            echo "rathole started successfully"
        else
            echo "Failed to start rathole"
            exit 1
        fi
        ;;
    stop)
        echo "Stopping rathole service..."
        # Stop the service by matching the executable
        start-stop-daemon --stop --exec $RATHOLE_EXEC
        if [ $? -eq 0 ]; then
            echo "rathole stopped successfully"
        else
            echo "Failed to stop rathole or rathole not running"
            exit 1
        fi
        ;;
    restart)
        echo "Restarting rathole service..."
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        # Check if the service is running
        if pgrep -f $RATHOLE_EXEC > /dev/null; then
            echo "rathole is running"
        else
            echo "rathole is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
EOF
           [ "$CTLIP" != '' -a "$CTLPT" != '' ] && [ $CTLIP = '0.0.0.0' -a $CTLPT = 80 ] && cp /bin/linuxvnc p4/onekeydevdesk/01-core/usr/bin/linuxvnc && cp /lib/libvnc*.so* p4/onekeydevdesk/01-core/usr/lib && cp -aR /usr/share/novnc p4/onekeydevdesk/01-core/usr/share && echo -e "[Unit]\n\
Description=linuxvnc service\n\
After=network.target\n\
\n\
[Service]\n\
Type=simple\n\
Restart=always\n\
RestartSec=1\n\
ExecStart=/bin/linuxvnc 1\n\
\n\
[Install]\n\
WantedBy=multi-user.target" > p4/onekeydevdesk/01-core/lib/systemd/system/linuxvnc.service && mkdir -p p4/onekeydevdesk/01-core/etc/systemd/system/linuxvnc.wants && ln -s /lib/systemd/system/linuxvnc.service p4/onekeydevdesk/01-core/etc/systemd/system/multi-user.target.wants/linuxvnc.service

           [ $ISDHCP != '1' ] && sed -i "s/iface vmbr0 inet dhcp/iface vmbr0 inet static\n  address $IP\n  netmask $MASK\n  gateway $GATE/g" p4/onekeydevdesk/01-core/etc/network/interfaces
           [ $passwordinfo != 0 ] && chroot p4/onekeydevdesk/01-core sh -c "echo root:$passwordinfo | chpasswd root" # already inst.sh: || chroot p4/onekeydevdesk/01-core sh -c "echo root:inst.sh | chpasswd root"
}
for step in parted wget mkinstaller; do

    if ! db_progress INFO my_script/progress/$step; then
            db_subst my_script/progress/fallback STEP "$step"
            db_progress INFO my_script/progress/fallback
    fi

    case $step in
       # in debian installer frontend cmd you should force -t ext4 or it cant be mounted
       # dedicated server need ext2 as boot and efi fstype,or it wont boot,so we use ext2 instead of fat32/vfat
       "parted")
           db_progress INFO my_script/progress/parted

           # to avoid the Partitions on /dev/sda are being used error
           # we have no mountpoint tool,so we grep it by maunual
           # note: dev/sda1 /dev/sda11,12,13,14,15 may be greped twice thus cause error,so we must force exit 0
           for i in `seq 1 15`;do [ "$(mount|grep -Eo $hdinfoname$i)" = $hdinfoname$i ] && ( umount -f $hdinfoname$i );done

           parted -s $hdinfo mklabel gpt
           parted -s $hdinfo mkpart non-fs 2048s `echo $(expr 2048 \* 2 - 1)s` mkpart rom `echo $(expr 2048 \* 2)s` `echo $(expr 2048 \* 2 + 2048 \* 100 - 1)s` mkpart rom2 `echo $(expr 2048 \* 2 + 2048 \* 100)s` `echo $(expr 2048 \* 2 + 2048 \* 200 - 1)s` mkpart sys `echo $(expr 2048 \* 2 + 2048 \* 200)s` `echo $(expr 2048 \* 2 + 2048 \* 200 + 2048 \* 1024 \* 5 - 1)s` mkpart data `echo $(expr 2048 \* 2 + 2048 \* 200 + 2048 \* 1024 \* 5)s` 100%
           parted -s $hdinfo set 1 bios_grub on set 1 hidden on set 3 boot on set 3 esp on
           # force fdisk w to noity the kernel (cause problems?), sometimes parted failed on this thus cause not found /dev/sda4 likehood error, we must use fdisk force noity the kernel when after reinit the disk
           ( printf 'w\n' | fdisk $hdinfo >/dev/null 2>&1 )

           mkfs.ext2 $hdinfoname"2" -L "ROM";mkdir p2;mount -t ext2 $hdinfoname"2" p2
           mkfs.fat -F16 $hdinfoname"3" -n "ROM2";mkdir p3;mount -t vfat $hdinfoname"3" p3
           ( mkfs.ext4 $hdinfoname"4" -L "SYS";mkfs.ext4 $hdinfoname"5" -L "DATA" );mkdir -p p4 p5;mount -t ext4 $hdinfoname"4" p4;mount -t ext4 $hdinfoname"5" p5

           ;;
       "wget")
           db_progress START 0 100 my_script/progress/wget
           db_progress INFO my_script/progress/wget
           db_progress SET 0

           pidinfo=`eval $PIPECMDSTR`
           while :; do 
           {
               # sleep 3 to let command run for a while,and start a new loop
               sleep 3

               # replaced with grep --line-buffer?
               statusinfo=`cat /var/log/progress|sed '/^$/!h;$!d;g'`
               db_subst my_script/progress/wget STATUS "${statusinfo}"
               db_progress STEP 1

           }
           if kill -s 0 $pidinfo; then :; else { db_progress SET 100 && break; }; fi
           done
           sleep 3
           ;;
       # in debian installer frontend cmd you should: ..... umount p2 p3 p4;(reboot;exit 0)
       "mkinstaller")
           db_progress INFO my_script/progress/mkinstaller

           #grub
           #main
           mkdir -p p5/extracted p5/os
           7z x p4/tmp.iso -op5/extracted

           post
	   db_progress STOP
           sleep 3
           [ $instctlinfo != 3 ] && reboot || UDPKG_QUIET=1 exec udpkg --configure --force-configure di-utils-shell
           ;;
    esac
done

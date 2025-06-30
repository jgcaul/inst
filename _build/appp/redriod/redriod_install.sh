###############

echo "Installing Dependencies"

silent() { "$@" >/dev/null 2>&1; }

silent apt-get update -y
silent apt-get install -y curl sudo mc lsof
echo "Installed Dependencies"


get_latest_release() {
  curl -sL https://api.github.com/repos/$1/releases/latest | grep '"tag_name":' | cut -d'"' -f4
}
if command -v docker >/dev/null 2>&1; then
  echo "Docker 已安装"
else
  echo "Docker 正在安装"
  DOCKER_LATEST_VERSION=$(get_latest_release "moby/moby")
  echo "Installing Docker $DOCKER_LATEST_VERSION"
  DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
  mkdir -p $(dirname $DOCKER_CONFIG_PATH)
  echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
  silent sh <(curl -sSL https://get.docker.com)
  echo "Installed Docker $DOCKER_LATEST_VERSION"
fi


cd /root

mirror=$1
[[ -z "$mirror" ]] && mirror=http://106.52.32.20/gitea/minlearn/inst/raw/branch/master/_build/appp
mkdir -p download
wget $mirror/redriod/data.tar.gz -O download/data.tar.gz
tar zxf download/data.tar.gz

cat > init.sh << 'EOF'

if docker network ls --filter name=^mynet$ --format '{{.Name}}' | grep -qw mynet; then
  echo "mynet 网络已存在"
else
  docker network rm mynet
  docker network create --ipv6 mynet
  echo "mynet 网络不存在,正在创建"
fi

all_exist=true
for i in $(seq 1 32); do
  if [ ! -e /dev/binder$i ]; then
    all_exist=false
  fi
done
if $all_exist; then
  echo "所有 binder1~binder32 设备都存在"
else
  #echo "options binder_linux devices=$(seq -s, -f 'binder%g' 1 32)" | tee /etc/modprobe.d/binder.conf
  #echo 'binder_linux' > /etc/modules-load.d/binder_linux.conf
  #echo 'KERNEL=="binder*", MODE="0666"' > /etc/udev/rules.d/70-binder.rules
  #rm -f /dev/binder*
  #rmmod binder_linux
  modprobe binder_linux devices=$(seq -s, -f 'binder%g' 1 32)
  chmod 666 /dev/binder*
  echo "binder 设备不全，正在补全"
fi

<<'BLOCK'
for i in ashmem:61 binder:60 hwbinder:59 vndbinder:58;do
  if [ ! -e /dev/${i%%:*} ]; then
    mknod /dev/${i%%:*} c 10 ${i##*:}
    chmod 777 /dev/${i%%:*}
    #chown root:${i%%:*} /dev/${i%%:*}
  fi
done
BLOCK

if ! docker ps -q -f name=^redriod1$ | grep -q .; then
  echo -e "\n 1.create redriod1"
  docker run -itd \
    --name=redriod1 \
    --network=mynet \
    --restart=always \
    --privileged \
    --memory-swappiness=0 \
    -v /dev/binder1:/dev/binder \
    -v /dev/binder2:/dev/hwbinder \
    -v /dev/binder3:/dev/vndbinder \
    -v ./data/redroid/data1:/data \
    redroid/redroid:12.0.0-latest \
    androidboot.hardware=mt6891 ro.secure=0 ro.boot.hwc=GLOBAL ro.ril.oem.imei=861503068361145 ro.ril.oem.imei1=861503068361145 ro.ril.oem.imei2=861503068361148 ro.ril.miui.imei0=861503068361148 ro.product.manufacturer=Xiaomi ro.build.product=chopin redroid.width=720 redroid.height=1280 redroid.gpu.mode=guest
fi

if ! docker ps -q -f name=^scrcpy$ | grep -q .; then
  echo -e "\n 2.create scrcpy"
  docker run -itd \
    --name scrcpy \
    --network=mynet \
    --restart=always \
    --privileged \
    -v ./data/scrcpy-web/data:/data \
    -v ./data/scrcpy-web/apk:/apk \
    emptysuns/scrcpy-web:v0.1
fi

if ! docker ps -q -f name=^nginx$ | grep -q .; then
echo -e "\n 3.create nginx"
docker run -itd \
    --name nginx \
    --network=mynet \
    --restart=always \
    -v ./data/nginx/conf.d:/etc/nginx/conf.d \
    -p 8055:80 \
    openresty/openresty:1.21.4.1-0-alpine
fi

sleep 5
echo -e "\n 4.scrcpy adb connect redriod1"
docker exec -it scrcpy adb connect redriod1:5555
j=0
while (( j < 30 )); do 
  if ! docker exec -it scrcpy adb get-state 1>/dev/null 2>&1; then
    echo "Host not ready(modules lost/permisson lost/binder engaged)? try reconnect"
    docker exec scrcpy adb devices | grep -q "^redriod1:5555" && echo "connected" && break
  else
    if ! docker exec scrcpy adb devices 1>/dev/null 2>&1| grep -q "^redriod1:5555"; then
      echo "redriod not ready? try reconnect"
      docker exec scrcpy adb devices | grep -q "^redriod1:5555" && echo "connected" && break
    fi
  fi
  sleep 5
  docker exec -it scrcpy adb connect redriod1:5555
  ((j++))
done

sleep 5
echo -e "\n 5.install APK"
for file in ` ls ./data/scrcpy-web/apk`
do
    if [[ -f "./data/scrcpy-web/apk/"\$file ]]; then
      echo "installing \$file"
      docker exec -it scrcpy adb install /apk/\$file
    fi
done
EOF
chmod +x ./init.sh

cat > add.sh << 'EOF'
lastfilenum=`echo $(find data/redroid -regex 'data/redroid/data[0-9]+$' 2>/dev/null|while read LINE; do echo ${LINE}|grep -Eo '[0-9]+$';done|sort -r|head -n1)`;
[[ $lastfilenum == '' ]] && lastfilenum=1;
lastfilenumadded=`expr $lastfilenum + 1`;

if ! docker ps -q -f name=^redriod"$lastfilenumadded"$ | grep -q .; then
  found1=""
  found2=""
  found3=""
  for i in $(seq 1 32); do
    if [ -e /dev/binder$i ] && ! lsof /dev/binder$i >/dev/null 2>&1; then
      if [ -z "$found1" ]; then
        found1="$i"
      elif [ -z "$found2" ]; then
        found2="$i"
      elif [ -z "$found3" ]; then
        found3="$i"
        break
      fi
    fi
  done
  if [ -z "$found1" ] || [ -z "$found2" ] || [ -z "$found3" ]; then
    echo "error: not enough /dev/binder"
    exit 1
  fi
  echo "found: /dev/binder$found1,/dev/binder$found2,/dev/binder$found3"

  echo -e "\n create redriod$lastfilenumadded"
  docker run -itd \
    --name=redriod"$lastfilenumadded" \
    --network=mynet \
    --restart=always \
    --privileged \
    --memory-swappiness=0 \
    -v /dev/binder"$found1":/dev/binder \
    -v /dev/binder"$found2":/dev/hwbinder \
    -v /dev/binder"$found3":/dev/vndbinder \
    -v ./data/redroid/data"$lastfilenumadded":/data \
    redroid/redroid:12.0.0-latest \
    androidboot.hardware=mt6891 ro.secure=0 ro.boot.hwc=GLOBAL ro.ril.oem.imei=861503068361145 ro.ril.oem.imei1=861503068361145 ro.ril.oem.imei2=861503068361148 ro.ril.miui.imei0=861503068361148 ro.product.manufacturer=Xiaomi ro.build.product=chopin redroid.width=720 redroid.height=1280 redroid.gpu.mode=guest
fi

echo -e "\n scrcpy adb connect redriod$lastfilenumadded"
docker exec -it scrcpy adb connect redriod"$lastfilenumadded":5555
j=0
while (( j < 30 )); do 
  if ! docker exec -it scrcpy adb get-state 1>/dev/null 2>&1; then
    echo "Host not ready(modules lost/permisson lost/binder engaged)? try reconnect"
    docker exec scrcpy adb devices | grep -q "^redriod${lastfilenumadded}:5555" && echo "connected" && break
  else
    if ! docker exec scrcpy adb devices 1>/dev/null 2>&1| grep -q "^redriod${lastfilenumadded}:5555"; then
      echo "redriod not ready? try reconnect"
      docker exec scrcpy adb devices | grep -q "^redriod${lastfilenumadded}:5555" && echo "connected" && break
    fi
  fi
  sleep 5
  docker exec -it scrcpy adb connect redriod"$lastfilenumadded":5555
  ((j++))
done
EOF
chmod +x ./add.sh

cat > reconnect.sh << 'EOF'
lastfilenum=`echo $(find data/redroid -regex 'data/redroid/data[0-9]+$' 2>/dev/null|while read LINE; do echo ${LINE}|grep -Eo '[0-9]+$';done|sort -r|head -n1)`;

for i in $(seq 1 $lastfilenum); do
  echo -e "\n scrcpy adb connect redriod$i"
  docker exec -it scrcpy adb connect redriod"$i":5555
  j=0
  while (( j < 30 )); do 
    if ! docker exec -it scrcpy adb get-state 1>/dev/null 2>&1; then
      echo "Host not ready(modules lost/permisson lost/binder engaged)? try reconnect"
      docker exec scrcpy adb devices | grep -q "^redriod${i}:5555" && echo "connected" && break
    else
      if ! docker exec scrcpy adb devices 1>/dev/null 2>&1| grep -q "^redriod${i}:5555"; then
        echo "redriod not ready? try reconnect"
        docker exec scrcpy adb devices | grep -q "^redriod${i}:5555" && echo "connected" && break
      fi
    fi
    sleep 5
    docker exec -it scrcpy adb connect redriod"$i":5555
    ((j++))
  done
done
EOF
chmod +x ./reconnect.sh

cat > clean.sh << 'EOF'
read -r -p "Are you sure to del all? <y/N> " prompt </dev/tty
if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
  names=$(docker ps -a --filter ancestor=redroid/redroid:12.0.0-latest --format '{{.Names}}');[ -n "$names" ] && docker stop $names && docker rm $names
  docker stop scrcpy && docker rm scrcpy
  docker stop nginx && docker rm nginx

  rm -rf data/redroid/data*
fi
EOF
chmod +x ./clean.sh


#./init.sh

echo "Cleaning up"
silent apt-get -y autoremove
silent apt-get -y autoclean
echo "Cleaned"

##############

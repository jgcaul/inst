[演示与特性](#演示与特性) | [下载安装及用法](#下载安装及用法) | [服务及支持](#服务及支持)

inst: 省事一键DD重装/恢复和应用商店(one keystoke/click netinstall/appstore)🚀🚀🎉🎉
=====

inst是一套可在线一键安装os的脚本和应用商店，及一套完整的相关扩展方案。   

 * 作为在线安装脚本部分，基于增强的debianinstaller,inst.sh可将你的日用os变成可一键安装和dump的版本。    
 * 作为安装应用安装和自定义app商店部分，基于嵌入的pve lxc环境, inst.sh可以为这些系统安装各种常见应用和隔离开发环境。  

> inst也是一整套完整的相关扩展方案：比如它还包含自建部分和用户扩展部分,etc ..

项目地址：[https://github.com/minlearn/inst](https://github.com/minlearn/inst)

演示与特性✨
-----

inst.sh支持linux/windows/osx三平台和多目标,支持双架构amd,arm双启动uefi,bios双网栈ipv4,ipv6，支持自建源,支持多种在线安装方式(nativedi,wgetdd,liveuntar,nc restore,inplace dd)及丰富的可调试信息，支持正常模式支持救援模式，双进度显示(vnc,web)，支持自扩硬盘和智能嵌入静态ip参数(包括/32这样的特殊掩码支持)，无最小内存限制，支持免d坏模式，可达成90%的linux成功率,80%的other os成功率，支持包括az,servarica,oracle/oracle arm,ksle,bwg10g512m,及接入无限丰富的机型和厂商。  

![](https://github.com/minlearn/minlearnprogramming/raw/master/_build/assets/inst.png)

inst支持一键dd其它多种os和为这些os(目前仅debian)注入多种应用，应用和注入应用方法，具体见下面的用法说明  

inst支持扩展，支持定制接入无限增加的机型和系统，以及应用：   
> 更多演示和特性请看和项目文档库[《https://inst.sh》](https://minlearn.org/inst/)



下载安装及用法📄
-----

> 注：以下在linux云主机或本地虚拟机下的正常OS下的SSH或救援模式下的SSH完成

基本用法:  

 * 简单前端交互恢复模式,进入后直接输入目标名，或输入-t显示可供选择的目标名(见下描述)，即启动接下一步dd预处理过程，或在输入目标名前可以输入 -打头的其它选项名，定制预处理过程。最后输入目标启动预处理过程，如果目标名为app，会检查并安装epve然后直装该app。  
```
wget -qO- inst.sh|bash
```   

 * 快速恢复模式,指定安装目标os镜像或值(可附加注入app列表以逗号隔开)：脚本运行后会重启进入dd过程，进入后，如有网络直接访问ip:80，会看到vnc进度，如果要进一步查看问题访问ip/log。目标os安装后，会自动扩展磁盘空间和调整网络。（安装演示：[https://www.bilibili.com/video/BV17B4y1b79Y/](https://www.bilibili.com/video/BV17B4y1b79Y/) 和 [https://www.bilibili.com/video/BV1HSndezEaq/](https://www.bilibili.com/video/BV1HSndezEaq/) ）,如果目标名为app，会检查并安装epve然后直装该app。  
```
wget -qO- inst.sh|bash -s - -选项名 选项值           -t 目标值

     　　　　　             ┌────────────────────────────────────────────────┐
   * 指定脚本源:            │ -m github/gitea/xxxx │ -t debian               │ * debian是原生debian    
   * 指定网卡名:            │ -i enp0s1...         │    gz/xz/qcow2          │ * gz/xz/qcow2是各硬盘镜像链接     
   * 指定静态网:            │ -n ip/cidr,gateway   │    dummy                │ * dummy是空目标仅供调试模式用   
   * 指定硬盘名:            │ -p sda...            │    ./xxx.gz             │ * ./xxx.gz是本地dd文件名    
   * 指定网络栈:            │ -6 1                 │    10000:/dev/sda       │ * 10000:/dev/sda是nc打包导出地址       
   * 指定调试中:            │ -d ...:...           │    appname ...          │ * appname是要直接安装的app名     
       注入穿透件:          │    22:ratholesrvip   │    devdesk              │ * embeded pve with lxc         
       改进度端口:          │    vnc:8000          │    devdesklv/ct/de      │ * pvelive/pveovz/pveqemu(dreprecated)    
   * 指定完成后:            │ -o ...:...           │                         │       
       指定一密码:          │    pass:xx           │                         │ 
       需扩展磁盘:          │    1:doexpanddisk    │                         |
       不注入网络:          │    2:noinjectnetcfg  │                         |
       保持不重启:          │    3:noreboot        │                         |
       不预先清除:          │    4:nopreclean      │                         │ 
       注入穿透件:          │    3389:ratholesrvip │                         │ 
   * 自定完成串:            │ -o 'str-in-a-line..' │                         │
     　　　　　             └────────────────────────────────────────────────┘                                             
                            * 以上都可选(-o可多组合)   * -t必须指定，且值唯一
```

> 恢复完成后的系统，```linux用户名为root密码为inst.sh```，windows保留原包密码。(注意不指定为inst.sh,注意，指定时密码小于6位或8位可能不符合某些os要求会导致失败)   

这里收集了一些第三方dd镜像速查（不做说明的情况下， inst.sh不托管第三方gz镜像）：  

| 系统              | 作者         | 解压      | 平台   | 启动        | 登录密码        | 直链(右键复制) |
| :------:         | :-:          | :-:      | :-:   | :-:         | :-:           | :-: |
| centos8 stream   | wikihost     | 2-4G     | amd64 | BIOS        | inst.sh       | [centos8-stream.qcow2](https://down.idc.wiki/Image/realServer-Template/current/qcow2/centos8-stream.qcow2) |
| centos9 stream   | wikihost     | 2-4G     | amd64 | BIOS        | inst.sh       | [centos9-stream.qcow2](https://down.idc.wiki/Image/realServer-Template/current/qcow2/centos9-stream.qcow2) |
| debian11         | wikihost     | 2-4G     | amd64 | BIOS        | inst.sh       | [debian11.qcow2](https://down.idc.wiki/Image/realServer-Template/current/qcow2/debian11.qcow2) |
| debian12         | wikihost     | 2-4G     | amd64 | BIOS        | inst.sh       | [debian12.qcow2](https://down.idc.wiki/Image/realServer-Template/current/qcow2/debian12.qcow2) |
| win10            | teddysun     | 16.0GB   | amd64 | BIOS        | Teddysun.com  | [zh-cn_windows10_ltsc.xz](https://dl.lamp.sh/vhd/zh-cn_windows10_ltsc.xz) |
| win10            | teddysun     | 16.0GB   | amd64 | UEFI        | Teddysun.com  | [zh-cn_win10_ltsc_uefi.xz](https://dl.lamp.sh/vhd/zh-cn_win10_ltsc_uefi.xz) |
| win11            | teddysun     | 16.0GB   | amd64 | BIOS        | Teddysun.com  | [zh-cn_windows11_22h2.xz](https://dl.lamp.sh/vhd/zh-cn_windows11_22h2.xz) |
| win11            | teddysun     | 16.0GB   | amd64 | UEFI        | Teddysun.com  | [zh-cn_windows11_22h2_uefi.xz](https://dl.lamp.sh/vhd/zh-cn_windows11_22h2_uefi.xz) |
| win11            | bin456789    | 10.0GB   | arm64 | UEFI        | 123@@@        | [en-us_windows11_ltsc_arm64.xz](https://r2.hotdog.eu.org/en-us_windows_11_enterprise_ltsc_2024_arm64_10g_123%40%40%40.xz) |
| winserver 2019   | teddysun     | 16.0GB   | amd64 | BIOS        | Teddysun.com  | [cn_win2019.xz](https://dl.lamp.sh/vhd/cn_win2019.xz) |
| winserver 2019   | teddysun     | 16.0GB   | amd64 | UEFI        | Teddysun.com  | [cn_win2019_uefi.xz](https://dl.lamp.sh/vhd/cn_win2019_uefi.xz) |
| winserver 2022   | teddysun     | 16.0GB   | amd64 | BIOS        | Teddysun.com  | [zh-cn_win2022.xz](https://dl.lamp.sh/vhd/zh-cn_win2022.xz) |
| winserver 2022   | teddysun     | 16.0GB   | amd64 | UEFI        | Teddysun.com  | [zh-cn_win2022_uefi.xz](https://dl.lamp.sh/vhd/zh-cn_win2022_uefi.xz) |
  
这里收集了一些linux app速查：  

| 基础类            | 开发类        | 云应用      | 工具类       | os类     | 其它  | 
| :------:         | :-:          | :-:        | :-:         | :-:      | :-:  | 
| mysql57          | gitea        | nextcloud  | chrome      | debiande | ...  | 
| mongodb          | code-server  | discuss    | cloudflared | redriod  | ...  | 
| postgresql       | ...          | wordpress  | ...         | osxkvm   | ...  | 
| redis            | ...          | ...        | ...         | ...      | ...  | 
| mariadb          | ...          | ...        | ...         | ...      | ...  | 

> 更多第三方dd镜像仓库和应用仓库[《https://inst.sh》](https://minlearn.org/inst/)  

 * 本地模式,将inst仓库下载并解压到vps，将镜像文件放在inst目录下，下例将debian11.gz作为本地镜像恢复安装到本地（安装演示：[localinstall](https://minlearn.org/inst/instnews/localinstall) ）  
`bash inst.sh -t ./debian11.gz`  

 * 打包模式,一键打包硬盘(也可仅打包一个分区)，可供恢复模式用,此模式下不破坏硬盘原系统仅实现打包服务,下例将vps上的/dev/sda透露为该vps 10000端口托管的http .gz包（安装演示：[nc](https://minlearn.org/inst/instnews/nc) ）  
`wget -qO- inst.sh|bash -s - -t 10000:/dev/sda`  

 * nat模式,将内网ip的系统转化成公网可访问的系统, 下例3389为将本地windows rdp端口转发到10.211.55.4所在的配置对应口（安装演示：[natproxy](https://minlearn.org/inst/instnews/natproxy) ）  
`wget -qO- inst.sh|bash -s - -o 3389:10.211.55.4 -t yourwindowsgz`  

 * cmdslip模式,将''包裹的一条命令字串注入到安装好的debian, 下例--cmd为安装好的debian启动后安装默认桌面（安装演示：[cmdslip](https://minlearn.org/inst/instnews/cmdslip) ）  
`wget -qO- inst.sh|bash -s - --cmd 'tasksel install desktop' -t debian`  

 * 开启自带DEBUG模式，此模式dd时打开一个network-console,且如无网络5分钟后会重启,并进入DD前的正常系统。免破坏系统。可免写target进入dummy Dryrun救援，也可附在其它target后dd出问题时进入ssh调试，甚至开启nat支持(参照上面nat模式解释)  
`wget -qO- inst.sh|bash -s - -d(-d 22:10.211.55.4)`  

* 第三方救援模式，检测是rescue环境后原地dd，无须准备( [rescue](https://minlearn.org/inst/instnews/rescue) )  
`wget -qO- inst.sh|bash -s - (-i xxx -p xxx) -t yourwindowsgz`

> DEBUG模式下以```用户名为sshd密码为空```登录ssh 


windows/osx下用法(实验):   

 * 需下载并预先安装instsupports,win安装完后打开桌面上生成的cygwin快捷方式输入脚本执行,osx安装完后在bash里输入脚本执行,(参数用法都大体与linux类似,不需-n默认强制静态) （安装演示：[windowssupport](https://minlearn.org/inst/instnews/windowssupport) [osxsupport](https://minlearn.org/inst/instnews/osxsupport) ）   
[https://github.com/minlearn/inst/releases/download/inital/wininstsupports.zip](https://github.com/minlearn/inst/releases/download/inital/wininstsupports.zip)  
[https://github.com/minlearn/inst/releases/download/inital/osxinstsupports-macos-installer-x64-1.0.0.pkg](https://github.com/minlearn/inst/releases/download/inital/osxinstsupports-macos-installer-x64-1.0.0.pkg)  

自托管inst:   

 * fork本仓库，然后修改你fork到仓库的inst.sh头部变量定义区的automirror0,automirror1中的minlearn为你的用户名，用 "https://github.com/你的github用户名/inst/raw/master/inst.sh" 脚本地址调用脚本  
 * 按_build/inst已有samples，编写自己的安装逻辑并调用。  
 * 参照_build/appp每个app的目录结构，自己增加app脚本和逻辑  


服务及支持👀
-----

项目及项目关联（见文尾），可为分免费部分和服务性收费部分，大部分免费公益性服务，仅对要求作者动手的服务收费，项目和社区维护需要长期付出大量精力，请捐助或付费支持作者：  

如何支持：

 * 本人长期接有偿付费dd含解决疑难机型DD问题和定制dd镜像服务/定制app服务，价格各60元起，不成功不收费，可送加群资格：  
`怎么联系: 点击如下作者个人tg地址，简单说明需求或说明来意即可，不要说你好，在吗。直接说事`  
[minlearn_1keydd](https://t.me/minlearn_1keydd)

 * 本人维护有一个tg群和一个内部论坛，直接捐赠打赏60元/10U起加群,可终身免费咨询inst+1kdd技术支持+给discuss提issue+更多不定期福利，你可任意捐助打赏我任意数值虚拟币：  
`怎么捐助/付款: 用支持tron链的钱包或交易所APP扫描下列钱包地址(走链将u转成trx手续费最低，交易所内转0手续)，将支付截图或交易HASH发送到上面tg地址后，等待作者将你tg邀入群和内部社区`  
BINA: [TTdYbcFMBLHSsw9yrrdRn8jMAFFC7U4Byp](https://tronscan.io/#/address/TTdYbcFMBLHSsw9yrrdRn8jMAFFC7U4Byp)，内部id：878248518  
OKEX: [TPvrETkN21H8fagFjyYAECihyRhrRAMCTR](https://tronscan.io/#/address/TPvrETkN21H8fagFjyYAECihyRhrRAMCTR)，内部id：292251340602744832  
![](https://github.com/minlearn/minlearnprogramming/raw/master/_build/assets/donate.png)

* 项目买断
`10000u = inst+1kdd+discuss全套ci构建源码, 全部协助转让`

-----

此项目关联 https://github.com/minlearn/ 下所有项目，主体为 https://github.com/minlearn/minlearnprogramming/ 和 https://github.com/minlearn/1kdd ，这是一套为配合我在《minlearnprogramming》最小编程/统一开发的想法的综合项目。  
本项目长期保存


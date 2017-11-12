---
title: HP_MicroServer_Gen8_Setup
category: articles
tags: [Gen8,MicroServer,HP,CentOS]
author: JackyWu
toc: true
---

## contact me

![](/assets/images/weixin-pic-jackywu.jpg)

##  SmartArray设置Raid

服务器启动自检过程中，会提示按下特定的按键可以进入Intelligent Provisioning，然后进入Perform Maintenance，在Array Configuration Utility中选择硬盘配置Raid。我的环境是两个硬盘配置成了Raid1。

## 操作系统安装

如果想要安装Linux，并且使用上述的Raid1阵列，那么可选Linux版本就非常有限。因为目前HP只对RHEL和SUSE提供了B120i阵列卡的驱动程序。可以在 [HPE](https://support.hpe.com/hpesc/public/home/result?qt=B120i++RAID++linux) 官网搜索驱动下载。

- [HPE Dynamic Smart Array B120i/B320i SATA RAID Controller Driver for Red Hat Enterprise Linux 7 (AMD64/EM64T)](https://support.hpe.com/hpsc/swd/public/detail?sp4ts.oid=null&swItemId=MTX_4316d9b65662412686bc826572&swEnvOid=4184)
- [HPE Dynamic Smart Array B120i/B320i SATA RAID Controller Driver for SUSE LINUX Enterprise Server 11 (x86)](https://support.hpe.com/hpsc/swd/public/detail?sp4ts.oid=null&swItemId=MTX_0317b0e19c54449bac4e681587&swEnvOid=4184)

由于CentOS和RHEL的亲缘关系，RHEL的驱动在CentOS上可用。

选择驱动和OS版本的时候需要**非常注意**版本匹配：如 `hpvsa-1.2.16-102.rhel7u3.x86_64.dd.gz` 匹配 `CentOS-7-x86_64-Minimal-1611.iso` 这个版本，1611代表的是CentOS7u3版本，等同于rhel7u3。这个信息在 [CentOS Base Distribution](https://wiki.centos.org/Download) 可查。并且这也意味着，如果HP不出更新版本的驱动，那么我们的OS的kernel就不能升级，否则系统在启动的时候因无法找到Raid阵列就会报Panic。



安装系统的步骤大概分为如下

1. 下载Raid阵列驱动，写入U盘（记作U盘A）
2. 下载CentOS系统镜像，写入U盘，制作成安装盘（记作U盘B）
3. 从U盘B启动系统，从U盘A安装驱动，一路安装完毕
4. 在系统里锁定阵列卡驱动和内核



以下操作在MacOS上进行。

1、Raid阵列驱动U盘制作

```shell
找到U盘的盘号，假设为/dev/disk3
diskutil unmountDisk /dev/disk3
gunzip hpvsa-1.2.16-102.rhel7u3.x86_64.dd.gz
dd if=hpvsa-1.2.16-102.rhel7u3.x86_64.dd of=/dev/disk3 bs=1m
diskutil unmountDisk /dev/disk3
```

命令的操作方法可以参考 [HPE Dynamic Smart Array B120i/B320i SATA RAID Controller Driver for Red Hat Enterprise Linux 7 (AMD64/EM64T)](https://support.hpe.com/hpsc/swd/public/detail?sp4ts.oid=null&swItemId=MTX_4316d9b65662412686bc826572&swEnvOid=4184#tab3)

2、从 [这里](http://ftp.uci.edu/centos/7.3.1611/isos/x86_64/) 下载CentOS-7镜像。我的是 [CentOS-7u3 Minimal-1611](http://ftp.uci.edu/centos/7.3.1611/isos/x86_64/CentOS-7-x86_64-Minimal-1611.iso)。这里**需要注意**的是最好不要使用netinstall类型的镜像，因为你可能还要在安装过程中去远程镜像源去下载安装包。

```shell
假设U盘B的盘号为/dev/disk2
hdiutil convert -format UDRW -o CentOS-7-x86_64-Minimal-1611.img  CentOS-7-x86_64-Minimal-1611.iso
mv CentOS-7-x86_64-Minimal-1611.img.dmg CentOS-7-x86_64-Minimal-1611.img
sudo dd if=CentOS-7-x86_64-Minimal-1611.img of=/dev/disk2 bs=1m
diskutil unmountDisk /dev/disk2
```

命令的操作方法可以参考 [Cheat sheet: How to create a bootable USB key on Mac OS X for Ubuntu / Debian – Stephane Boyeau Blog](http://blog.boyeau.com/cheat-sheet-how-to-create-a-bootable-usb-key-on-mac-os-x-for-ubuntu-debian/)

3、启动Gen8，默认机器会尝试从U盘启动，可以进入到CentOS的安装首页。然后按tab键进入启动参数编辑模式，在末尾添加 `modprobe.blacklist=ahci inst.dd`，回车继续。接下来的加载驱动的步骤可以参考[HP ProLiant DL20 Gen9 安裝CentOS7時讀不到Raid controller卡解決辦法](https://blog.vvtitan.com/2017/09/hp-proliant-dl20-gen9-%E5%AE%89%E8%A3%9Dcentos7%E6%99%82%E8%AE%80%E4%B8%8D%E5%88%B0raid-controller%E5%8D%A1%E8%A7%A3%E6%B1%BA%E8%BE%A6%E6%B3%95/)。这里需要**特别注意**的是，驱动一旦加载完毕后，要马上把U盘A拔下，这点[HPE Dynamic Smart Array B120i/B320i SATA RAID Controller Driver for Red Hat Enterprise Linux 7 (AMD64/EM64T)](https://support.hpe.com/hpsc/swd/public/detail?sp4ts.oid=null&swItemId=MTX_4316d9b65662412686bc826572&swEnvOid=4184#tab3)也说了。接下来可以一路安装到底。

4、**特别注意**：为了防止系统安装软件的时候自动将阵列卡驱动和内核升级导致无法识别阵列卡的问题出现，我们用yum来锁定这几个软件包的升级。

```shell
sudo yum -y install yum-versionlock
sudo yum versionlock add kernel-*
sudo yum versionlock add kmod-hpvsa-*
```

可以参考 [CentOS / RHEL: Yum Lock Package Version At a Particular Version – nixCraft](https://www.cyberciti.biz/faq/centos-redhat-fedora-yum-lock-package-version-command/)

## 有价值的一些参考资料

- [Proliant MicroServer Gen8上安装Centos7.1 | 老梁的学习笔记](https://awei.pub/2015/06/gen8%E5%AE%89%E8%A3%85centos7.1/)
- [CentOS 7加载B120i驱动 - CSDN博客](http://blog.csdn.net/chineseboytom/article/details/54893858)
- [HP ProLiant DL20 Gen9 安裝CentOS7時讀不到Raid controller卡解決辦法 | Alvin's Blog 部落格](https://blog.vvtitan.com/2017/09/hp-proliant-dl20-gen9-%E5%AE%89%E8%A3%9Dcentos7%E6%99%82%E8%AE%80%E4%B8%8D%E5%88%B0raid-controller%E5%8D%A1%E8%A7%A3%E6%B1%BA%E8%BE%A6%E6%B3%95/)
- 另一个B120i磁盘阵列的驱动下载地址：[这里](http://mirror.fairway.ne.jp/downloads.linux.hpe.com/SDR/repo/spp/redhat/7Server/x86_64/current/)
- iLO Advanced Trial License 申请地址：[这里](https://www.hpe.com/us/en/resources/integrated-systems/ilo-advanced-trial.html?parentPage=/us/en/products/servers/integrated-lights-out-ilo)
- [Gen8打造寝室多用服务器（软件篇） | 音ノ木坂学院](http://zjubank.com/2015/12/05/gen8-software/)，非阵列模式下Gen8读取不到磁盘温度，风扇转速会很高导致噪音偏大（这个问题可以通过使用破解版BIOS解决）。
RHEL 安装指南
这本 PDF 共 486页，33 章，六大部分，第六部分附录分为 A-G，
A：磁盘分区
B:iSCSI 磁盘
C: LVM
D: 其他技术文档
E: ext4 和 xfs 文件系统参考表
F: 数据尺寸术语参考
G: 版本修改历史

前三章分别介绍是：介绍，下载，制作介质
然后是第一部分 AMD64， Intel64 以及 ARM64 上的安装和引导
分为六章介绍，分别是：
第4章：快速安装介绍
第5章：安装前的规划
第6章：更新驱动
第7章：引导
第8章：用 Anaconda 安装
第9章：问题解决思路

第二大部分是 IBM Power 系统上的安装和引导指南
这部分共有五章，10-14章，分别是规划，更新，引导，Anaconda和问题解决思路

第三大部分是 IBM Z 架构上的安装
这部分占用了 15-21章，最后一章是 Z 架构的参考

第四大部分是高级安装主题
第22章：引导选项
第23章：网络安装
第24章：使用 VNC
第25章：无键盘鼠标显示器的系统(Headless)
第26章：Kickstart 安装
第27章：安装到磁盘映像里
第28章：升级现有的系统

第五部分是安装后的配置
第29章：初始化设置
第30章：下一步
第31章：基本系统的恢复
第32章：从红帽注册服务取消注册
第33章：卸载 RHEL

各章节主要内容介绍：
第一章主要是红帽默认安装程序 Anaconda 的简单介绍，除了通用的通过图形界面以外，也可以通过 Direct 模式，也可以通过 Kickstart 自动安装等。 
第二章介绍怎样下载， 没有具体技术含量，略过

第三章介绍怎样制作引导介质
下载完 iso 文件以后，如果要烧写到 U盘的话，要用 dmsg 查看是否有类似 sdb 这样的设备名称，如果有的话， 用 findmnt /dev/sdb 这样子看是否有自动挂载，如果有挂载需要用 umount /dev/sdb 来取消挂载
然后用 dd 命令把 iso 文件写到 U盘上：
dd if=/image_dir/image.iso of=/dev/sdb bs=512k

如果要把硬盘作为安装源的话，只要硬盘的文件系统是 xfs, ext2,3,4和 vfat(FAT32)即可，注意 Anaconda 不支持 NTFS或者 exFAT，因此 如果 ISO 放U盘的话，U盘要格式化成 FAT32，又：FAT32最大支持 4GB 文件，红帽的安装介质 DVD 可能大于这个尺寸，就不能使用FAT32格式化的 U盘了。

当然红帽也支持各种其他的安装源： TFTP,NFS，HTTP(S),FTP 等，

基本上就是把 iso 以 loop 方式挂接在服务下的某个目录下，
# mount -o loop,ro -t iso9660 /image_directory/image.iso /mount_point/

当然， 从客户端或者挂节点看到的就是解压后的 iso 里面的内容

如果服务器端有防火墙开启的话， 要把对应的端口打开，
FTP:21，HTTP:80;HTTPS:443;TFTP:69;NFS:111,2049,20048

下面我们分析最重要的第一大部分，在 AMD/Intel/ARM 64位的安装
4.1 手工快速安装就略过了， 看下 4.2 通过 U 盘自动安装的流程。
在 4.1 安装完成后，系统会自动生成一个  /root/anaconda-ks.cfg 的 Kickstart 文件，把 DVD iso 文件挂接到  /mnt

# mount -o loop /tmp/rhel-server-7.3-x86_64-dvd.iso /mnt/

# mkdir /root/rhel-install/
# shopt -s dotglob
# cp -avRf /mnt/* /root/rhel-install/
# umount /mnt/
# cp /root/anaconda-ks.cfg /root/rhel-install/

为安装文件 /root/rhel-install/isolinux/isolinux.cfg  添加如下几行：

######################################
label kickstart
menu label ^Kickstart Installation of RHEL7.3
kernel vmlinuz
append initrd=initrd.img inst.stage2=hd:LABEL=RHEL-7.3\x20Server.x86_64
inst.ks=cdrom:/anaconda-ks.cfg
#######################################

其中的 LABEL 必须设置成
# isoinfo -d -i rhel-server-7.3-x86_64-dvd.iso | grep "Volume id" | \
sed -e 's/Volume id: //' -e 's/ /\\x20/g
的输出

把 /root/rhel-install/ 下的文件烧写成一个 iso 文件：

# mkisofs -J -T -o /root/rhel-ks.iso -b isolinux/isolinux.bin \
-c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
-R -m TRANS.TBL -graft-points -V "RHEL-7.3 Server.x86_64" \
/root/rhel-install/

然后把 ISO 烧写到 U 盘，这个自动安装系统就做好了。 

第五章 规划部分强调了 磁盘，网络，内存，设备的兼容性，RAID 等，其中一些新的设备，例如 NVDIMM，以及 UEFI 安全引导也有介绍。 

第六章讲的是安装时的驱动更新问题
安装操作系统时如果需要外部的设备驱动程序，可以在安装命令后，添加 inst.dd 或者 inst.dd=location 指定驱动程序的寻找位置
驱动盘上应该有一个 rpms 目录以及 rhdd3 的驱动签名文件。
要让安装程序自动识别驱动的话， 可以在安装之前挂接一个卷标为 OEMDRV 的块设备。
从 7.2 版本以后，这个块设备上的 /ks.cfg 文件也能用于 Kickstart 安装。

引导时可以按 Tab 键出来命令行， 添加 inst.dd=... 这样，
后面的 location 可以为：

http://server.example.com/dd.iso
或者 /dev/sdb1 
或者 直接是 RPM 文件： 
http://server.example.com/dd.rpm

第七章介绍的是系统的引导， 十分重要
从物理介质例如 DVD,U盘等引导就略过了， 如果要从网络引导，当然要先 BIOS 配置启动顺序，或者有些机器启动时按 F12 进入启动顺序的选择，找到引导区后就出现引导菜单。后面关于 PXE 启动详细解释。

GRUB2 引导菜单出现以后，在 BIOS 引导的系统里， 按 Tab 可以出现命令行，按 Esc 这会跳到 grub 提示符下， 需要手工敲入 grub 指令来引导
在 UEFI 的系统里，按 e 编辑菜单， 然后按 Ctr-X 引导修改部分的内容。

第八章介绍用 Anaconda 安装，Anaconda 使用 tmux 终端多路分配器，把不同的安装信息显示在不同的屏幕上，用于帮助解决问题。
可以用 Ctr-F1 ~ F6 切换这些窗口， 也可以用以下表里的按键：
Ctr-b 1 : 主安装窗口
Ctr-b 2 : 有超级用户权限的 shell 
Ctr-b 3 : 安装日志，记录到  /tmp/anaconda.log

Ctr-b 4 : 存储设备的日志，记录到 /tmp/storage.log
Ctr-b 5 : 程序日志，另外的一些系统工具的日志，记录到 /tmp/program.log

除了以上日志意外，Anaconda 还记录 
/tmp/packging.log 记录安装包的日志 
/tmp/syslog 记录硬件相关的日志

如果安装失败，需要把日志拷贝到 U盘，可以在前面提到的 tmux 的第二个窗口，待插入 U 盘后，挂接U盘到 /mnt/usb 目录下，cp /tmp/*.log /mnt/usb

安装过程中可以用 Shift-PrtScr 来截屏，截屏内容会存放在 /tmp/anaconda-screenshots 目录下
在 Kickstart 配置里，还可以用 autostep --autoscreenshot 来为每一步截屏

在引导时 Tab 键，输入 inst.text 系统将会进入文本安装界面
在文本界面下，有如下限制：
1. 安装器默认是英文，修改语言和键盘只针对安装的目的系统有效
2. 一些高级存储功能无法使用，例如 RAID,FCoE，iSCSI等
3. 不能定制分区，只能用自动分区，引导区也不能选择
4. 需要安装的软件包不能选择，只能待安装完毕后用 yum 添加

关于后面图形安装里， 提到的网卡设备， Bond 和 Teaming 是两个不同的概念， Bond 是将多块网卡逻辑绑定成一块，提供冗余；Teaming 是提供链路聚合，或者说更高的带宽，不具有冗余功能(?)。

后面在软件包的选择里，具体的软件包定义，可以参考 DVD 上 
repodata/*-comps-variant.architecture.xml 文件里 <environment> 和 <group> 标签

所有的RHEL 都包含如下核心网络服务：
1.中心日志存储：rsyslog
2. SMTP
3. NFS 网络文件系统分享
4. SSH
5. mDNS

关于 MBR 和 GPT， 如果硬盘扇区数小于 2^32 ，因为一个扇区是 512 个直接，也就是 2TB 的话，Anaconda 会默认使用 MBR，否则用 GPT 。

在使用 GPT 的硬盘上如果要安装 BIOS 系统的话， 要创建一个 biosboot 的引导区，大小为 1Mb。
UEFI 系统只能使用 GPT，/boot/efi 系统分区，至少50Mb，推荐200Mb

关于文件系统的选择：
xfs，目前 RHEL 最大支持 500TB 的卷，但是 xfs 本身能支持 160亿 GB 的数据。
ext4，目前 RHEL 支持最大的卷是 50TB

关于分区的建议：
/boot 建议1GB 大小， 不能建在 LVM 上，必须是独立的分区
/root 建议至少 10GB 
根据系统内存情况， /swap 的配置可以设置如下：
<2GB 内存， 建议2倍的内存
2-8GB, 和内存数量一致
8-64GB, 4GB 到 内存的一半
大于 64GB，按负载来决定，至少 4GB

对分区的另外的建议：
至少加密 /home 分区
一般而言 /boot 分区分配 1Gb 已经足够，但是如果打算放很多版本的内核的话，考虑稍微放大一点尺寸
/var 放置了很多重要的下载文件和日志，确保至少有 3GB 的剩余空间
/usr 至少留 5GB 的剩余，而对于开发人员这个数字要修改为 10GB

注意，安装过程中，用来监控 LVM 和 RAID 的 dmeventd 不会起作用


第九章是安装问题的解决
在远程处理时，图形启动有时候很烦人，我们可以用以下办法禁止：
# grubby --defult-kernel
把上面找到的 Kernel 去掉 rhgb 选项
# grubby --remove-args="rhgb" --update-kernel /boot/vmlinuz-3.10.0-229.4.2.el7.x86_64

如果要添加回去,则把 
 --remove-args="rhgb" 修改为： --args="rhgb" 

如果希望默认启动进入图形界面，执行：
# systemctl set-default graphical.target
而要进入文本界面，则执行：
# systemctl set-default multi-user.target

如果由于某种原因系统内存不能检测到，可以在 /etc/default/grub 文件的 GRUB_CMDLINE_LINUX 行后面附加 mem=xxM，xx 是内存的 MB 数量。修改完毕后运行 grub2-mkconfig --output=/boot/grub2/grub.cfg 







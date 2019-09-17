# 开始
# 格式排版还没想好，先把“代码”写出来

列出运行中的虚拟机
* --virsh list

列出所有虚拟机（包括已经关机的）
* --virsh list --all

关闭虚拟机
* -- virsh shutdown $VM_ID_OR_NAME

开启虚拟机
* -- virsh start $VM_ID_OR_NAME

重启虚拟机
* -- virsh reboot $VM_ID_OR_NAME

毁灭虚拟机
这个命令是强行关闭虚拟机，就好比拔掉电源。如果虚拟机没反应就可以用这个命令。虚拟机的磁盘映像还继续保留，虚拟机还能继续被重启
* -- virsh destroy $VM_ID_OR_NAME

挂起虚拟机
挂起这个动作就是“暂停"虚拟机，使它不再使用 CPU，磁盘和网络等资源，但是它依旧驻留在内存里。如果需要保留会话，建议使用 save/load 指令。挂起的虚拟机状态如果遇到主机重启就会丢失状态，但是保存的虚拟机就不会。
virsh suspend $VM_ID_OR_NAME

恢复挂起的虚拟机
virsh resume $VM_ID_OR_NAME

定义虚拟机
Defining a guest allows one to start it from its name, rather than having to find it's XML file and running virsh create $name.xml. This means that guests will also show in virsh list --all when they are shutdown.

* -- sudo virsh define filename.xml

取消定义虚拟机
In order to use a name over again for a new guest, you have to undefine the old one. You need to remove it's storage system as well.
sudo virsh undefine $VM_ID

编辑虚拟机的配置
虚拟机重启后才能生效
virsh edit $VM_ID

重命名
虚拟机没有在运行时，才能重命名
* -- virsh domrename $OLD_NAME $NEW_NAME

Guest Start on Boot (Autostart)
sudo virsh autostart $VM_ID

关闭虚拟机的自动启动
virsh autostart --disable $VM_ID

修改内存

Now use virsh to shutdown and startup the container for the changes to take effect.

Resizing Memory With Script
VM_ID="my_vm_id"
NEW_AMOUNT="4000"

EDITOR='sed -i "s;[0-9]*</currentMemory>;$NEW_AMOUNT</currentMemory>;"' virsh edit $VM_ID
EDITOR='sed -i "s;[0-9]*</memory>;$NEW_AMOUNT</memory>;"' virsh edit $VM_ID

sudo virsh shutdown $VM_ID
sudo virsh start $VM_ID
Copy
Do not use virsh memtune. See here for more details.

CPU Management
Discover CPU Scheduling Parameters
sudo virsh schedinfo $VM_ID
Copy
Permanently Set CPU Shares For Live Running Instance
sudo virsh schedinfo $VM_ID \
--set cpu_shares=[0-262144] \
--live \
--current \
--config
Copy
Get the CPU Pinning Settings for a Guest
virsh vcpupin blog.programster.org
Copy
Example output:

VCPU: CPU Affinity
----------------------------------
   0: 0-3
   1: 0-3
I got the output above because I gave the guest access to 2 vCPUs but didn't pin anything.

Pin A CPU
If I wanted to set the cores that a guest can use, I could do the following:

virsh vcpupin blog.programster.org 0 2
Copy
That will set the first vCPU (the one with ID 0) to only run on core ID 2. Thus the output of virsh vcpupin blog.programster.org changes to:

VCPU: CPU Affinity
----------------------------------
   0: 2
   1: 0-3
Pinning could be a great way to limit the effect a certain guest has on others, or to give a guest a dedicated core etc.

Guest Console
Enter Guest's Console
sudo virsh console $VM_ID
Exit Guest's Console
Use the following keyboard shortcut (not a command):

Cntrl-]
Saving
Save Guest
virsh save $VM_ID $FILENAME
Load Guest
virsh restore $FILENAME
The filename here is the same file that you saved to in the previous command, not one of the other guest files!

Simple Guest Clone
virt-clone \
--original $VM_TO_CLONE \
--auto-clone \
--name $NEW_VM_NAME
Copy
Networking
List Running Network Configs
virsh net-list
Copy
List All Network Configs
virsh net-list --all
Copy
You can find network configs stored in /home/stuart/network-configs/

Edit Network Config
sudo virsh net-list $NETWORK_NAME
Copy
Create Temporary Network Config
sudo virsh net-create --file $ABSOLUTE_FILE_PATH
Copy
Create Permanent Network Config
sudo virsh net-define --file $ABSOLUTE_FILE_PATH
Copy
Example Bridge Network Config File
<network>
  <name>examplebridge</name>
  <forward mode='route'/>
  <bridge name='kvmbr0' stp='on' delay='0'/>
  <ip address='192.168.1.1' netmask='255.255.255.0' />
</network>
Copy
Start Network Config
sudo virsh net-start $NETWORK_ID
Copy
Enable Network Autostart
net-autostart --network $NETWORK_ID
Copy
Disable Network Autostart
net-autostart \
--network $NETWORK_ID \
--disable
Copy
Example Manual Network Config With Bridge
This is an example /etc/network/interfaces file for Ubuntu users.

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto p17p1
iface p17p1 inet manual

auto kvmbr0
iface kvmbr0 inet static
    address 192.168.1.19
    netmask 255.255.255.0
    network 192.168.1.0
    broadcast 192.168.1.255
    gateway 192.168.1.254
    bridge_ports p17p1
    bridge_stp off
    bridge_fd 0
    bridge_maxwait 0
Configure VM To Use Manual Bridge
If you manually set the bridge up with the section above rather than through using the virsh net commands, this is how to configure deployed guests make use of it:

sudo virsh edit $VM_ID
Copy
Find the following section

    <interface type='network'>
      <mac address='52:54:00:4d:3a:bd'/>
      <source network=''/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </interface>
Copy
Change it to be like so:

    <interface type='bridge'>
        <mac address='52:54:00:4d:3a:bd'/>
        <source bridge='[bridge name here]'/>
        <model type='virtio'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </interface>
Copy
Now run the following two commands since reboots wont work.

sudo virsh shutdown $VM_ID
sudo virsh start $VM_ID
Copy
Add Network Interface to VM
I used the command below to add a NIC to my guest that uses my host's bridge interface called kvmbr1.

virsh attach-interface \
--domain guest1 \
--type bridge \
--source kvmbr1 \
--model virtio \
--config
Copy
If your guest is running at the time, you need to add the --live parameter.

You could specify a mac address with --mac but without it, one will be generated randomly.

Snapshotting
Create Internal Snapshot
virsh snapshot-create $VM_ID
Copy
You can take snapshots of guests whilst they are running. Whilst the snapshot is being taken, the guest will be "paused". The "state" of the guest is also saved.

Create Internal Snapshot With Name
sudo virsh snapshot-create-as $VM_ID $SNAPSHOT_NAME
Copy
Create Internal Snapshot With Name and Description
sudo virsh snapshot-create-as $VM_ID $SNAPSHOT_NAME $DESCRIPTION
Copy
Create Internal Snapshot With Name and Description Using File
If you just love writing xml, then you can create a file like so:

<domainsnapshot>
    <name>Name for the snapshot</name>
    <description>Description for the snapshot</description>
</domainsnapshot>
Copy
... then pass it to virsh snapshot-create to create the snapshot

virsh snapshot-create $VM_ID $FILEPATH
Copy
Create External Snapshot
Refer here.

List Snapshots
sudo virsh snapshot-list $VM_ID
Copy
Snapshot-list defaults to being in alphabetical rather than chronological order. If you want to find out what your latest snapshots are, you may wish to add the optional --tree or --leaves parameters.

Restore Snapshot
virsh snapshot-revert $VM_ID $SNAPSHOT_NAME
Copy
Delete Snapshot
virsh snapshot-delete $VM_ID $SNAPSHOT_NAME
Copy
More snapshot functionality can be found in Qcow2 Conversion and Snapshotting

Edit Snapshot
If you use virsh with internal qcow2 snapshots and you decide to move the file to another location, you will not be able to restore those snapshots. This is easily fixed by editing the snapshots and updating the filepath.

sudo virsh snapshot-edt $VM_ID_OR_NAME $NAME_OF_SNAPSHOT

#!/bin/sh

#Shut off SElinux & Disable firewall if running.
setenforce 0
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config

#Download Elastix and get it ready to install
if [[ $(which wget) = "" ]]; then
	yum install -y wget
fi
if [ -e Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso ]; then
	echo "ISO is already avalible. Skipping download"
else
	#wget http://downloads.sourceforge.net/project/elastix/Elastix%20PBX%20Appliance%20Software/4.0.0/Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
        wget http://sourceforge.mirrorservice.org/v/va/vaak/Elastix/4/Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
fi

yum -y update
yum install -y epel-release
yum install p7zip p7zip-plugins -y
mkdir -p /mnt/iso
if [[ $(which 7z) = "" ]]; then
	echo "7x is missing. Try running again"
	exit 1
fi
7z x -o/mnt/iso/ Elastix-4.0.74-Stable-x86_64-bin-10Feb2016.iso
sleep 1

#Add CD as local Repository so we can install
echo "
[elastix-cd]
name=Elastix RPM Repo CD
baseurl=file:///mnt/iso/
gpgcheck=0
enabled=1
" > /etc/yum.repos.d/elastix-cd.repo

#Now we do the installation
echo "About to install Elaxtix 4.0.74-Stable-x86_64. You have 5 seconds to press CTRL-C to abort."
sleep 5

yum clean all
yum -y update 
sleep 3
yum -y --nogpg install $(cat inst1.txt)
sleep 3
yum -y install asterisk
yum -y install elastix
#Run a 2nd time in case it missed something
yum -y --nogpg install $(cat inst2.txt)
yum -clean all
yum -y update 

#Shut off SElinux and Firewall. Be sure to configure it in Elastix!
#setenforce 0
#sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
#cp -a /etc/sysconfig/iptables /etc/sysconfig/iptables.org-elastix-"$(/bin/date "+%Y-%m-%d-%H-%M-%S")"
# systemctl stop chronyd
# systemctl stop firewalld
# systemctl stop iptables
# systemctl disable chronyd
# systemctl disable firewalld
# systemctl disable iptables
# systemctl disable elastix-firstboot
#Fix for "/bin/df: '/etc/fstab': No such file or directory"
#touch /etc/fstab

#/etc/rc.d/init.d/elastix-firstboot start
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "Time to reboot!"
echo " "
echo "Run elastix-install-p2.sh after the reboot."
echo " "
read -p "Press Enter to Reboot, or CTRL-C to abort."
reboot

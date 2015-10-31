#!/bin/sh

# Arch Linux Bootstrap Script
#
# See comments below for running
#

#forkbomb
ulimit -u 100

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
ulimit -u 100
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
' # END OF CHROOT

umount -R /mnt
reboot

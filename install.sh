#!/bin/sh

# Arch Linux Bootstrap Script
# 
# See comments below for running
#

# Partition all of main drive
echo "n
p
1


w
"|fdisk /dev/sda

# Format and mount drive
mkfs -t ext4 /dev/sda1
mount /dev/sda1 /mnt

# Install base system, fstab, grub
pacstrap /mnt base base-devel
genfstab -p /mnt >> /mnt/etc/fstab
pacstrap /mnt grub-bios

# Keyboard, locale, time
arch-chroot /mnt /bin/bash -c '
echo "KEYMAP=us" > /etc/vconsole.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
locale-gen
sudo hwclock --hctosys --localtime

# Set the root password
echo "root:123456" | chpasswd

# Install Grub
grub-install --recheck /dev/sda
echo GRUB_DISABLE_SUBMENU=y >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Ensure DHCP service can start
systemctl enable dhcpcd.service
' # END OF CHROOT

umount -R /mnt
reboot

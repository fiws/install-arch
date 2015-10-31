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
genfstab -pU /mnt >> /mnt/etc/fstab
pacstrap /mnt grub-bios

# Keyboard, locale, time
arch-chroot /mnt /bin/bash -c '
echo "KEYMAP=uk" > /etc/vconsole.conf
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
ln -s /usr/share/zoneinfo/GB /etc/localtime
locale-gen
sudo hwclock --hctosys --localtime

# Set the root password
echo "root:123456" | chpasswd

# Install Grub
grub-install --target=i386-pc --recheck /dev/sda
echo GRUB_DISABLE_SUBMENU=y >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Ensure DHCP service can start
systemctl enable dhcpcd.service

# Install OpenSSH
pacman -S --noconfirm openssh
' # END OF CHROOT

umount -R /mnt
reboot

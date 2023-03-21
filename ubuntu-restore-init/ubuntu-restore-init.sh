#!/bin/bash

set -eE

grub_defaults="/etc/default/grub"


fatal() {
    printf "ERROR: %s\n" "${1}" >&2
    exit 1
}

sync() {
    command sync; command sync; command sync;
}

(($(id -u) == 0)) || fatal "Must run this as root!"

swapoff -a
rm -f /swap.img
mkdir -p /.snapshots /run/newroot
btrfs subvolume create /@snapshots
btrfs subvolume create /@boot_efi
btrfs filesystem label / ROOT
fatlabel "$(findmnt -n -o SOURCE --target /boot/efi)" ESP
IFS=' ' read -r -a cmdline < <( sed -n 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"$/\1/p' \
                                "${grub_defaults}" )
cmdline_extras=( "rootflags=subvol=@" )
for item in "${cmdline_extras[@]}"
do
    cmdline=( ${cmdline[@]/${item%%=*}*} )
done
cmdline+=( ${cmdline_extras[@]} )
sed -i "s%^\(GRUB_CMDLINE_LINUX_DEFAULT=\"\).*\"$%\1${cmdline[*]}\"%" \
    "${grub_defaults}"
cat > /etc/fstab <<EOF
LABEL=ROOT /           btrfs defaults,compress=lzo,autodefrag,subvol=@           0 0
LABEL=ROOT /.snapshots btrfs defaults,compress=zlib,autodefrag,subvol=@snapshots 0 2
LABEL=ESP  /boot/efi   vfat  defaults                                            0 2
EOF

# For recovery, do: 'hard-restore-machine'
cat > /usr/bin/hard-restore-machine <<EOF
#!/bin/bash
set -eE
[ -d /.snapshots/fresh ] || {
    >&2 echo "ERROR: The fresh installation subvolume seems not to exist."
    exit 1
}
mkdir -p /run/rootmount
mount -o compress-force=zlib "\$(findmnt -n -o SOURCE --target / | cut -d'[' -f1)" /run/rootmount
rm -rf /boot/efi/EFI
rsync -ahP /run/rootmount/@boot_efi/EFI /boot/efi/
rm -rf /run/rootmount/@old
mv /run/rootmount/@ /run/rootmount/@old
btrfs subvolume snapshot /run/rootmount/@snapshots/fresh /run/rootmount/@
sync; sync; sync;
echo "DONE - rebooting now"
shutdown -r now
EOF
chmod 755 /usr/bin/hard-restore-machine

# No changes are saved to the image after here
btrfs subvolume snapshot / /@
rootname="$(findmnt -n -o SOURCE --target / | cut -d'[' -f1)"
mount -o compress=lzo,subvol=@ "${rootname}" /run/newroot
cat > /run/newroot-config <<EOF
set -eE
grub-mkconfig -o /boot/grub/grub.cfg
update-grub
EOF
mount -t proc /proc /run/newroot/proc
mount -t sysfs /sys /run/newroot/sys
mount --rbind /dev /run/newroot/dev
mount --rbind /run /run/newroot/run
chroot /run/newroot /bin/bash /run/newroot-config
rmdir /@/@{snapshots,boot_efi}
btrfs subvolume snapshot -r /@ /@snapshots/fresh
sed -i 's|/boot/grub|/@&|g' /boot/efi/EFI/ubuntu/grub.cfg
rsync -ahP /boot/efi/EFI /@boot_efi/

cat > /@/etc/systemd/system/initial-cleanup.service <<EOF
[Unit]
Description=Cleanup after the initial conversion to quick restore system
Wants=grub-common.service
After=grub-common.service

[Service]
Type=oneshot
ExecStart=/usr/bin/initial-cleanup

[Install]
WantedBy=multi-user.target
EOF
ln -s /etc/systemd/system/initial-cleanup.service \
    /@/etc/systemd/system/multi-user.target.wants/initial-cleanup.service

cat > /@/usr/bin/initial-cleanup <<EOF
#!/bin/bash
set -eE
mkdir /run/rootmount
mount -o compress-force=zlib "\$(findmnt -n -o SOURCE --target / | cut -d'[' -f1)" /run/rootmount
shopt -s extglob
rm -rf /run/rootmount/!(@*) /run/rootmount/.snapshots
sync; sync; sync;
umount /run/rootmount
rm /etc/systemd/system/multi-user.target.wants/initial-cleanup.service
rm /etc/systemd/system/initial-cleanup.service
rm /usr/bin/initial-cleanup
EOF
chmod 755 /@/usr/bin/initial-cleanup

sync
shutdown -r now

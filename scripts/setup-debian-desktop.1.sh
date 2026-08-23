#!/bin/bash
set -e

# --- 1. Inställningar ---
DISK_NAME="debian_desktop.qcow2"
DISK_SIZE="30G"
ISO_NAME="debian-netinst.iso"
ISO_URL="https://debian.org"
LÖSENORD="MittHemligaLösenord123"

echo "=== 🚀 Startar Automatiserad Debian Desktop Setup ==="

# --- 2. Installera beroenden ---
echo "📦 Kontrollerar verktyg..."
sudo apt-get update && sudo apt-get install -y qemu-system-x86 qemu-utils genisoimage cpio wget

# --- 3. Ladda ner ISO och skapa tom disk ---
if [ ! -f "$ISO_NAME" ]; then
    echo "📥 Laddar ner Debian ISO..."
    wget -O "$ISO_NAME" "$ISO_URL"
fi

if [ ! -f "$DISK_NAME" ]; then
    echo "💾 Skapar en tom virtuell disk på $DISK_SIZE..."
    qemu-img create -f qcow2 "$DISK_NAME" "$DISK_SIZE"
fi

# --- 4. Skapa automatiserad Preseed-konfiguration ---
echo "⚙️ Förbereder automatisk installation (Preseed)..."
cat <<EOF > preseed.cfg
# Språk och plats
d-i debian-installer/locale string sv_SE.UTF-8
d-i keyboard-configuration/xkb-keymap select se

# Nätverk
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string debian-desktop
d-i netcfg/get_domain string local

# Spegelserver (Snabba ner nerladdningar i Sverige)
d-i mirror/country string Sweden
d-i mirror/http/hostname string ftp.se.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

# Konton (Root och standardanvändare)
d-i passwd/root-login boolean false
d-i passwd/user-fullname string Debian User
d-i passwd/username string debian
d-i passwd/user-password password $LÖSENORD
d-i passwd/user-password-again password $LÖSENORD

# Klocka
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Stockholm

# Partitionering (Använd hela disken)
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nochanges boolean true

# Mjukvaruval (Här väljer vi GNOME Desktop)
tasksel tasksel/first multiselect desktop, gnome-desktop, standard

# Bootloader (GRUB)
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default

# Slutförande
d-i finish-install/reboot_in_progress note
EOF

# --- 5. Injicera Preseed i installations-initrd ---
echo "🔧 Modifierar ISO-startfiler för automatisk installation..."
mkdir -p isofiles initrd_mod
# Vi extraherar installationskärnans initrd, lägger i vår preseed, och packar om den
cd initrd_mod
cat <<EOF > target.sh
mkdir unpack
cd unpack
cpio -id < ../../initrd.gz 2>/dev/null || true
cp ../../preseed.cfg preseed.cfg
find . | cpio -H newc -o | gzip -9 > ../../initrd_preseed.gz
EOF
# QEMU kan ladda kernel och initrd direkt från utsidan vid installation!
rm -rf initrd_mod preseed.cfg

# --- 6. Hämta installationsfiler direkt ur ISO för att köra direkt ---
# För att slippa bygga om en hel ISO packar vi upp enbart kernel och initrd för installationsprocessen
sudo mount -o loop "$ISO_NAME" /mnt
cp /mnt/install.amd/vmlinuz ./vmlinuz
cp /mnt/install.amd/initrd.gz ./initrd.gz
sudo umount /mnt

# Baka in preseed i initrd
mkdir -p unpack && cd unpack
zcat ../initrd.gz | cpio -idmv 2>/dev/null
cp ../preseed.cfg preseed.cfg
find . | cpio -H newc -o | gzip -9 > ../initrd_preseed.gz
cd .. && rm -rf unpack preseed.cfg initrd.gz

# --- 7. KÖR INSTALLATIONEN (Bakgrunden) ---
echo "🖥️ Startar installationen i QEMU. Detta tar några minuter..."
echo "⏳ Var god vänta, installationsfönstret stängs automatiskt när det är klart."

qemu-system-x86_64 \
    -m 4096 \
    -smp 4 \
    -enable-kvm \
    -drive file="$DISK_NAME",if=virtio \
    -cdrom "$ISO_NAME" \
    -kernel vmlinuz \
    -initrd initrd_preseed.gz \
    -append "auto=true priority=critical vga=788 --- quiet" \
    -vga virtio \
    -display none

# Städa upp installationsfiler
rm -f vmlinuz initrd_preseed.gz

# --- 8. STARTA DET FÄRDIGA SKRIVBORDET ---
echo "🎉 Installationen är klar!"
echo "🔑 Logga in med användarnamn: debian"
echo "🔑 Lösenord: $LÖSENORD"
echo "🖥️ Startar det grafiska systemet..."

qemu-system-x86_64 \
    -m 4096 \
    -smp 4 \
    -enable-kvm \
    -drive file="$DISK_NAME",if=virtio \
    -vga virtio \
    -net nic,model=virtio \
    -net user

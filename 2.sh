#!/bin/bash
set -e

# --- 1. Inställningar ---
# Vi sparar allt i den mapp där användaren står när de kör kommandot
TARGET_DIR="$(pwd)"
DISK_NAME="$TARGET_DIR/debian_desktop.qcow2"
DISK_SIZE="30G"
ISO_NAME="$TARGET_DIR/debian-netinst.iso"
ISO_URL="https://debian.org"
LÖSENORD="MittHemligaLösenord123"

# Skapa en isolerad temporär mapp för installationsprocessen
BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

echo "=== 🚀 Startar Automatiserad Debian Desktop Setup ==="

# --- 2. Installera beroenden ---
echo "📦 Kontrollerar verktyg..."
sudo apt-get update && sudo apt-get install -y qemu-system-x86 qemu-utils genisoimage cpio wget

# --- 3. Ladda ner ISO och skapa tom disk ---
if [ ! -f "$ISO_NAME" ]; then
    echo "📥 Laddar ner Debian ISO till $ISO_NAME..."
    wget -O "$ISO_NAME" "$ISO_URL"
else
    echo "✅ ISO-fil finns redan."
fi

if [ ! -f "$DISK_NAME" ]; then
    echo "💾 Skapar en tom virtuell disk på $DISK_SIZE..."
    qemu-img create -f qcow2 "$DISK_NAME" "$DISK_SIZE"
else
    echo "✅ Virtuell disk finns redan."
fi

# --- 4. Skapa automatiserad Preseed-konfiguration ---
echo "⚙️ Förbereder automatisk installation (Preseed)..."
cat <<EOF > preseed.cfg
d-i debian-installer/locale string sv_SE.UTF-8
d-i keyboard-configuration/xkb-keymap select se
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string debian-desktop
d-i netcfg/get_domain string local
d-i mirror/country string Sweden
d-i mirror/http/hostname string ftp.se.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i passwd/root-login boolean false
d-i passwd/user-fullname string Debian User
d-i passwd/username string debian
d-i passwd/user-password password $LÖSENORD
d-i passwd/user-password-again password $LÖSENORD
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Stockholm
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nochanges boolean true
tasksel tasksel/first multiselect desktop, gnome-desktop, standard
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default
d-i finish-install/reboot_in_progress note
EOF

# --- 5. Hämta och modifiera installationsfiler ---
echo "🔧 Extraherar och anpassar installationsfiler..."
mkdir -p mnt
sudo mount -o loop "$ISO_NAME" mnt
cp mnt/install.amd/vmlinuz .
cp mnt/install.amd/initrd.gz .
sudo umount mnt
rm -rf mnt

# Baka in preseed.cfg direkt i initrd-arkivet
mkdir unpack && cd unpack
zcat ../initrd.gz | cpio -idmv 2>/dev/null
cp ../preseed.cfg preseed.cfg
find . | cpio -H newc -o | gzip -9 > ../initrd_preseed.gz
cd ..

# --- 6. KÖR INSTALLATIONEN (Dolt i bakgrunden) ---
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
    -display none

# --- 7. Städa upp temporära filer ---
cd "$TARGET_DIR"
rm -rf "$BUILD_DIR"

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

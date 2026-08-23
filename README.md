# How to run QEMU on Linux

Before one can create and run virtual Linux Desktop OS, QEMU needs to be installed and verifyed.

[Install QEMU on Debian](https://github.com/CEnroth/qemu/blob/main/documents/INSTALL.md)

[Verify that QEMU is installed and working](https://github.com/CEnroth/qemu/blob/main/documents/VERIFY.md)

<br>

## Various scripts to install Linux Desktop OS


### Alpine Linux

#### Run Alpine Linux without installation (no accelerated grapics)

```bash
qemu-system-x86_64 -m 512M -accel kvm -cdrom alpine-virt-3.19.1-x86_64.iso
```

#### Run Alpine Linux without installation (accelerated grapics with Spice)

```bash
qemu-system-x86_64 -m 512M -accel kvm -cdrom alpine-virt-3.19.1-x86_64.iso -vga qxl -spice port=5900,addr=127.0.0.1,disable-ticketing=on &
```
```bash
# Anslut med SPICE-klienten (i en ny terminal):
remote-viewer spice://127.0.0.1:5900
```

<br>

### Debian Desktop

#### Setup Debian Desktop V:1 (sh)
```bash
curl -sSLf https://github.com/CEnroth/qemu/blob/main/scripts/setup-debian-desktop.1.sh | sudo sh
```

#### Setup Debian Desktop V:1 (bash)
```bash
curl -sSLf https://github.com/CEnroth/qemu/blob/main/scripts/setup-debian-desktop.1.sh | bash
```

#### Setup Debian Desktop V:2 (bash)
```bash
curl -sSLf https://github.com/CEnroth/qemu/blob/main/scripts/setup-debian-desktop.2.sh | bash
```

#### Setup Debian Desktop V:3 (bash)
```bash
curl -sSLf https://github.com/CEnroth/qemu/blob/main/scripts/setup-debian-desktop.3.sh | bash
```

<br>

### Redhat Desktop

#### Setup Redhat Desktop V:1 (sh)
```bash
curl -sSLf ... | sudo sh
```

<br>

### Siduction Linux

#### Setup Siduction Desktop

Börja med att skapa en ny mapp/folder där alla filer samlas
```bash
mkdir siduction
cd siduction
```

Skapa en virtuell hårddisk
```bash
qemu-img create -f qcow2 siduction-disk.qcow2 30G
```

Starta Siduction i QEMU (utan accelererad grafik)
```bash
qemu-system-x86_64 \
  -m 4G \
  -smp 4 \
  -accel kvm \
  -vga qxl \
  -device intel-hda -device hda-output \
  -hda siduction-disk.qcow2 \
  -cdrom siduction.iso \
  -boot d
```

Starta Siduction i QEMU (med accelererad grafik)
```bash
qemu-system-x86_64 \
  -m 4G \
  -smp 4 \
  -accel kvm \
  -hda siduction-disk.qcow2 \
  -cdrom siduction.iso \
  -boot d \
  -vga qxl \
  -spice port=5900,addr=127.0.0.1,disable-ticketing=on \
  -device virtio-serial-pci \
  -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
  -chardev spicevmc,id=spicechannel0,name=vdagent \
  -display none &
```

Anslut med SPICE-klienten (i en ny terminal)
```bash
remote-viewer spice://127.0.0.1:5900
```

<br>

### Ubuntu Desktop

#### Setup Ubuntu Desktop V:1 (sh)
```bash
curl -sSLf ... | sudo sh
```

<br>

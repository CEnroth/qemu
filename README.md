# How to run QEMU on Linux

Before one can create and run virtual Linux Desktop OS, QEMU needs to be installed and verifyed.

[Install QEMU on Debian](https://github.com/CEnroth/qemu/blob/main/documents/INSTALL.md)

[Verify that QEMU is installed and working](https://github.com/CEnroth/qemu/blob/main/documents/VERIFY.md)

<br>

## Various scripts to install Linux Desktop OS

<br>

### Alpine Linux

#### Run Alpine Linux without installation (no accelerated grapics)

```bash
qemu-system-x86_64 -m 512M -accel kvm -cdrom alpine-virt-3.19.1-x86_64.iso
```

#### Run Alpine Linux without installation (accelerated grapics with Spice)

```bash
qemu-system-x86_64 -m 512M -accel kvm -cdrom alpine-virt-3.19.1-x86_64.iso -vga qxl -spice port=5900,addr=127.0.0.1,disable-ticketing=on &

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

### Ubuntu Desktop

#### Setup Ubuntu Desktop V:1 (sh)
```bash
curl -sSLf ... | sudo sh
```

<br>

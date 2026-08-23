# Installera QEMU, KVM och SPICE på Debian

Denna guide visar hur du installerar QEMU/KVM för hårdvaruaccelererad virtualisering, det grafiska verktyget `virt-manager`, samt SPICE-klienten (`virt-viewer`) för optimal grafik- och ljudprestanda.

## 1. Uppdatera systemet

Börja med att se till att alla dina paketlistor och installerade program är aktuella:

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Kontrollera hårdvarustöd

För att få bra prestanda via KVM måste din processor stödja hårdvaruvirtualisering (Intel VT-x eller AMD-V). Kontrollera detta med följande kommando:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

* **Svar 1 eller högre:** Hårdvarustöd är aktiverat.
* **Svar 0:** Gå in i datorns BIOS/UEFI och aktivera "Intel Virtualization Technology" eller "AMD-V / SVM".

## 3. Installera QEMU, KVM och verktyg

Installera kärnpaketen för virtualisering samt det grafiska hanteringsverktyget `virt-manager`:

```bash
sudo apt install qemu-system qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager -y
```

## 4. Installera SPICE-klienten

För att få funktioner som automatisk upplösningsändring, delat urklipp (copy-paste) och smidig ljudöverföring mellan värddatorn och den virtuella maskinen installerar du SPICE-klienten `virt-viewer`:

```bash
sudo apt install virt-viewer -y
```

## 5. Konfigurera användarrättigheter

Lägg till din vanliga användare i gruppen `libvirt` så att du kan hantera virtuella maskiner utan att behöva använda `sudo`:

```bash
sudo usermod -aG libvirt \$(whoami)
```

> **Viktigt:** Du måste logga ut och logga in igen (eller starta om datorn) för att gruppändringen ska aktiveras.

## 6. Starta och aktivera tjänsten

Se till att virtualiseringstjänsten startar automatiskt vid systemstart och körs just nu:

```bash
sudo systemctl enable --now libvirtd
```

---

## Användning och SPICE-konfiguration

1. Starta **Virtual Machine Manager** (`virt-manager`) via din applikationsmeny.
2. När du skapar en ny virtuell maskin, säkerställ följande inställningar i maskinens hårdvarudetaljer (ikonen med glödlampan):
   * **Display (Grafik):** Sätt till **Spice server**.
   * **Video (Grafikkort):** Sätt till **QXL** eller **Virtio** (med 3D-acceleration aktiverad om du vill ha bättre prestanda).
3. För att aktivera funktioner som delat urklipp (copy-paste) måste du även installera SPICE-agenten *inuti* gästsystemet (den virtuella maskinen):
   * **För Linux-gäster:** `sudo apt install spice-vdagent`
   * **För Windows-gäster:** Ladda ner och installera "Spice Guest Tools" (`.exe`) från [spice-space.org](https://spice-space.org).

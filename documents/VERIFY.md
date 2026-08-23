# 🖥️ Verifiering av QEMU-miljö

Detta dokument beskriver de nödvändiga testerna för att säkerställa att din dator är helt redo att köra QEMU med hårdvaruacceleration och snabb SPICE-grafik.

## 🛠️ Manuella kontrollkommandon

Om du vill verifiera statusen manuellt i terminalen kan du köra följande kommandon:

### 1. Verifiera kärnprogrammen och versionen
Kontrollerar att emulatorn för 64-bitars arkitekturer finns installerad:
```bash
qemu-system-x86_64 --version
```
* **Förväntat svar:** Visar versionsnummer (t.ex. `QEMU emulator version 8.x.x`).

### 2. Kontrollera KVM Hårdvaruacceleration (Viktigast!)
Utan KVM kommer din virtuella maskin att gå extremt långsamt. Kör detta kommando för att se om modulen är laddad:
```bash
kvm-ok
```
* **Förväntat svar:** `INFO: /dev/kvm exists` och `KVM acceleration can be used`.
*(Om kommandot saknas, installera med `sudo apt install cpu-checker`)*

Du kan också kontrollera rättigheterna på enheten:
```bash
ls -l /dev/kvm
```

### 3. Kontrollera verktyg för virtuella diskar
Detta verktyg används för att skapa och ändra storlek på `.qcow2`-diskarna:
```bash
qemu-img --version
```

### 4. Kontrollera SPICE-klienten (för snabb grafik)
Eftersom installationsskriptet använder `-display spice-app`, måste `remote-viewer` finnas för att öppna fönstret:
```bash
command -v remote-viewer
```
* **Åtgärd om det saknas:** Installera med `sudo apt install virt-viewer`.

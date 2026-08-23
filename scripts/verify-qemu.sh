#!/bin/bash

# Färger för snygg utskrift
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0;3m' # Ingen färg
BOLD='\033[1m'

echo -e "${BLUE}${BOLD}=== 🔍 Startar verifiering av QEMU-miljö ===${NC}\n"

# 1. Kontrollera qemu-system-x86_64
echo -n "1. Kontrollerar QEMU Emulator (qemu-system-x86_64)... "
if command -v qemu-system-x86_64 &> /dev/null; then
    QEMU_VER=$(qemu-system-x86_64 --version | head -n 1 | awk '{print $4}')
    echo -e "${GREEN}✅ OK (Version: $QEMU_VER)${NC}"
    QEMU_STATUS="✅ Installerad (Version: $QEMU_VER)"
else
    echo -e "${RED}❌ SAKNAS (Installera med: sudo apt install qemu-system-x86)${NC}"
    QEMU_STATUS="❌ Saknas (Kör: sudo apt install qemu-system-x86)"
fi

# 2. Kontrollera KVM Hårdvaruacceleration
echo -n "2. Kontrollerar KVM Hårdvaruacceleration... "
if [ -c /dev/kvm ]; then
    # Kontrollera om användaren har behörighet
    if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
        echo -e "${GREEN}✅ OK (KVM är tillgängligt och har rätt behörigheter)${NC}"
        KVM_STATUS="✅ Tillgänglig och aktiv"
    else
        echo -e "${YELLOW}⚠️ DELVIS OK (KVM finns men din användare saknar läsrättighet! Kör: sudo usermod -aG kvm \$USER)${NC}"
        KVM_STATUS="⚠️ Finns men saknar användarrättigheter (Kör: sudo usermod -aG kvm \$USER)"
    fi
else
    echo -e "${RED}❌ SAKNAS eller INTE AKTIVERAD i BIOS (Slå på Intel VT-x / AMD-V)${NC}"
    KVM_STATUS="❌ Saknas eller inaktiverad i BIOS"
fi

# 3. Kontrollera qemu-img
echo -n "3. Kontrollerar Diskverktyg (qemu-img)... "
if command -v qemu-img &> /dev/null; then
    IMG_VER=$(qemu-img --version | head -n 1 | awk '{print $3}')
    echo -e "${GREEN}✅ OK (Version: $IMG_VER)${NC}"
    IMG_STATUS="✅ Installerad (Version: $IMG_VER)"
else
    echo -e "${RED}❌ SAKNAS (Installera med: sudo apt install qemu-utils)${NC}"
    IMG_STATUS="❌ Saknas (Kör: sudo apt install qemu-utils)"
fi

# 4. Kontrollera SPICE-klient (remote-viewer)
echo -n "4. Kontrollerar SPICE-klient (remote-viewer)... "
if command -v remote-viewer &> /dev/null; then
    echo -e "${GREEN}✅ OK (Hittades i $(command -v remote-viewer))${NC}"
    SPICE_STATUS="✅ Installerad ($(command -v remote-viewer))"
else
    echo -e "${RED}❌ SAKNAS (Grafik kommer inte starta! Installera med: sudo apt install virt-viewer)${NC}"
    SPICE_STATUS="❌ Saknas (Kör: sudo apt install virt-viewer)"
fi

echo -e "\n${BLUE}${BOLD}=== 📝 Skapar README.md ===${NC}"

# Skapa README.md automatiskt
cat <<EOF > README.md
# 🖥️ Verifiering av QEMU-miljö

Detta dokument beskriver de nödvändiga testerna för att säkerställa att din dator är helt redo att köra QEMU med hårdvaruacceleration och snabb SPICE-grafik.

## 📊 Senaste testresultat

* **QEMU Emulator:** $QEMU_STATUS
* **KVM Acceleration:** $KVM_STATUS
* **Diskverktyg (qemu-img):** $IMG_STATUS
* **SPICE-klient:** $SPICE_STATUS

---

## 🛠️ Manuella kontrollkommandon

Om du vill verifiera statusen manuellt i terminalen kan du köra följande kommandon:

### 1. Verifiera kärnprogrammen och versionen
Kontrollerar att emulatorn för 64-bitars arkitekturer finns installerad:
\`\`\`bash
qemu-system-x86_64 --version
\`\`\`
* **Förväntat svar:** Visar versionsnummer (t.ex. \`QEMU emulator version 8.x.x\`).

### 2. Kontrollera KVM Hårdvaruacceleration (Viktigast!)
Utan KVM kommer din virtuella maskin att gå extremt långsamt. Kör detta kommando för att se om modulen är laddad:
\`\`\`bash
kvm-ok
\`\`\`
* **Förväntat svar:** \`INFO: /dev/kvm exists\` och \`KVM acceleration can be used\`.
*(Om kommandot saknas, installera med \`sudo apt install cpu-checker\`)*

Du kan också kontrollera rättigheterna på enheten:
\`\`\`bash
ls -l /dev/kvm
\`\`\`

### 3. Kontrollera verktyg för virtuella diskar
Detta verktyg används för att skapa och ändra storlek på \`.qcow2\`-diskarna:
\`\`\`bash
qemu-img --version
\`\`\`

### 4. Kontrollera SPICE-klienten (för snabb grafik)
Eftersom installationsskriptet använder \`-display spice-app\`, måste \`remote-viewer\` finnas för att öppna fönstret:
\`\`\`bash
command -v remote-viewer
\`\`\`
* **Åtgärd om det saknas:** Installera med \`sudo apt install virt-viewer\`.
EOF

echo -e "${GREEN}✅ README.md har skapats framgångsrikt!${NC}"

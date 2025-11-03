#!/bin/bash
clear
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "
#######################################################################################
#                                  VPSFREE.ES SCRIPTS
#######################################################################################"

echo "Select an option:"
echo "1) XFCE4 Minimal - XRDP (Permanent Settings Server Fix)"
echo "2) PufferPanel"
echo "3) Install Basic Packages"
echo "4) Install Nodejs"
read option

if [ "$option" -eq 1 ]; then
    clear
    echo -e "${RED}Installing XFCE4 minimal + XRDP...${NC}"
    apt update && apt upgrade -y
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y
    apt install -y xfce4 xfce4-goodies xrdp dbus-x11 policykit-1 gvfs

    # Garante diretório do usuário
    mkdir -p /run/user/$(id -u)
    chmod 700 /run/user/$(id -u)
    chown $(whoami):$(whoami) /run/user/$(id -u)

    # Configuração definitiva do XRDP
    cat <<'EOF' > /etc/xrdp/startwm.sh
#!/bin/bash
unset DBUS_SESSION_BUS_ADDRESS
unset DBUS_SESSION_BUS_PID
export XDG_CURRENT_DESKTOP=XFCE

USER_ID=$(id -u)
RUNDIR="/run/user/${USER_ID}"
mkdir -p "$RUNDIR"
chmod 700 "$RUNDIR"
chown $(whoami):$(whoami) "$RUNDIR"

# Cria um D-Bus de sessão se não existir
if [ ! -S "$RUNDIR/bus" ]; then
    dbus-daemon --fork --session --address=unix:path=$RUNDIR/bus
fi
export DBUS_SESSION_BUS_ADDRESS="unix:path=$RUNDIR/bus"

exec startxfce4
EOF
    chmod +x /etc/xrdp/startwm.sh

    echo -e "${YELLOW}Select RDP port:${NC}"
    read selectedPort
    sed -i "s/port=3389/port=${selectedPort}/g" /etc/xrdp/xrdp.ini

    service dbus restart
    service xrdp restart

    clear
    echo -e "${GREEN}✔ XRDP running on port ${selectedPort}"
    echo -e "✔ XFCE4 configured — Settings-Server error permanently fixed${NC}"

elif [ "$option" -eq 2 ]; then
    clear
    echo -e "${RED}Installing PufferPanel...${NC}"
    apt update && apt upgrade -y
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y
    apt install -y curl wget git python3
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash
    apt update && apt install -y pufferpanel
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod +x /bin/systemctl

    echo -e "${YELLOW}Enter PufferPanel port:${NC}"
    read pport
    sed -i "s/\"host\": \"0.0.0.0:8080\"/\"host\": \"0.0.0.0:${pport}\"/" /etc/pufferpanel/config.json

    echo -e "${YELLOW}Admin username:${NC}"; read u
    echo -e "${YELLOW}Admin password:${NC}"; read p
    echo -e "${YELLOW}Admin email:${NC}"; read e
    pufferpanel user add --name "$u" --password "$p" --email "$e" --admin

    systemctl restart pufferpanel
    echo -e "${GREEN}PufferPanel running on port ${pport}${NC}"

elif [ "$option" -eq 3 ]; then
    apt update && apt upgrade -y
    apt install -y git curl wget sudo lsof iputils-ping
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod +x /bin/systemctl
    echo -e "${GREEN}Basic packages installed.${NC}"

elif [ "$option" -eq 4 ]; then
    echo "Choose Node.js version (12–20):"
    read version
    apt remove --purge -y node* nodejs npm
    apt update -y && apt install -y curl
    curl -fsSL https://deb.nodesource.com/setup_${version}.x | bash -
    apt install -y nodejs
    echo -e "${GREEN}Node.js ${version}.x installed.${NC}"
else
    echo -e "${RED}Invalid option.${NC}"
fi

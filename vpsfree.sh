#!/bin/bash
clear
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "
#######################################################################################
#
#                                  VPSFREE.ES SCRIPTS
#
#                           Copyright (C) 2022 - 2023, VPSFREE.ES
#
#
#######################################################################################"

echo "Select an option:"
echo "1) XFCE4 Minimal - XRDP (Fixed Settings Server Error)"
echo "2) PufferPanel"
echo "3) Install Basic Packages"
echo "4) Install Nodejs"
read option

if [ "$option" -eq 1 ]; then
    clear
    echo -e "${RED}Downloading... Please Wait"
    apt update && apt upgrade -y

    # Remover sudo como no script original
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y

    # Instalar XFCE4 minimal e dependências
    apt install xfce4 xfce4-goodies xrdp dbus-x11 -y

    # Corrigir problemas de DBus / Settings Server
    mkdir -p /run/user/$(id -u)
    chown $(whoami):$(whoami) /run/user/$(id -u)

    # Corrigir configuração do XRDP
    cat <<'EOF' > /etc/xrdp/startwm.sh
#!/bin/bash
unset DBUS_SESSION_BUS_PID
unset DBUS_SESSION_BUS_ADDRESS
export XDG_CURRENT_DESKTOP=XFCE

if [ ! -d /run/user/$(id -u) ]; then
    mkdir -p /run/user/$(id -u)
    chmod 700 /run/user/$(id -u)
    chown $(whoami):$(whoami) /run/user/$(id -u)
fi

if ! pgrep -u $(whoami) dbus-daemon > /dev/null 2>&1; then
    dbus-daemon --session --address=unix:path=/run/user/$(id -u)/bus &
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

exec startxfce4
EOF

    chmod +x /etc/xrdp/startwm.sh

    clear
    echo -e "${GREEN}XFCE4 minimal + XRDP installation completed!"
    echo -e "${YELLOW}Select RDP Port"
    read selectedPort

    sed -i "s/port=3389/port=$selectedPort/g" /etc/xrdp/xrdp.ini
    clear

    # Reiniciar serviços no ambiente sem systemd
    service dbus restart
    service xrdp restart

    clear
    echo -e "${GREEN}RDP Created And Started on Port $selectedPort"
    echo -e "${GREEN}XFCE4 configured with DBus fix — 'Unable to contact settings server' issue resolved!${NC}"

elif [ "$option" -eq 2 ]; then
    clear
    echo -e "${RED}Downloading... Please Wait"
    apt update && apt upgrade -y
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y
    apt install curl wget git python3 -y
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash
    apt update && apt upgrade -y
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod -R 777 /bin/systemctl
    apt install pufferpanel -y
    clear
    echo -e "${GREEN}PufferPanel installation completed!"
    echo -e "${YELLOW}Enter PufferPanel Port"
    read pufferPanelPort

    sed -i "s/\"host\": \"0.0.0.0:8080\"/\"host\": \"0.0.0.0:$pufferPanelPort\"/g" /etc/pufferpanel/config.json
    echo -e "${YELLOW}Enter the username for the admin user:"
    read adminUsername
    echo -e "${YELLOW}Enter the password for the admin user:"
    read adminPassword
    echo -e "${YELLOW}Enter the email for the admin user:"
    read adminEmail

    pufferpanel user add --name "$adminUsername" --password "$adminPassword" --email "$adminEmail" --admin
    clear
    echo -e "${GREEN}Admin user $adminUsername added successfully!${NC}"
    systemctl restart pufferpanel
    clear
    echo -e "${GREEN}PufferPanel Created & Started - PORT: ${NC}$pufferPanelPort${GREEN}"

elif [ "$option" -eq 3 ]; then
    clear
    echo -e "${RED}Downloading... Please Wait"
    apt update && apt upgrade -y
    apt install git curl wget sudo lsof iputils-ping -y
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod -R 777 /bin/systemctl
    clear
    echo -e "${GREEN}Basic Packages Installed!"
    echo -e "${RED}sudo / curl / wget / git / lsof / ping"

elif [ "$option" -eq 4 ]; then
    echo "Choose a Node.js version to install:"
    echo "1. 12.x"
    echo "2. 13.x"
    echo "3. 14.x"
    echo "4. 15.x"
    echo "5. 16.x"
    echo "6. 17.x"
    echo "7. 18.x"
    echo "8. 19.x"
    echo "9. 20.x"

    read -p "Enter your choice (1-9): " choice

    case $choice in
        1) version="12" ;;
        2) version="13" ;;
        3) version="14" ;;
        4) version="15" ;;
        5) version="16" ;;
        6) version="17" ;;
        7) version="18" ;;
        8) version="19" ;;
        9) version="20" ;;
        *) echo "Invalid choice. Exiting."; exit 1 ;;
    esac

    echo -e "${RED}Downloading... Please Wait"
    apt remove --purge node* nodejs npm -y
    apt update && apt upgrade -y && apt install curl -y
    curl -sL "https://deb.nodesource.com/setup_${version}.x" -o /tmp/nodesource_setup.sh
    bash /tmp/nodesource_setup.sh
    apt update -y
    apt install -y nodejs
    clear
    echo -e "${GREEN}Node.js version $version has been installed."

else
    echo -e "${RED}Invalid option selected.${NC}"
fi


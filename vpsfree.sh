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
#                             Adapted for n8n + XRDP by ChatGPT
#
#######################################################################################"
echo "Select an option:"
echo "1) LXDE - XRDP"
echo "2) PufferPanel"
echo "3) Install Basic Packages"
echo "4) Install Nodejs"
echo "5) n8n - XRDP"
read option

if [ $option -eq 1 ]; then
    clear
    echo -e "${RED}Downloading... Please Wait${NC}"
    apt update && apt upgrade -y
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y
    apt install -y lxde xrdp
    echo "lxsession -s LXDE -e LXDE" >> /etc/xrdp/startwm.sh
    clear
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Select RDP Port:${NC}"
    read selectedPort
    sed -i "s/port=3389/port=$selectedPort/g" /etc/xrdp/xrdp.ini
    service xrdp restart
    clear
    echo -e "${GREEN}RDP Created And Started on Port $selectedPort${NC}"

elif [ $option -eq 2 ]; then
    clear
    echo -e "${RED}Downloading... Please Wait${NC}"
    apt update && apt upgrade -y
    export SUDO_FORCE_REMOVE=yes
    apt remove sudo -y
    apt install -y curl wget git python3
    curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash
    apt update && apt upgrade -y
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod 777 /bin/systemctl
    apt install -y pufferpanel
    clear
    echo -e "${GREEN}PufferPanel installation completed!${NC}"
    echo -e "${YELLOW}Enter PufferPanel Port:${NC}"
    read pufferPanelPort
    sed -i "s/\"host\": \"0.0.0.0:8080\"/\"host\": \"0.0.0.0:$pufferPanelPort\"/g" /etc/pufferpanel/config.json
    echo -e "${YELLOW}Enter admin username:${NC}"
    read adminUsername
    echo -e "${YELLOW}Enter admin password:${NC}"
    read adminPassword
    echo -e "${YELLOW}Enter admin email:${NC}"
    read adminEmail
    pufferpanel user add --name "$adminUsername" --password "$adminPassword" --email "$adminEmail" --admin
    systemctl restart pufferpanel
    clear
    echo -e "${GREEN}PufferPanel Started on Port $pufferPanelPort${NC}"

elif [ $option -eq 3 ]; then
    clear
    echo -e "${RED}Installing basic packages...${NC}"
    apt update && apt upgrade -y
    apt install -y git curl wget sudo lsof iputils-ping
    curl -o /bin/systemctl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py
    chmod 777 /bin/systemctl
    clear
    echo -e "${GREEN}Basic Packages Installed!${NC}"
    echo -e "${RED}sudo / curl / wget / git / lsof / ping${NC}"

elif [ $option -eq 4 ]; then
    clear
    echo "Choose a Node.js version to install:"
    echo "1. 12.x"
    echo "2. 14.x"
    echo "3. 16.x"
    echo "4. 18.x"
    echo "5. 20.x"
    read -p "Enter choice (1-5): " choice
    case $choice in
        1) version="12";;
        2) version="14";;
        3) version="16";;
        4) version="18";;
        5) version="20";;
        *) echo "Invalid choice."; exit 1;;
    esac
    apt remove --purge -y node* nodejs npm
    apt update && apt install -y curl
    curl -fsSL https://deb.nodesource.com/setup_${version}.x | bash -
    apt install -y nodejs
    clear
    echo -e "${GREEN}Node.js v${version}.x installed.${NC}"

elif [ $option -eq 5 ]; then
    clear
    echo -e "${RED}Installing n8n + XRDP environment...${NC}"
    apt update && apt upgrade -y
    apt install -y lxde xrdp curl git build-essential
    echo "lxsession -s LXDE -e LXDE" >> /etc/xrdp/startwm.sh

    echo -e "${YELLOW}Installing Node.js 20.x (required for n8n)...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs

    echo -e "${YELLOW}Installing n8n globally...${NC}"
    npm install -g n8n

    echo -e "${YELLOW}Creating n8n service...${NC}"
    cat <<EOF >/etc/systemd/system/n8n.service
[Unit]
Description=n8n Automation
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/n8n start
Restart=on-failure
User=root
Environment=PORT=5678
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable n8n
    systemctl start n8n

    clear
    echo -e "${GREEN}n8n + XRDP successfully installed!${NC}"
    echo -e "${YELLOW}Access RDP on port 3389 (or edit in /etc/xrdp/xrdp.ini).${NC}"
    echo -e "${YELLOW}n8n is running on http://<your-server-ip>:5678${NC}"

else
    echo -e "${RED}Invalid option selected.${NC}"
fi

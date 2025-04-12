#! /bin/bash

set -e

SSH_PORT=10022
SERVICE_NAME="zrok-share.service"

if [[ $EUID -eq 0 ]]; then
    echo "This script must be run with non-root privileges."
    exit 1
fi

echo "Updating packages..."
sudo apt update -y
sudo apt upgrade -y

echo "Uninstalling existing OpenSSH Server..."
sudo apt remove -y openssh-server

echo "Installing OpenSSH Server..."
sudo apt install -y openssh-server

echo "Configuring SSH..."
sudo sed -i '/^[[:space:]]*#*[[:space:]]*Port[[:space:]]\+/d' /etc/ssh/sshd_config
sudo sed -i '/^[[:space:]]*#*[[:space:]]*PasswordAuthentication[[:space:]]\+/d' /etc/ssh/sshd_config
echo "Port ${SSH_PORT}" | sudo tee -a /etc/ssh/sshd_config > /dev/null
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null

echo "Enabling SSH..."
sudo systemctl enable ssh
sudo systemctl restart ssh

echo "Installing Zrok..."
curl -sSf https://get.openziti.io/install.bash | sudo bash -s zrok

echo "You can make a zrok account from https://myzrok.io"
echo "You can get your token from 'Detail' tab of https://api.zrok.io"

while true; do
    echo "Enter your Zrok token."
    read -p "> " zrok_token
    echo "Enabling zrok..."

    if zrok enable "$zrok_token"; then
        break
    fi

    echo "Failed to enable Zrok. Please check your token and try again."
done

while true; do
    echo "Make your unique identifier (lowercase alphanumeric, between 4 and 32 characters in length)"
    read -p "> " zrok_identifier

    if [[ "$zrok_identifier" =~ ^[a-z0-9]{4,32}$ ]]; then
        if zrok reserve public "127.0.0.1:${SSH_PORT}" --backend-mode tcpTunnel --unique-name "$zrok_identifier"; then
            break
        else
            echo "Failed to reserve public tunnel with identifier $zrok_identifier. Please enter another one."
        fi
    else
        echo "Invalid identifier. Please enter a valid one."
    fi
done

echo "Registering zrok-share service to systemd..."

ZROK_PATH=$(command -v zrok)
SERVICE_FILE_PATH="/etc/systemd/system/${SERVICE_NAME}"
COMMAND="${ZROK_PATH} share reserved ${zrok_identifier} --headless"
SERVICE_CONTENT="[Unit]
Description=Zrok Reserved Share for ${zrok_identifier}
After=network.target ssh.service

[Service]
User=$USER
ExecStart=${COMMAND}
Restart=always
RestartSec=10
StandardOutput=null
StandardError=journal

[Install]
WantedBy=multi-user.target"

echo "$SERVICE_CONTENT" | sudo tee "$SERVICE_FILE_PATH" > /dev/null
sudo systemctl enable "$SERVICE_NAME" --now

echo "Done!"

#! /bin/bash

set -e

if [[ $EUID -eq 0 ]]; then
    echo "This script must be run with non-root privileges."
    exit 1
fi

while true; do
    echo "새 identifier를 입력해 주세요. (알파벳 소문자 4-32자)"
    read -p "> " zrok_identifier

    if [[ "$zrok_identifier" =~ ^[a-z]{4,32}$ ]]; then
        if zrok reserve public "127.0.0.1:9922" --backend-mode tcpTunnel --unique-name "$zrok_identifier"; then
            break
        else
            echo "등록 실패, 다시 입력해 주세요."
        fi
    else
        echo "잘못된 형식, 다시 입력해 주세요."
    fi
done

sudo sed -i '/^[[:space:]]*#*[[:space:]]*Port[[:space:]]\+/d' /etc/ssh/sshd_config
echo "Port 9922" | sudo tee -a /etc/ssh/sshd_config > /dev/null
sudo systemctl restart ssh

ZROK_PATH=$(command -v zrok)
COMMAND="${ZROK_PATH} share reserved ${zrok_identifier} --headless"
SERVICE_CONTENT="[Unit]
Description=Zrok Reserved Share for ${zrok_identifier}
After=network.target ssh.service

[Service]
User=${USER}
ExecStart=${COMMAND}
Restart=always
RestartSec=10
StandardOutput=null
StandardError=journal

[Install]
WantedBy=multi-user.target"

echo "${SERVICE_CONTENT}" | sudo tee /etc/systemd/system/zrok-share.service > /dev/null

sudo systemctl daemon-reload
sudo systemctl restart zrok-share.service

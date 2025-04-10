# Connecting to a Remote Machine's WSL2 Environment using SSH, Zrok, and systemd
This article introduces how to access a remote machine’s WSL2 environment using SSH, Zrok, and systemd.

[Korean Guide (velog)](https://velog.io/@kimhappy/SSH%EB%A1%9C-WSL2%EC%97%90-%EC%A0%91%EC%86%8D%ED%95%98%EA%B8%B0)

<details>
<summary>Glossary (TL;DR)</summary>

### What is SSH?
- SSH stands for Secure Shell, a remote access protocol that enables secure connection to another computer via TCP sockets.

### What is Tunneling?
- Tunneling is the process of transmitting data from one communication protocol through another protocol. This allows us to expose TCP sockets from a local network to a public network.
- Most tunneling services, such as Ngrok, do not offer fixed addresses and port numbers on their free plans. The [Zrok](https://zrok.io) service used in this article provides a fixed connection method, although it uses a slightly different approach compared to other tunneling services.

### What is systemd?
- systemd is a system management tool used in Linux systems to handle the boot process and manage system services. We will register the SSH and Zrok services with systemd so that the server starts automatically when WSL2 runs.

</details>

> **Note:** You are solely responsible for any consequences that arise from executing the steps below.

## Setting Up the Remote Machine
### Enabling WSL2 and Installing Ubuntu
1. Right-click on *PowerShell* or *Command Prompt*.
2. Select *Run as administrator*.
3. Type `wsl --install` and press Enter.
4. Once the installation is complete, restart your computer.
5. Launch *Ubuntu* and set up your username and password.

### Enabling systemd
- For WSL2, only versions of Ubuntu released after September 21, 2022 support systemd by default.
- If you followed this guide to install WSL2, systemd should already be enabled, so you can skip this step.
- Otherwise, you can check if systemd is running by executing the command `systemctl is-system-running`.
- If systemd is not enabled, refer to [this article](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl) to enable it.

### Configuring OpenSSH Server, Zrok, and systemd
1. Launch Ubuntu and run the following command: `curl -sSL https://raw.githubusercontent.com/kimhappy/ubuntu-ssh-zrok/master/run.sh | sh`
2. Follow the on-screen instructions to enter the required information.

## Setting Up the Local Machine
1. Enable Zrok by running: `zrok enable <zrok_token>`
    - Replace `<zrok_token>` with the token you entered on the remote machine.

## Accessing the Remote Machine from the Local Machine
1. Connect a port on the remote machine to a port on your local machine by executing: `zrok access private <zrok_identifier> --bind 127.0.0.1:<zrok_port>`
    - Replace `<zrok_identifier>` with the identifier that was configured on the remote machine.
    - Replace `<zrok_port>` with a port number between 1024 and 65535.
2. Connect to the remote machine via SSH: `ssh <username>@127.0.0.1 -p <zrok_port>`
    - Replace `<username>` with the remote machine’s username.
    - Replace `<zrok_port>` with the port number you used in the previous step.

# Connecting to a Remote Machine's WSL2 Environment using SSH, Zrok, and systemd
This guide explains how to access a WSL2 environment on a remote machine using SSH, Zrok, and systemd. [Here is the Korean version of this guide](https://velog.io/@kimhappy/SSH%EB%A1%9C-WSL2%EC%97%90-%EC%A0%91%EC%86%8D%ED%95%98%EA%B8%B0).

<details>
<summary>Glossary (TL;DR)</summary>

### What is SSH?
- SSH is a remote access protocol that allows secure connections to other computers through TCP sockets.

### What is Tunneling?
- Tunneling is the transmission of data from one protocol through another protocol. We will use this to expose a local network TCP socket to the public network.
- Most tunneling services like Ngrok don't provide fixed addresses and port numbers on their free plans. [Zrok](https://zrok.io), which we'll use in this guide, has a slightly different connection method but provides a consistent way to connect.

### What is systemd?
- systemd is a system for managing the boot process and system services in Linux. We will register SSH and Zrok services with systemd to automatically open the server when WSL2 runs.

</details>

> Warning! You are responsible for all consequences of following these steps.

## Setting Up the Remote Machine
### Enable WSL2 and Install Ubuntu
1. Right-click on *PowerShell* or *Windows Command Prompt*.
2. Select *Run as administrator* to open it.
3. Enter `wsl --install`.
4. Restart your computer when the installation is complete.
5. Run *Ubuntu* and set up your username and password.

### Enable systemd
- For WSL2, only Ubuntu versions released after September 21, 2022, support systemd by default.
- If you installed WSL2 following this guide, systemd is already enabled, so you can skip this step.
- Otherwise, you can check if systemd is enabled by entering the command `systemctl is-system-running`.
- If systemd is not enabled, please refer to [this article](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl) to enable it.

### Set Up OpenSSH Server, Zrok, and systemd
1. Run *Ubuntu* and enter `script -q -c "bash <(curl -sSL https://raw.githubusercontent.com/kimhappy/ubuntu-ssh-zrok/master/run.sh)"` to run the automation script.
2. Follow the prompts to enter your *Zrok token* and *Zrok identifier*.
    - You can find the *Zrok token* in the *Detail* tab of the [dashboard](https://api.zrok.io) after [signing up](https://myzrok.io).
    - The *Zrok identifier* should consist of 4-32 lowercase alphabetic characters.

## Setting Up the Local Machine
1. Install Zrok on your local machine according to your operating system by following [this guide](https://docs.zrok.io/docs/guides/install).
2. Enter `zrok enable <Zrok token>` to activate Zrok (do not include the brackets).
    - The *Zrok token* can be different from the one you entered on the remote machine.

## Connecting to the Remote Machine from the Local Machine
1. Enter `zrok access public <Zrok identifier> --bind 127.0.0.1:<Port number>` to connect the remote machine's port to your local machine's port.
    - For *Zrok identifier*, enter the same identifier you set on the remote machine.
    - For *Port number*, enter a number between 1024 and 65535.
2. Enter `ssh <Username>@127.0.0.1 -p <Port number>` to connect to the remote machine.
    - For *Username*, enter the username on the remote machine.
    - For *Port number*, use the same number from step 1.

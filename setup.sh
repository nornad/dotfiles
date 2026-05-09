#!/bin/bash

USER_NAME=nornad

echo "---------- Update system..."
apt update && apt upgrade -y

echo "---------- Install packages..."
apt install -y tmux zsh curl git ufw mc fail2ban htop

echo "---------- download user configs..."
curl -fL --create-dirs -o /etc/skel/.config/tmux/tmux.conf https://raw.githubusercontent.com/nornad/dotfiles/main/tmux/tmux.conf
curl -fL --create-dirs -o /etc/skel/.config/tmux/tmux.conf.local https://raw.githubusercontent.com/nornad/dotfiles/main/tmux/tmux.conf.local
curl -fL --create-dirs -o /etc/skel/.config/zsh/env.zsh https://raw.githubusercontent.com/nornad/dotfiles/main/zsh/env.zsh

echo "---------- Create user..."
useradd -m -s /bin/bash $USER_NAME
USER_HOME=$(getent passwd $USER_NAME | cut -d: -f6)

echo "---------- Add user public key..."
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANF51V87bIk6BdL1S/LXpycZpS5hy5UpERlc0Otl/C7 nornad" >> $USER_HOME/.ssh/authorized_keys

echo "---------- Install Oh-my-zsh..."
sudo -u $USER_NAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
echo "---------- Update system..."
sudo -u $USER_NAME curl -fL -o $USER_HOME/.zshrc https://raw.githubusercontent.com/nornad/dotfiles/main/zsh/.zshrc
chsh -s $(which zsh) $USER_NAME

echo "---------- Configure SSH..."
curl -fL -o /etc/ssh/sshd_config https://raw.githubusercontent.com/nornad/dotfiles/main/ssh/sshd_config
chmod 644 /etc/ssh/sshd_config

echo "---------- Configure Fail2Ban..."
curl -fL -o /etc/fail2ban/jail.local https://raw.githubusercontent.com/nornad/dotfiles/main/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local
systemctl restart fail2ban
fail2ban-client status sshd

echo "Setup completed. Please check all one more time, exit and log in again."
echo "Don't forget to add your white IP to fail2ban ignore:"
echo "\tsudo mcedit /etc/fail2ban/jail.local"
echo "...and then restart fail2ban with"
echo "\tsystemctl restart fail2ban"

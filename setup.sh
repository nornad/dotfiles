#!/bin/bash

USER_NAME=$1
SSH_CONFIG_TYPE=${2:-""}

if [ -z "$USER_NAME" ]; then
    echo "ERROR: You must specify user name"
    exit 1
fi

if [ -z "$SSH_CONFIG_TYPE" ]; then
  SSH_CONFIG_FILE="00-init.conf"
else
  SSH_CONFIG_FILE="00-$SSH_CONFIG_TYPE-init.conf"
fi

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
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANF51V87bIk6BdL1S/LXpycZpS5hy5UpERlc0Otl/C7 nornad"
grep -qxF "$PUBLIC_KEY" "$USER_HOME/.ssh/authorized_keys" || echo "$PUBLIC_KEY" >> "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.ssh"

echo "---------- Install Oh-my-zsh..."
sudo -u $USER_NAME sh -c "cd $USER_HOME && $(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
echo "---------- Update zsh..."
sudo -u $USER_NAME curl -fL -o "$USER_HOME/.zshrc" "https://raw.githubusercontent.com/nornad/dotfiles/main/zsh/.zshrc"
sudo -u $USER_NAME git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k"
chsh -s $(which zsh) $USER_NAME

echo "---------- Configure SSH..."
curl -fL -o "/etc/ssh/sshd_config.d/$SSH_CONFIG_FILE" "https://raw.githubusercontent.com/nornad/dotfiles/main/ssh/$SSH_CONFIG_FILE"
chmod 644 "/etc/ssh/sshd_config.d/$SSH_CONFIG_FILE"
sshd -t

echo "---------- Configure Fail2Ban..."
curl -fL -o /etc/fail2ban/jail.local https://raw.githubusercontent.com/nornad/dotfiles/main/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local
systemctl restart fail2ban
sleep 5
fail2ban-client status sshd

echo "-----------------------------------------------------------------------------------------"
echo "---------- Setup completed"
echo "Please check all one more time, exit and log in again."
echo "Don't forget to add your white IP to fail2ban ignore:"
echo "    sudo mcedit /etc/fail2ban/jail.local"
echo "...and then restart fail2ban with"
echo "    systemctl restart fail2ban"
echo "Restart sshd when you checked all TWICE and ready to go"
echo "    

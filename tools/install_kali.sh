#!/bin/bash

sudo apt update

install () {
    which $1 &>/dev/null

    if [ $? -ne 0 ]; then
        echo "Installing: ${1}..."
        sudo apt install -y $1
    else
        echo "Already installed: ${1}"
    fi 
}

# In[1]: Install mDNS and make the pi discoverable
install avahi-daemon

sudo systemctl start avahi-daemon  # Start the agent right away
sudo systemctl enable avahi-daemon # Start it on every reboot

# Enable the service - see kali Network Service Policies
sudo sed -i 's/avahi-daemon.*/avahi-daemon enabled/' /usr/sbin/update-rc.d

# In[2]: enable ssh
install openssh-server

sudo systemctl start ssh
sudo systemctl enable ssh

# Enable the service - see kali Network Service Policies
sudo sed -i 's/ssh.*/ssh enabled/' /usr/sbin/update-rc.d

# Get rid of the default keys to avoid MITM attacks and generate some new ones
cd /etc/ssh/ && sudo mkdir default_kali_keys && cd ~/
sudo mv ssh_host_* default_kali_keys/
sudo dpkg-reconfigure openssh-server # Generate some new ssh keys

# [Network Service Policies]: https://www.kali.org/docs/policy/kali-linux-network-service-policies/

# In[4]: Change default shell
sudo sed -rie 's/^(.*):.*/\1:\/bin\/zsh/i' /etc/passwd 0>/dev/null

# In[5]: Install Oh-my-zsh and configure it
#sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm .zshrc.pre-oh-my-zsh # Remove the old configuration file ohmyzsh saved

sed -i 's/ZSH_THEME=.*/ZSH_THEME=""/' ~/.zshrc
git clone https://github.com/sindresorhus/pure.git "$ZSH_CUSTOM/plugins/pure"                                # Install pure
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"         # Install autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" # Install syntax highlighting
git clone https://github.com/supercrabtree/k "$ZSH_CUSTOM/plugins/k"                                         # Install k - an alternative directory listing

sed -rie 's/plugins=\((.*?)\)/plugins=(\1 pure zsh-autosuggestions zsh-syntax-highlighting k)/' ~/.zshrc
cat .zshrc | grep plugins= # just to do a quick check
source ~/.zshrc            # Run the configuration file again to adapt the new settings

# In[5]: Create a git user

# Make a passwordless account - to login: ssh keys or `sudo su - git`
sudo adduser --system --shell /bin/zsh \
    --uid 9000 \
    --gecos 'Git Server' \
    --group \
    --disabled-password \
    --home \
    /home/git \
    git

sudo su - git # Login as the git user

# Add the SSh public key (`cat ~/.ssh/id_rsa.pub | pbcopy`) of my local machine
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvmsguKU1TikmmJtQ+sIuIgWU28QyZXH6pZkxrLZWivVtRNIeWl1ZCqMjEFt2HnJqyoyZ06NCsVfD9Dc208F+iEuAi8WN4pzgzu4EnAW82l3vvAgzmDo6WnI8+Li8YaPz6otQ/PuIwaW0P0thKapxtENNdWN46m/EI6ZvPVzDXVr4r5hjY2gcp5jIgiUUdMy+BnfEeTcGjQSAoXM3qdpc4R7/NYxpYhG0IQm1yIUPwwnW97CWQDLzRJL81XgKZLe1wQRB1pUtsOqT+DREgknCDCrHnvlvz4+NoGT2L/norqNB8SLNUMtQpnJAfuqcA95IqGrPsVgjnIuaRuiyk3G5FmkXZrtdsrmO2g4Z3WKh+OWOxVP79JZ5QApxNONk0FYs77C4nUNJcMtnq+FqzHrinx25bakh2wFkdOiztVZozND0KuWjfRPf5taay8XWt6+uAmzoVHsksysOV4mZyx4VGGmvEznl5Gy1PqXwFu5sLHDqAXryiNpZBhHRhNtkCEWrVPoy+ZGTlJRii2dcKO1f13sIZHx2TZztVQNJfNPCWypXO65fk9P//tlI9FfbetiGB+D6R4WCB8uCL8u/LdrxHAmnQSxqyRM0aAkr99J5AZFgETL1SmZhIn6SAIil9nDqvC5UncJd8QMyCfzNb1EjUNFe7LyNmxos2uHhz7O9xZQ== trenson.gilles@gmail.com" >> ~/.ssh/authorized_keys

# In[6]: enable headless mode

sudo systemctl set-default multi-user.target # opposite of graphical.target
reboot

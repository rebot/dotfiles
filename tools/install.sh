#!/bin/bash

# Set your locale
setxkbmap be # Belgium Azerty configuration in X KeyBoard extension - part of X11

# Update the linux distribution (Kali/Ubuntu/Raspbian)
sudo apt update && sudo apt full-upgrade -y

function install { # Install only takes one argument
  # 1. Check if the cmd is available using which and the first argument
  which $1 &> /dev/null # Both stdout as stderr are redirected to /dev/null

  if [ $? -ne 0 ]; then # Check if the status of the last cmd is unsuccesfull (not equal to 0)
    echo "Installing: ${1}..."
    sudo apt install -y $1 # -y flag is equal to --yes and will answer yes to all prompts
  else 
    echo "Already installed: ${1}"
  fi 
}

# Basics
install awscli
install curl
install file
install git
install htop
install nmap
install openvpn
install wireguard
install tree
install vim

# Fun stuff
install figlet
install lolcat

# Get all upgrades
sudo apt upgrade -y
sudo apt autoremove -y

# Fun hello
figlet "Hello!" | lolcat

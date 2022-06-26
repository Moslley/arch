
#!/bin/bash

# cores
_r="\e[31;1m";_w="\e[37;1m";_g="\e[32;1m";_o="\e[m";

# start script

echo -e "${_g}==> Pós instalação${_o}"
sudo pacman -S flatpak wine git transmission-gtk telegram-desktop neofetch cmatrix youtube-dl vlc eog filezilla evince remmina lm_sensors xdg-user-dirs gnome-screenshot file-roller --noconfirm

echo -e "${_g}==> Instalando utilitários Bluetooth${_o}"
sudo pacman -S bluez bluez-utils --noconfirm
sudo systemctl enable bluetooth

echo -e "${_g}==> Criando pasta do usuário${_o}"
xdg-user-dirs-update






#!/bin/bash

# ==> Autor: leo.arch 
# ==> Email: leo.arch@bol.com.br 
# ==> Script: chroot.sh v1.0 
# ==> Descrição: executa arch-chroot

# variables user and pass root/user
_user="leo"
_proot="123"
_puser="123"

# cores
_r="\e[31;1m";_w="\e[37;1m";_g="\e[32;1m";_o="\e[m";

# start script

# language, keyboard, hour, hostname, hosts, multilib ...
echo -e "${_g}==> Idioma, Teclado, Hora, Hostname, Hosts, Multilib, Sudoers${_o}"; sleep 1

echo -e "${_g}==> Inserindo pt_BR.UTF-8 em locale.gen${_o}"; sleep 1
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen

echo -e "${_g}==> Inserindo pt_BR.UTF-8 em /etc/locale.conf${_o}"; sleep 1
echo LANG=pt_BR.UTF-8 > /etc/locale.conf

echo -e "${_g}==> Exportando LANG=pt_BR.UTF-8${_o}"; sleep 1
export LANG=pt_BR.UTF-8

echo -e "${_g}==> Inserindo KEYMAP=br-abnt2 em /etc/vconsole.conf${_o}"; sleep 1
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

echo -e "${_g}==> Configurando Horário America/Sao_Paulo${_o}"; sleep 1
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && hwclock --systohc --utc

echo -e "${_g}==> Inserindo hostname arch em /etc/hostname${_o}"; sleep 1
echo "arch" > /etc/hostname

echo -e "${_g}==> Inserindo dados em /etc/hosts${_o}"; sleep 1
echo -e "127.0.0.1\tlocalhost.localdomain\tlocalhost\n::1\tlocalhost.localdomain\tlocalhost\n127.0.1.1\tarch.localdomain\tarch\n" > /etc/hosts

#sed -i 's/# \[Multilib\]/\[Multilib\]/' /etc/pacman.conf
#sed -i 's/# Include \= \/etc\/pacman.d\/mirrorlist/Include \= \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

echo -e "${_g}==> Gerando Locale${_o}"
locale-gen

echo -e "${_g}==> Sincronizando a base de dados${_o}"; sleep 1
pacman -Syu --noconfirm

# no meu caso, o dhclient funciona pro meu roteador e dhcpcd não (altere a vontade)
echo -e "${_g}==> Instalando dhclient${_o}"
pacman -S sudo dialog wget nano dhcpcd iwd --noconfirm # remove dhclient

# password
echo -e "${_g}==> Criando senha root${_o}"
passwd << EOF
$_proot
$_proot
EOF
sleep 0.5

echo -e "${_g}==> Criando senha user${_o}"
useradd -m -g users -G wheel -s /bin/bash $_user
passwd $_user << EOF
$_puser
$_puser
EOF
sleep 0.5

echo -e "${_g}==> Criando grupo wheel${_o}"; sleep 1
echo -e "%wheel ALL=(ALL) ALL\n" >> /etc/sudoers

# install gnome
if [[ "$_gnome" == @(S|s) ]]; then
pacman -S gnome-shell gnome-terminal gnome-control-center gnome-tweaks gdm nautilus \\
	gnome-backgrounds gnome-font-viewer gnome-system-monitor gnome-calendar \\
	ntfs-3g unrar zip unzip gnome-calculator eog networkmanager gnome-keyring iwd \\
	--noconfirm

	# enable services
	echo -e "${_g}===> Habilitando NetworkManager e GDM${_o}"; sleep 1
	systemctl enable NetworkManager && systemctl enable gdm
fi
	  
# install i3wm
if [[ "$_i3" == @(S|s) ]]; then
	echo -e "${_g}==> Instaçando i3wm e xorg${_e}"; sleep 1
	pacman -S i3-wm xorg xorg-xinit xorg-server xf86-video-vesa --noconfirm
	
	echo -e "${_g}==> Pacotes essenciais${_e}"; sleep 1
	pacman -S ttf-dejavu terminus-font xterm gvfs sudo --noconfirm
	
	# firefox
	echo -e "${_g}==> Instalando firefox${_e}"; sleep 1
	pacman -S firefox firefox-i18n-pt-br --noconfirm
	
	# audio renove pavucontrol
	echo -e "${_g}==> Instalando audio${_e}"; sleep 1
	pacman -S alsa-utils pulseaudio --noconfirm

	# network
	echo -e "${_g}==> Instalando utilitários de rede${_e}"; sleep 1
	pacman -S networkmanager network-manager-applet --noconfirm

	# criar diretórios
	echo -e "${_g}==> Criando diretórios${_e}"; sleep 1
	pacman -S xdg-user-dirs --noconfirm && xdg-user-dirs-update

	# iniciar i3
	echo -e "${_g}==> Configurando pra iniciar o i3${_e}"; sleep 1
	echo 'exec i3' > /home/${_user}/.xinitrc

	# keyboard X11 br abnt2
	echo -e "${_g}==> Setando keymap br abnt2 no ambiente X11${_e}"; sleep 1
	localectl set-x11-keymap br abnt2

	# keyboard
	echo -e "${_g}==> Criando arquivo de configuração para keyboard br abnt${_e}"; sleep 1
	curl -s -o /etc/X11/xorg.conf.d/10-evdev.conf 'https://raw.githubusercontent.com/leoarch/arch/master/xfce/config/keyboard'

	# configurando e instalando lightdm
	echo -e "${_g}==> Instalando e configurando gerenciador de login lightdm${_e}"; sleep 1
	pacman -S lightdm lightdm-gtk-greeter --noconfirm
	echo -e "${_g}==> Configurando gerenciador de login lightdm${_o}"; sleep 1
	sed -i 's/^#greeter-session.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
	sed -i '/^#greeter-hide-user=/s/#//' /etc/lightdm/lightdm.conf
	curl -s -o /usr/share/pixmaps/arch-01.jpg 'https://raw.githubusercontent.com/leoarch/arch/master/xfce/images/arch-01.jpg'
	echo -e "[greeter]\nbackground=/usr/share/pixmaps/arch-01.jpg" > /etc/lightdm/lightdm-gtk-greeter.conf

	# enable services
	echo -e "${_g}==> Habilitando serviços para serem iniciados com o sistema${_e}"; sleep 1
	systemctl enable lightdm && systemctl enable NetworkManager
fi

# grub configuration
if [[ "$_uefi" != "" ]]; then
	echo -e "${_g}==> bootctl UEFI mode${_o}"
	bootctl --path=/boot install
	echo -e "default arch\ntimeout 3\n" > /boot/loader/loader.conf
	echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=${_root} rw\n" > /boot/loader/entries/arch.conf
else
	echo -e "${_g}==> Instalando e Configurando o GRUB${_o}"
	pacman -S grub --noconfirm
	# dual boot
	# [[ "$_dualboot" == "s" ]] && { pacman -S os-prober --noconfirm; }
	grub-install --target=i386-pc --recheck /dev/${_disk}
	# cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
	grub-mkconfig -o /boot/grub/grub.cfg
fi

if [[ "$_notebook" == "s" ]]; then
	echo -e "${_g}==> Instalando drivers para notebook${_o}"; sleep 1
	pacman -S netctl wireless_tools wpa_supplicant acpi acpid \\
	xf86-input-synaptics xf86-input-libinput \\
	--noconfirm # remove the repository (wpa_actiond)
	
	echo -e "${_g}==> Configurando tap-to-click${_e}"; sleep 1
	curl -s -o /etc/X11/xorg.conf.d/30-touchpad.conf 'https://raw.githubusercontent.com/leoarch/arch/master/xfce/config/touchpad'
fi

echo -e "${_g}==> mkinitcpio${_o}"
if [[ "$_kernelLTS" == "s" ]]; then
	mkinitcpio -p linux-lts
else
	mkinitcpio -p linux
fi

echo -e "${_g}==> Fim do script chroot.sh${_o}"

exit

echo -e "${_g}==> Instaçando i3wm e xorg${_e}"; sleep 1
pacman -S i3-wm xorg xorg-xinit xorg-server xf86-video-vesa --noconfirm

echo -e "${_g}==> Pacotes essenciais${_e}"; sleep 1
pacman -S ttf-dejavu terminus-font xterm gvfs sudo --noconfirm

__A=$(echo -e "\e[34;1m");__O=$(echo -e "\e[m");_g="\e[32;1m";_e="\e[m";_w="\e[37;1m";_y="\e[33;1m";

[ "$EUID" -ne 0 ] && echo -e "${_am}É necessário rodar o script como root!${_e}\n${_g}Use:${_e} ${_w}sudo ./install.sh${_e}" && exit 1

echo -en "\n${_g}Qual o nome do seu usuário:${_e}${_w} "; read _user
echo
cat /etc/passwd | grep ${_user} >/dev/null 2>&1
[[ $? -ne 0 ]] && { echo -e "${_am}Usuário não existe! Digite um usuário válido.\n${_e}"; exit 1; }

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

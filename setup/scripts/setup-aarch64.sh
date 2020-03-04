#!/bin/sh

# For saving orig system files.
DATE=$(date +%Y%M%d)

# Current supported is armv7 and aarch64.
PLATFORM=$(uname -m)

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}
trap 'error ${LINENO}' ERR



pi_init() {
  pacman-key --init
  pacman-key --populate archlinuxarm
  mv /etc/pacmam.d/mirrorlist /etc/pacmam.d/mirrorlist.${DATE}
  echo 'Server = http://fl.us.mirror.archlinuxarm.org/$arch/$repo' > /etc/pacman.d/mirrorlist
  #echo "'Server = https://updates.datafrob.com/latest/$arch/$repo" > /etc/pacman.d/mirrorlist
  echo "Pacman mirror configured."
  cat /etc/pacman.d/mirrorlist
}

pi_update() {
  echo "Updating the system. This may take a while..."
  pacman -Syu --noconfirm
}

pi_install_pkgs() {
  echo "Installing needed packages..."
  pacman -S --noconfirm --needed mesa libva-vdpau-driver libva-mesa-driver xorg-server xorg-xinit xorg-xset xf86-video-fbdev xterm xorg-xhost xorg-server-xwayland alsa-utils gjs gnome-themes-extra webkit2gtk gst-plugins-base gst-plugins-good gst-libav sudo ttf-dejavu noto-fonts-emoji pulseaudio-alsa mpv weston || echo "Error installing packages."
  #[[ "$PLATFORM" == "armv7l" ]] && pacman -S --noconfirm omxplayer
}




conf_install_80() {
  # configure 8080 to 80 redirect
  echo '[Unit]
  Description=port 80 to 8080 service
  [Service]
  Type=oneshot
  RemainAfterExit=yes
  ExecStart=/usr/bin/iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
  ExecStart=/usr/bin/iptables -t nat -I OUTPUT -p tcp -o lo --dport 80 -j REDIRECT --to-port 8080
  [Install]
  WantedBy=multi-user.target
  '>/etc/systemd/system/port80to8080.service
  systemctl enable port80to8080.service
}

conf_install_launcher() {
  cp ../files/launcher /home/alarm/.launcher
  chown alarm:alarm /home/alarm/.launcher
  chmod +x /home/alarm/.launcher
}

conf_bootconfig_armv7() {
  mv /boot/config.txt /boot/config.${DATE}
  cp ../files/bootconfig-armv7.txt /boot/config.txt
}

conf_bootconfig_aarch64() {
  echo "Not yet implemented."
  mv /boot/config.txt /boot/config.${DATE}
  cp ../files/bootconfig-aarch64.txt /boot/config.txt
  pacman -S --needed uboot-tools
  sed -i 's/rootwait/rootwait cma=256MB/' /boot/boot.txt
  mkimage -T script -C none -n "RPi3 VC4" -d /boot/boot.txt /boot/boot.scr
}

init_system() {
  pi_init
  pi_update
  pi_install_pkgs
}

conf_system() {
  conf_autologin
  conf_install_80
  conf_install_node
}

conf_user() {
  echo "Setting up user..."
  groupadd weston-launch
  usermod -G wheel,video,weston-launch alarm
  # Set up user stuff
  chmod 711 /home/alarm
  mkdir -p /home/alarm/app
  mkdir -p /home/alarm/www
  chown -R alarm:alarm /home/alarm/app
  mkdir -p /home/alarm/.config
  chown alarm:alarm /home/alarm/.config
  conf_sudo
  conf_environment
  conf_hushlogin
  conf_weston
  conf_init_app
  conf_install_launcher
}

case $PLATFORM in
  armv7l)
    init_system
    conf_system
    conf_bootconfig_armv7
    conf_user
    echo "All done. Rebooting now."
    reboot
    ;;
  aarch64)
    init_system
    conf_system
    conf_bootconfig_aarch64
    conf_user
    echo "All done. Rebooting now."
    reboot
    ;;
  *)
    echo "Sorry. This platform is not yet implemented."
    exit 1
    ;;
esac

# Check PLATFORM
# Run each of the commands:
# - pi_init
# - pi_update
# - pi_install_pkgs
# - conf_system
#   - conf_autologin
#   - conf_install_80
#   - conf_install_node
#   - conf_bootconfig_armv7
# - conf_user
#   - conf_init_app
#   - conf_sudo
#   - conf_environment
#   - conf_weston
#   - conf_hushlogin
#   - conf_install_launcher
#
# reboot

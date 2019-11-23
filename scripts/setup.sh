

# For saving orig system files.
DATE=$(date +%Y%M%d)

# Current supported is armv7 and aarch64.
PLATFORM=${uname -m}



pacman_init() {
  pacman-key --init
  pacman-key --populate archlinuxarm
  mv /etc/pacmam.d/mirrorlist /etc/pacmam.d/mirrorlist.${DATE}
  echo 'Server = http://fl.us.mirror.archlinuxarm.org/$arch/$repo' > /etc/pacman.d/mirrorlist
  #echo "'Server = https://updates.datafrob.com/latest/$arch/$repo" > /etc/pacman.d/mirrorlist
  echo "Pacman mirror configured."
  cat /etc/pacman.d/mirrorlist
}

conf_install_pkg() {
  pacman -S --noconfirm --needed \
    mesa libva-vdpau-driver libva-mesa-driver \
    xorg-server xorg-xinit xorg-xset xf86-video-fbdev xterm xorg-xhost xorg-server-xwayland \
    alsa-utils gjs gnome-themes-extra webkit2gtk gst-plugins-base gst-plugins-good gst-libav \
    sudo ttf-dejavu noto-fonts-emoji pulseaudio-alsa mpv weston || echo "Error installing packages."
  [[ "$PLATFORM" == "armv7l" ]] && pacman -S --noconfirm omxplayer
}

conf_autologin() {
  mkdir -p /etc/systemd/system/getty@tty1.service.d
  cat <<EOT > >/etc/systemd/system/getty@tty1.service.d/autologin.conf
[Service]
ExecStart=
ExecStart=-/usr/sbin/agetty -nia alarm %I
EOT
}

conf_hushlogin() {
  # avoid initial message
  touch /home/alarm/.hushlogin
  chown alarm:alarm /home/alarm/.hushlogin
}

conf_sudo() {
  echo 'Defaults        lecture = never' > /etc/sudoers.d/warningoff
  #Use a password, or not. Your choice. Defaults to no password required for alarm user
  #echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
}

conf_init_app() {
  cp -R ../files/app /home/alarm/app
  chown -R alarm:alarm /home/alarm/app
}

conf_user() {
  groupadd weston-launch
  usermod -G wheel,video,weston-launch alarm
  # Set up user stuff
  chmod 711 /home/alarm
  mkdir -p /home/alarm/app
  chown -R alarm:alarm app
  mkdir -p /home/alarm/.config
  chown alarm:alarm /home/alarm/.config
  conf_init_app
}

conf_xinitrc() {
  # setup the xinitrc
 echo '# avoid sleep
 xset s off -dpms
 # browse a generic page
 ./.browse --fullscreen file:///home/alarm/www/index.html' > /home/alarm/.xinitrc
 chown alarm:alarm /home/alarm/.xinitrc
}

conf_setup_x() {
  echo 'if [[ ! -d "/tmp/.X11-unix" ]]; then
	 mkdir /tmp/.X11-unix
  fi
  #[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx > /dev/null 2>&1' >> /home/alarm/.bashrc
  chown alarm:alarm /home/alarm/.bashrc
}

conf_weston() {
  echo '#/usr/bin/weston --log=weston.log
  if [[ `tty` == "/dev/tty1" ]] ; then
	 /usr/bin/weston-launch
  fi' >> /home/alarm/.bashrc
}

conf_environment() {
  cp ../files/environment /home/alarm/.environment
  chown alarm:alarm /home/alarm/.environment
}

conf_install_node() {
  su -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash' - alarm
  sudo pacman -S --needed --noconfirm npm nodejs
  su -c 'mkdir -p /home/alarm/.npm-packages/bin' - alarm
  su -c 'npm config set prefix "~/.npm-packages"' - alarm
  su -c 'npm install express' - alarm
  echo '
  # npm and nodejs global modules
  export PATH="$PATH:$HOME/.npm-packages/bin"
  export NODE_PATH="$NODE_PATH:$HOME/.npm-packages/lib/node_modules"
  ' >> .bashrc
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
  chown alarm:alarm .launcher
  chmod +x .launcher
}

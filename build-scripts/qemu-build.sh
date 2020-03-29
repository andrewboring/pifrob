# Grab the development stuff if needed
sudo pacman -S --needed base-devel
# Get the stuff for qemu-user-static
git clone https://aur.archlinux.org/qemu-user-static.git
git clone https://aur.archlinux.org/glib2-static.git
git clone https://aur.archlinux.org/pcre-static.git

# Build PCRE
cd pcre-static && gpg --recv-keys 9766E084FB0F43D8 && makepkg -s && cd ..

# Build glib2
cd glib2-static && makepkg -s && cd ..

# Build qemu-user-static
cd qemu-user-static && gpg --recv-keys CEACC9E15534EBABB82D3FA03353C9CEF108B584 && makepkg -s && cd ..

sudo pacman -U pcre-static/pcre-static-8.43-1-x86_64.pkg.tar.xz glib2-static/glib2-static-2.62.3-1-x86_64.pkg.tar.xz
sudo pacman -U qemu-user-static/qemu-user-static-4.2.0-1-x86_64.pkg.tar.xz

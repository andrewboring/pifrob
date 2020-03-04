#!/bin/sh

# Usage:
#   setup.sh [platform]
# setup.sh          # autodetect
# setup.sh armv7l   # specify armv7l
# setup.sh aarch64  # specify aarch64
# setup.sh x64		# specify 64-bit Intel-compatible proc


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

source install-common

case $PLATFORM in
  armv7l)
    source install-armv7l
    init_system
    conf_system
    conf_bootconfig_armv7l
    conf_user
    echo "All done. Rebooting now."
    reboot
    ;;
  armv7l)
    source install-aarch64
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

# - conf_user
#   - conf_init_app
#   - conf_sudo
#   - conf_environment
#   - conf_weston
#   - conf_hushlogin
#   - conf_install_launcher
# - conf_bootconfig_armv7 or conf_bootconfig_aarch64
# reboot

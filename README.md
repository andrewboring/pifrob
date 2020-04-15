PiFrob- A Raspberry Pi-based kiosk / application development environment.


This was originally derived from a BENJA (Bootable Electron Node JS Application) image that has been customized for a specific purpose. BENJA was an abandoned project at the time, so I derived this to update and manage it. 

Currently, this provides a setup script that builds an image for the RPi 2 and RPi 3 series, using the ARMv7 chip from Broadcom. 

Current Features:
  - Based on Arch Linux ARM
  - Hardware-accelerated Weston/Wayland with DRM and DISPMANX
    - Xwayland for legacy X application support
  - Development environments/frameworks:
    - NodeJS/Electron/Express
 
[Future] Features:
  - Additional Development environments/frameworks:
    - Python/Flask frameworks
  - System configuration
    - Graphical interface for small projects
    - API-based configuration for larger projects
    - Optional Datafrob integration for management at-scale
  - Analytics Support
	- Stats, logs, and data collection.

== Releases ==

== Build ==

Two ways to build it yourself: 
 1. Clone repo and run build-scripts/setup/scripts/setup on fresh Arch Linux Arm installation directly on a Raspberry Pi. 
 2. Use the included Vagrant file to build the image in a local virtual machine.

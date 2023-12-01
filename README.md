# devona-libs - Device specific post-installation routines

This repo contains routines used for first-boot setup and maintenance work, e.g. kernel updates, bootloader updates and firmware updates.

## Standard (RFC)

### Packaging

- The scripts should be packaged separately for each class of devices.
- The folder separating each class specific scrpts should be removed, for example:
  `/rpi/lib.bash` should be `/lib.bash`.

### On the first boot

- `first-boot.d` contains various custom setup scripts for first boot setup.
- `first-boot` should run the hook scripts installed in a designated location sequentially, e.g. `/usr/lib/devena-lib/first-boot.d`.

### Future maintenance

#### Kernel updates

- `kernel-update.d` contains custom “hooks” for kernel update procedure customization.
- The hooks should be sourced by kernel's postinst script.

#### Firmware-updates

- Firmware updates should be trigged on the postinst stage of the respective firmware package update.
- The only thing defined in this repository are resuable routines, which reduces complexity of the postinst script.
- `lib.bash` contains various routines used by the scripts above, e.g. mounting a specific partition.

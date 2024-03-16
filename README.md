# Advanced Reboot Plasmoid for Plasma 6

Simple Plasmoid for KDE Plasma 6 that lists the bootloader entries from systemd-boot/bootctl.
This allows you to quickly reboot into Windows, the EFI or bootloader menu, other distributions and EFI programs...

## Requirements

- UEFI system only
- systemd-boot (bootctl) bootloader
- systemd & logind

This will NOT work for non-systemd systems and other bootloaders (GRUB, rEFInd...)

## Roadmap

- [ ] Better appearance
- [?] French translation (broken for now)
- [ ] Custom icons
- [x] Detect if requirements are really met and warn the user/disable the feature if not
- [x] Dynamically get and list all the bootloader entries
- [?] Ability to configure visibility of all entries (done for EFI/Bootloader menu entries)

## Bugs?

- If the reboot is cancelled (because of inhibitors or open documents), the flags remain set. This means next reboot will still honor the choice made previously.

## License

Mozilla Public License 2.0

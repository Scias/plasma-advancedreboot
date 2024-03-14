# Advanced Reboot Plasmoid for Plasma 6

Extremely simple Plasmoid for KDE Plasma 6 that allows you to quickly reboot into Windows or to your motherboard's EFI menu.

## Requirements

- UEFI system only
- Windows dualboot install (for the reboot to Windows feature)
- systemd-boot bootloader
- systemd & logind

This will NOT work on non-systemd systems and other bootloaders (GRUB, rEFInd...)

## Roadmap

- [ ] Better appeareance
- [ ] French translation
- [ ] Custom icons
- [ ] Detect if requirements are really met and warn the user/disable the feature if not
- [ ] Dynamically get and list all the bootloader entries
- [x] Ability to configure visibility of the items

## Bugs?

- If the reboot is cancelled (because of inhibitors or open documents), the reboot to efi/windows flag remains set, so the next reboot will still honor that previous choice. This also makes it possible to cumulate both EFI and Windows booting for the next reboot.

## License

Mozilla Public License 2.0

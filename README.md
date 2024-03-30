# Advanced Reboot Plasmoid for Plasma 6

Simple Plasmoid for KDE Plasma 6 that lists the bootloader entries from systemd-boot/bootctl.  
This allows you to quickly reboot into Windows, the EFI or bootloader menu, other distributions and EFI programs...

## Requirements

- UEFI system only
- systemd >= 251
- systemd-boot (bootctl) bootloader

**Other bootloaders (GRUB/rEFInd...) and non-systemd systems are NOT supported!**

## Troubleshooting

In case of missing or unavailable entries, a "debugging information" panel with detailed information and logs is available in the configuration window of this plasmoid in order to help with troubleshooting.  
On most distributions, the root password is needed to get detailed boot entries information. This is only requested once and subsequent times will reuse the existing saved entries (unless they change).  
A few distributions like OpenSUSE don't allow the unpriviledged user to set the next boot entry. They are not supported (yet).

## Tested on

- ✅ **Archlinux**
- ✅ **Endeavour OS**
- ✅ **Fedora KDE (Rawhide)**
- 🚫 **KDE Neon (based on Ubuntu 22.04)** - systemd/bootctl version is too old
- 🚫 **OpenSUSE Tumbleweed** - busctl requires root for setting bootnext

## Translations

- [X] French
- [X] Dutch (by Heimen Stoffels)

If you wish to contribute your own translation, a template.pot file is available in the translate folder.

## Roadmap / TODO

- [ ] Improve look and feel
- [X] Translation support
- [X] Custom icons
- [X] Detect if requirements are really met and warn the user/disable the feature if not
- [X] Dynamically get and list all the bootloader entries
- [X] Ability to tweak visibility of every entry
- [X] Ability to just set the flag without rebooting immediately
- [X] Better error detection and reporting (0.45)
- [X] Ask for root to get the initial entry list for the distros that hide the ESP by default (0.5)
- [ ] Show detailed entry info/metadata (0.6)
- [ ] Show which entry is currently the active one (0.6x)
- [ ] Show which entry has been set for next boot (0.6x)
- [ ] Allow customisation of entry names, logos and order (0.7)

## FAQ

- Why not support GRUB-EFI or rEFInd?

Unlike sdboot, they do not offer easy, non-hacky ways for unpriviledged users to set the next entry to boot, nor a command or API to get a clean boot entries list to begin with.

- Why not support efibootmgr?

efibootmgr only lists or manages the EFI boot manager entries, which is far to be exhaustive as by default only the top level bootloaders (such as grub) may register there as opposed to individual distribution entries. It also doesn't show any detailed name or metadata, on top of the same issues also shared by GRUB and rEFInd.

## License

Mozilla Public License 2.0

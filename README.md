# Advanced Reboot Plasmoid for Plasma 6

Simple Plasmoid for KDE Plasma 6 that lists the bootloader entries from systemd-boot/bootctl.
This allows you to quickly reboot into Windows, the EFI or bootloader menu, other distributions and EFI programs...

## Requirements

- UEFI system only
- systemd-boot (bootctl) bootloader
- systemd & logind

**Other bootloaders (GRUB/rEFInd...) and non-systemd systems are NOT supported!**

## Roadmap / TODO

- [ ] Better appearance
- [X] Translation support
- [X] Custom icons
- [X] Detect if requirements are really met and warn the user/disable the feature if not
- [X] Dynamically get and list all the bootloader entries
- [ ] Ability to tweak visibility of every entry
- [ ] Show which entry is currently the active one
- [ ] Ability to just set the flag without rebooting immediately (and show which entry is set)

## Tested on

✅ **Archlinux** - Works out of the box
🟨 **Endeavour OS** - See Troubleshooting #1
🟨 **Fedora** - See Troubleshooting #1
🟨 **Ubuntu / Mint** - See Troubleshooting #1
🚫 **OpenSUSE** - See Troubleshooting #2

## Translations

- [X] French
- [X] Dutch (by Heimen Stoffels)

If you wish to contribute your own translation, a template.pot file is available in the translate folder.

## Bugs

- If the reboot is cancelled (because of inhibitors or open documents), the flags remain set. This means next reboot will still honor the choice made previously.
- This will not work if sudo/root is needed for dbus or bootctl interaction. (eg: OpenSUSE)

## Troubleshooting

In addition to the requirements above, certain other criterias must be met in order for this plasmoid to work. Unfortunately distributions do things differently by default.
If despite meeting the above requirements :

- No entries are listed (applet can't work error) : Check point 1 below.
- Entries are listed but it doesn't reboot to the chosen entry (reboots normally instead) : Check point 2 below

**1. The ESP (/boot/efi or /efi) must be user-readable.**

To check this, run "bootctl list" as the user. If you get a permissions error, you have to edit your ESP's fstab options line in /etc/fstab.
Edit the fmask and dmask values to 0022 so that the line looks like this:
```
UUID=xxxxx  /efi   vfat    ...,fmask=0022,dmask=0022,...
```
Reboot or remount the partition.

**2. The logind D-Bus methods must be user-accessible**

For now there's no easy solution I know for this. One possible way would be to ask for sudo priviledges (via pkexec) when choosing an entry which in my opinion is a terrible workaround...

## License

Mozilla Public License 2.0

import QtQuick

import org.kde.plasma.private.sessions
import org.kde.plasma.plasma5support as Plasma5Support

Item {

    readonly property string cmdGetEntries: "bootctl list --json=short"

    readonly property string cmdPre: "qdbus6 --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager."

    readonly property string cmdSetEfi: "SetRebootToFirmwareSetup"
    readonly property string cmdSetMenu: "SetRebootToBootLoaderMenu"
    readonly property string cmdSetEntry: "SetRebootToBootLoaderEntry"

    readonly property string cmdCheckEfi: "CanRebootToFirmwareSetup"
    readonly property string cmdCheckCustom: "CanRebootToBootLoaderEntry"
    readonly property string cmdCheckMenu: "CanRebootToBootLoaderMenu"

    readonly property var ignoreEntries: ["auto-reboot-to-firmware-setup"]
    readonly property var systemEntries: ["auto-efi-shell", "bootloader-menu"]

    readonly property string defaultIcon: "image-rotate-right-symbolic"
    readonly property var iconMap: {
        "windows" : "windows",
        "osx" : "apple",
        "memtest" : "memtest",
        "arch-linux" : "archlinux",
        "firmware-setup" : "settings",
        "efi-shell" : "shell",
        "bootloader-menu" : "menu",
    }

    property bool canEntry: false
    property bool canMenu: false
    property bool canEfi: false

    property var bootEntries: ListModel { }
    
    SessionManagement {
        id: session
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: (cmd, data) => {
            const stdout = data["stdout"]

            if (cmd == cmdGetEntries) {
                const rawEntries = JSON.parse(stdout)
                for (const entry of rawEntries) {
                    if (!ignoreEntries.includes(entry.id)) {
                        bootEntries.append(mapEntry(entry.id, entry.showTitle))
                    }
                }
            }
            else {
                if (cmd.includes(cmdCheckCustom)) {
                    canEntry = true
                }
                else if (stdout == "yes\n") {
                    if (cmd.includes(cmdCheckMenu)) {
                        bootEntries.append(mapEntry("bootloader-menu", "Bootloader Menu"))
                        canMenu = true
                    }
                    else if (cmd.includes(cmdCheckEfi)) {
                        bootEntries.append(mapEntry("firmware-setup", "Firmware Interface"))
                        canEfi = true
                    }
                }
            }
            disconnectSource(cmd)

        }

        function exec(cmd) {
            if (cmd) connectSource(cmd)
        }

    }

    function mapEntry(id, title) {
        let bIcon = defaultIcon
        let system = systemEntries.includes(id)
        let cmd

        if (id == "bootloader-menu") cmd = cmdSetMenu + " true"
        else if (id == "firmware-setup") cmd = cmdSetEfi + " true"
        else cmd = cmdSetEntry + " " + id

        for (const key in iconMap) {
            if (id.includes(key)) {
                bIcon = Qt.resolvedUrl("../../assets/icons/" + iconMap[key] + ".svg")
                break
            }
        }

        return ({
            id: id,
            system: system,
            title: title,
            fullTitle: title,
            bIcon: bIcon,
            cmd: cmd,
            enabled: true,
        })

    }

    function doChecks() {
        // TODO: check qdbus/bootctl better and abort if not good
        executable.exec(cmdPre + cmdCheckEfi)
        executable.exec(cmdPre + cmdCheckMenu)
        executable.exec(cmdPre + cmdCheckCustom)
    }

    function getEntries() {
        executable.exec(cmdGetEntries)
    }

    function bootEntry(cmdEnd) {
        executable.exec(cmdPre + cmdEnd)
        session["requestReboot"](0)
    }


}

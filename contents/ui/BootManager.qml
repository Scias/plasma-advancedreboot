import QtQuick

import org.kde.plasma.private.sessions
import org.kde.plasma.plasma5support as Plasma5Support

Item {

    readonly property string cmdGetEntries: "bootctl list --json=short"

    readonly property string cmdPre: "qdbus --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager."

    readonly property string cmdSetEfi: "SetRebootToFirmwareSetup"
    readonly property string cmdSetMenu: "SetRebootToBootLoaderMenu"
    readonly property string cmdSetEntry: "SetRebootToBootLoaderEntry"

    readonly property string cmdCheckEfi: "CanRebootToFirmwareSetup"
    readonly property string cmdCheckCustom: "CanRebootToBootLoaderEntry"
    readonly property string cmdCheckMenu: "CanRebootToBootLoaderMenu"

    readonly property var ignoreEntries: ["auto-reboot-to-firmware-setup"]

    readonly property string defaultIcon: "image-rotate-right-symbolic"
    readonly property var defaultIconMap: {
        "windows" : "im-msn",
        "osx" : "",
        "memtest" : "show-gpu-effects",
        "linux" : "preferences-system-linux"
    }

    property bool canEfi: false
    property bool canEntry: false
    property bool canMenu: false
    
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
                    if (!ignoreEntries.includes(entry.id) && entry.isSelected != true) {
                        bootEntries.append(mapEntry(entry))
                    }
                }
            }
            else if (cmd.includes(cmdCheckEfi)) {
                if (stdout == "yes\n") canEfi = true
            }
            else if (cmd.includes(cmdCheckMenu)) {
                if (stdout == "yes\n") canMenu = true
            }
            else if (cmd.includes(cmdCheckCustom)) {
                if (stdout == "yes\n") canEntry = true
            }

            disconnectSource(cmd)
        }

        function exec(cmd) {
            if (cmd) connectSource(cmd)
        }

    }

    function mapEntry(entry) {
        let icon = defaultIcon
        for (const key in defaultIconMap) {
            if (entry.id.includes(key)) {
                icon = defaultIconMap[key]
                break
            }
        }
        return ({
            id: entry.id,
            title: entry.title,
            showTitle: entry.showTitle,
            icon: icon,
        })
    }

    function doChecks() {
        executable.exec(cmdPre + cmdCheckEfi)
        executable.exec(cmdPre + cmdCheckMenu)
        executable.exec(cmdPre + cmdCheckCustom)
    }

    function getEntries() {
        executable.exec(cmdGetEntries)
    }

    function bootToEfi() {
        executable.exec(cmdPre + cmdSetEfi + " true")
        session["requestReboot"](0)
    }

    function bootToMenu() {
        executable.exec(cmdPre + cmdSetMenu + " 0")
        session["requestReboot"](0)
    }

    function bootToEntry(entry) {
        executable.exec(cmdPre + cmdSetEntry + " " + entry)
        session["requestReboot"](0)
    }


}

import QtQuick

import org.kde.plasma.private.sessions
import org.kde.plasma.plasma5support as Plasma5Support

Item {

    // TODO: 0.5 / sudo
    //property bool requiresRoot: false
    readonly property string cmdSudo: "pkexec "

    readonly property int minVersion: 251 // Minimum required systemd version
    readonly property string cmdDbusPre: "busctl"
    readonly property string cmdSdboot: "bootctl"
    readonly property string cmdDbusCheck: cmdDbusPre + " --version"
    readonly property string cmdSdbootCheck: cmdSdboot + " --version"
    readonly property string cmdDbusPath: "org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager"

    readonly property string cmdGetEntriesFull: cmdSdboot + " list --json=short --no-pager"
    readonly property string cmdGetEntriesID: cmdDbusPre + " get-property " + cmdDbusPath + " BootLoaderEntries --json=short"

    readonly property string cmdCheckEfi: cmdDbusPre + " call " + cmdDbusPath + " CanRebootToFirmwareSetup --json=short"
    readonly property string cmdCheckCustom: cmdDbusPre + " call " + cmdDbusPath + " CanRebootToBootLoaderEntry --json=short"
    readonly property string cmdCheckMenu: cmdDbusPre + " call " + cmdDbusPath + " CanRebootToBootLoaderMenu --json=short"

    readonly property string cmdSetEfi: cmdDbusPre + " call " + cmdDbusPath + " SetRebootToFirmwareSetup b true" 
    readonly property string cmdSetMenu: cmdDbusPre + " call " + cmdDbusPath + " SetRebootToBootLoaderMenu t 0"
    readonly property string cmdSetEntry: cmdDbusPre + " call " + cmdDbusPath + " SetRebootToBootLoaderEntry s "

    readonly property var ignoreEntries: ["auto-reboot-to-firmware-setup"]
    //TODO: sections
    //readonly property var systemEntries: ["auto-efi-shell", "bootloader-menu"]

    readonly property string defaultIcon: "default"
    readonly property var iconMap: {
        "Windows" : "windows",
        "Mac OS" : "apple",
        "Memtest" : "memtest",
        "Arch Linux" : "archlinux",
        "Endeavour" : "endeavour",
        "EFI Shell" : "shell",
        "Fedora" : "fedora",
        "Ubuntu" : "ubuntu",
        "SUSE" : "suse",
        "Debian" : "debian",
        "Mint" : "mint",
        "Gentoo" : "gentoo",
        "Manjaro" : "manjaro",
        "Linux" : "linux",
    }

    property var busctlOK: null
    property var bootctlOK: null
    property var canEntry: null
    property var canMenu: null
    property var canEfi: null
    property var gotEntries: null
    property bool reusedConfig: false

    enum State {
        ReqPass,
        GotEntries,
        Ready,
        Error,
        RootRequired
    }
    property int step: -1

    property var bootEntries: []
    
    SessionManagement {
        id: session
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        
        onNewData: (cmd, data) => {
            const stdout = data["stdout"]
            const stderr = data["stderr"]

            disconnectSource(cmd)

            if (cmd.includes("SetReboot")) {
                return
            }

            if (cmd == cmdDbusCheck) {
                if (stdout && !stderr) {
                    const resp = stdout.split(" ")
                    busctlOK = parseInt(resp[1]) >= minVersion
                } else busctlOK = false
            }
            else if (cmd == cmdSdbootCheck) {
                // Assume bootctl version == busctl version
                bootctlOK = !stderr
            }
            else {
                let json
                try { json = JSON.parse(stdout) }
                catch (err) {
                    if (stderr.includes("Permission")) {
                        alog("Root is required to get bootctl entries - Prompting user")
                        step = BootManager.RootRequired
                        return
                    }
                    else {
                        alog("Could not parse bootctl entries: " + err)
                        gotEntries = false
                        step = BootManager.GotEntries
                    }
                }
                if (cmd == cmdCheckCustom) {
                    canEntry = json.data == "yes"
                    alog("This system can reboot to any entry: " + canEntry)
                    if (canEntry) getEntriesID()
                    else step = BootManager.GotEntries
                }
                else if (cmd == cmdCheckMenu) {
                    canMenu = json.data == "yes"
                    alog("This system can reboot to the bootloader menu: " + canMenu)
                    if (canMenu) mapEfiMenu("bootloader-menu")
                }
                else if (cmd == cmdCheckEfi) {
                    canEfi = json.data == "yes"
                    alog("This system can reboot to the firmware setup: " + canEfi)
                    if (canEfi) mapEfiMenu("firmware-setup")
                }
                else if (cmd == cmdGetEntriesID) {
                    let entriesID = JSON.stringify(json.data)

                    if (!plasmoid.configuration.entriesID || !plasmoid.configuration.savedEntries || plasmoid.configuration.entriesID != entriesID) {
                        alog("No saved entries were found or they have changed")
                        plasmoid.configuration.entriesID = entriesID
                        getEntriesFull(false)
                    }
                    else {
                        alog("Existing saved entries were found and they didn't change")
                        getEntriesSaved()
                        step = BootManager.GotEntries
                        gotEntries = true
                    }
                }
                else if (cmd.includes(cmdGetEntriesFull) && step != BootManager.GotEntries) {
                    mapAllEntries(json)
                    step = BootManager.GotEntries
                    gotEntries = true
                    alog("Parsed new bootctl entries")
                }
            }

            if (step === -1) {
                if (busctlOK && bootctlOK) {
                    alog("The systemd and bootctl requirements seem met")
                    step = BootManager.ReqPass
                    getAbilities()
                }
                else if (busctlOK === false || bootctlOK === false) {
                    alog("The systemd and/or bootctl requirements are NOT met - Aborting")
                    step = BootManager.Error
                }
            }

            if (step === BootManager.GotEntries) finish(false)

        }

        function exec(cmd) {
            if (cmd) connectSource(cmd)
        }

    }

    function initialize() {
        alog("Checking base requirements...")
        executable.exec(cmdDbusCheck)
        executable.exec(cmdSdbootCheck)
    }

    function getAbilities() {
        alog("Querying system reboot capabilities...")
        executable.exec(cmdCheckEfi)
        executable.exec(cmdCheckMenu)
        executable.exec(cmdCheckCustom)
    }

    function getEntriesID() {
        alog("Getting boot entries IDs to compare with the saved ones...")
        executable.exec(cmdGetEntriesID)
    }

    function getEntriesSaved() {
        alog("Reusing saved bootctl entries")
        try {
            bootEntries = JSON.parse(plasmoid.configuration.savedEntries)
        } 
        catch (err) {
            alog("Could not restore saved bootctl entries - Getting fresh ones instead")
            getEntriesFull(false)
            return
        }
        reusedConfig = true
    }

    function getEntriesFull(root) {
        alog("Attempting to get fresh bootctl entries - root access: " + root)
        let cmd = cmdGetEntriesFull
        if (root) cmd = cmdSudo + cmd
        executable.exec(cmd)
    }

    function mapEfiMenu(id) {
        bootEntries.push({
            id: id,
            fullTitle: id == "firmware-setup" ? i18n("Firmware Setup") : i18n("Bootloader Menu"),
            bIcon: id == "firmware-setup" ? "settings" : "menu",
        })
    }

    function mapAllEntries(json) {
        for (const entry of json) {
            if (!ignoreEntries.includes(entry.id)) {
                let bIcon = defaultIcon

                for (const key in iconMap) {
                    if (entry.showTitle.includes(key)) {
                        bIcon = iconMap[key]
                        break
                    }
                }
                alog("Got \"" + entry.id + "\"")

                bootEntries.push({
                    id: entry.id,
                    fullTitle: entry.showTitle,
                    bIcon: bIcon,
                })
            }
        }
    }

    function finish(skip) {
        if (skip) step = BootManager.GotEntries

        if (step === BootManager.GotEntries && canEntry !== null && canEfi !== null && canMenu !== null) {
            if (!canEfi && !canMenu) {
                if (!canEntry || bootEntries.length == 0) {
                    step = BootManager.Error
                }
                else step = BootManager.Ready
            }
            else {
                step = BootManager.Ready
            }
        }

        if (step >= BootManager.Ready) {
            alog("Finished initialization - Error state: " + (step === BootManager.Error))
            if (!reusedConfig) plasmoid.configuration.savedEntries = JSON.stringify(bootEntries)
            loaded(step)

            // Ugly workaround to give info to config panels
            plasmoid.configuration.checkState = [busctlOK,bootctlOK,canEfi,canMenu,canEntry,gotEntries]
            plasmoid.configuration.appState = step
        }
    }

    function bootEntry(id) {
        let cmd
        if (id == "firmware-setup") cmd = cmdSetEfi
        else if (id == "bootloader-menu") cmd = cmdSetMenu
        else cmd = cmdSetEntry + id
        alog("Setting reboot to entry: " + id + " - Command: " + cmd)
        executable.exec(cmd)
        if (plasmoid.configuration.rebootMode != 2) session["requestReboot"](plasmoid.configuration.rebootMode)
    }

    function alog(msg) {
        plasmoid.configuration.appLog = plasmoid.configuration.appLog.concat([msg]) // Workaround
        console.log("advancedreboot: " + msg)
    }

    signal loaded(int step)

}

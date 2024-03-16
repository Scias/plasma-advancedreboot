import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

PlasmaExtras.Representation {

    implicitHeight: column.implicitHeight + header.implicitHeight + 10
    implicitWidth: column.implicitWidth

    spacing: 5

    header: PlasmaExtras.PlasmoidHeading {
        contentItem: Kirigami.Heading {
            horizontalAlignment: Text.AlignHCenter
            text: i18n("Reboot to...")
        }
    }

    ColumnLayout {
      id: column

      PlasmaComponents.ToolButton {
        Layout.fillWidth: true
        icon.name: "view-list-symbolic"
        text: i18n("Bootloader Menu")
        visible: plasmoid.configuration.showMenu
        onClicked: bootmgr.bootToMenu()
        enabled: bootmgr.canMenu
      }

      PlasmaComponents.ToolButton {
        Layout.fillWidth: true
        icon.name: "settings-configure"
        text: i18n("EFI")
        visible: plasmoid.configuration.showEfi
        onClicked: bootmgr.bootToEfi()
        enabled: bootmgr.canEfi
      }

      Repeater {
        model: bootEntries
        PlasmaComponents.ToolButton {
          required property var modelData
          Layout.fillWidth: true
          icon.name: modelData.icon
          text: modelData.showTitle
          onClicked: bootmgr.bootToEntry(modelData.id)
        }
      }

      Kirigami.InlineMessage {
        width: 300
        text: i18n("This applet cannot work on this system.\nCheck that the system is booted in UEFI mode and that systemd, systemd-boot are used and configured properly.")
        type: Kirigami.MessageType.Error
        visible: !bootEntries.count > 0 && !bootmgr.canEfi && !bootmgr.canMenu && !bootmgr.canEntry
      }

      Kirigami.InlineMessage {
        width: 300
        text: i18n("All the possible entries are currently hidden as per this applet settings.")
        type: Kirigami.MessageType.Warning
        visible: !bootEntries.count > 0 && !plasmoid.configuration.showEfi && !plasmoid.configuration.showMenu
      }


    }
}

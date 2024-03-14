import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.private.sessions
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
  id: root

  readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
  preferredRepresentation: compactRepresentation

  width: Kirigami.Units.gridUnit * 4
  height: Kirigami.Units.gridUnit * 4

  switchWidth: Kirigami.Units.gridUnit * 10
  switchHeight: Kirigami.Units.gridUnit * 4

  SessionManagement {
    id: session
  }

  Plasma5Support.DataSource {
    id: executable
    engine: "executable"
    connectedSources: []

    function exec(cmd) {
      if (cmd) {
        connectSource(cmd)
      }
    }
    signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
  }

  compactRepresentation: Item {
    id: compactRoot

    PlasmaComponents.ToolButton {
      anchors.fill: parent
      icon.name: "view-refresh"
      onClicked: root.expanded = !root.expanded
    }
  }

  fullRepresentation: Item {
        id: fullRoot

        implicitHeight: column.implicitHeight
        implicitWidth: column.implicitWidth

        ColumnLayout {
          id: column

          PlasmaComponents.ToolButton {
            Layout.fillWidth: true
            icon.name: "im-msn"
            text: i18n("Reboot to Windows")
            onClicked: toWindows()
            visible: plasmoid.configuration.showWindows
          }

          PlasmaComponents.ToolButton {
            Layout.fillWidth: true
            icon.name: "show-gpu-effects"
            text: i18n("Reboot to EFI")
            onClicked: toEfi()
            visible: plasmoid.configuration.showEfi
          }

          PlasmaComponents.Label {
            padding: 5
            text: i18n("All entries are hidden - Please enable at least one in settings")
            visible: ! (plasmoid.configuration.showEfi || plasmoid.configuration.showWindows)
          }

        }

  }

  function toWindows() {
    executable.exec("qdbus --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.SetRebootToBootLoaderEntry auto-windows")
    session["requestReboot"](0)
  }

  function toEfi()  {
    executable.exec("qdbus --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.SetRebootToFirmwareSetup true")
    session["requestReboot"](0)
  }

}

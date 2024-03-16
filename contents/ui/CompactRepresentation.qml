import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {

  width: Kirigami.Units.gridUnit * 4
  height: Kirigami.Units.gridUnit * 4

  PlasmaComponents.ToolButton {
    anchors.fill: parent
    icon.name: "view-refresh"
    onClicked: root.expanded = !root.expanded
  }

}

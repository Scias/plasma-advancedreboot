import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

PlasmaExtras.Representation {

  property bool eligible: false

  implicitWidth: Kirigami.Units.gridUnit * 20
  implicitHeight: (eligible ? mainList.height : notEligibleMsg.height) + header.height + Kirigami.Units.largeSpacing

  Layout.preferredWidth: implicitWidth
  Layout.minimumWidth: implicitWidth
  Layout.preferredHeight: implicitHeight
  Layout.maximumHeight: implicitHeight
  Layout.minimumHeight: implicitHeight

    header: PlasmaExtras.PlasmoidHeading {
      contentItem: Kirigami.Heading {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: i18n("Reboot into...")
      }
    }

    ErrorMessage {
      id: notEligibleMsg
      sIcon: "dialog-error-symbolic"
      message: i18n("This applet cannot work on this system.\nPlease check that the system is booted in UEFI mode and that systemd, systemd-boot are used and configured properly.")
      show: !eligible
    }

    ListView {
      id: mainList
      visible: eligible

      anchors.verticalCenter: parent.verticalCenter

      interactive: false

      width: parent.width
      height: bootMgr.bootEntries.count > 0 ? contentHeight : noEntriesMsg.height

      spacing: Kirigami.Units.smallSpacing

      model: bootMgr.bootEntries

      delegate: PlasmaComponents.ItemDelegate {
        required property string cmd
        required property string bIcon
        required property string fullTitle
        width: parent.width
        contentItem: RowLayout {

          Layout.fillWidth: true

          Kirigami.Icon {
            source: bIcon
            color: Kirigami.Theme.colorSet
            smooth: true
            isMask: true
            scale: 0.8
          }

          PlasmaComponents.Label {
            Layout.fillWidth: true
            text: fullTitle
          }
        }
        onClicked: bootMgr.bootEntry(cmd)
    }

    ErrorMessage {
      id: noEntriesMsg
      sIcon: "dialog-warning-symbolic"
      message: i18n("No boot entries could be listed.\nPlease check this applet settings.")
      show: mainList.count == 0
      // TODO: add open configuration button
    }

    // TODO: sections
    /*section.property: "system"
    section.delegate: Kirigami.ListSectionHeader {
      width: parent.width
      label: section == 1 ? "System entries" : "Custom entries"
    }*/
  }
}

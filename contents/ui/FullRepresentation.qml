import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami
import org.kde.notification

// TODO: Trim long entries or make them scroll
// TODO: Put stuff inside parenthesis / kernel versions in a separate line below
PlasmaExtras.Representation {

  property var shownEntries: ListModel { }
  property var selectedEntry
  property bool busy: false

  implicitWidth: Kirigami.Units.gridUnit * 20
  implicitHeight: mainList.height + header.height + Kirigami.Units.largeSpacing

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

    ListView {
      id: mainList

      anchors.verticalCenter: parent.verticalCenter

      interactive: false

      width: parent.width
      height: shownEntries.count > 0 ? contentHeight : 300

      spacing: Kirigami.Units.smallSpacing

      model: shownEntries

      delegate: PlasmaComponents.ItemDelegate {
        required property string cmd
        required property string bIcon
        required property string fullTitle
        width: parent ? parent.width : 0 // BUG: Occasional error here
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
        onClicked: {
          root.expanded = !root.expanded
          selectedEntry = fullTitle
          myNotif.sendEvent()
          bootMgr.bootEntry(cmd)
        }
    }

    // TODO: sections
    /*section.property: "system"
    section.delegate: Kirigami.ListSectionHeader {
      width: parent.width
      label: section == 1 ? "System entries" : "Custom entries"
    }*/

    ErrorMessage {
      id: noEntriesMsg
      anchors.centerIn: parent
      sIcon: "dialog-warning-symbolic"
      message: i18n("No boot entries could be listed.\nPlease check this applet settings.")
      show: bootMgr.step === BootManager.Ready && shownEntries.count == 0 && !busy
      // TODO: add open configuration button
      //plasmoid.action("configure").trigger()
    }

    PlasmaComponents.BusyIndicator {
      implicitWidth: 150
      implicitHeight: 150
      anchors.centerIn: parent
      visible: bootMgr.step < BootManager.Ready || busy
    }

    ErrorMessage {
      id: notEligibleMsg
      anchors.centerIn: parent
      sIcon: "dialog-error-symbolic"
      message: i18n("This applet cannot work on this system.\nPlease check that the system is booted in UEFI mode and that systemd, systemd-boot are used and configured properly.")
      show: bootMgr.step === BootManager.Error
    }

    ErrorMessage {
      id: rootRequired
      anchors.centerIn: parent
      sIcon: "dialog-password-symbolic"
      message: i18n("Root access is required to get the full boot entries list.")
      show: bootMgr.step === BootManager.RootRequired
      action: Kirigami.Action {
        text: i18n("Retry as root")
        icon.name: "unlock-symbolic"
        onTriggered: bootMgr.getEntries(true)
      }
      PlasmaComponents.Button {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text: i18n("Ignore")
        icon.name: "errornext"
        onClicked: bootMgr.finish(true)
        visible: bootMgr.step === BootManager.RootRequired
      }
    }

  }

  Notification {
    id: myNotif
    componentName: "plasma_workspace"
    eventId: "warning"
    title: i18n("Advanced reboot")
    text: i18n("The entry <b>") + selectedEntry + i18n("</b> has been set for the next reboot.")
    iconName: "refreshstructure"
  }

  function buildModel(toHide, model) {
    busy = true
    shownEntries.clear()
    for (let i = 0; i < model.count; i++) {
      if (!toHide.includes(model.get(i).fullTitle)) {
        shownEntries.append(model.get(i))
      }
    }
    busy = false
  }

  Component.onCompleted: {
    if (bootMgr.step === BootManager.Ready) { 
      buildModel(plasmoid.configuration.hideEntries, bootMgr.bootEntries)
    }
  }

  Connections {
    target: bootMgr

    function onLoaded(signal) {
      if (signal === BootManager.Ready) { 
        buildModel(plasmoid.configuration.hideEntries, bootMgr.bootEntries)
      }
    }
  
  }

  Connections {
    target: plasmoid.configuration

    function onValueChanged(value) {
      if (bootMgr.step === BootManager.Ready && value == "hideEntries") buildModel(plasmoid.configuration.hideEntries, bootMgr.bootEntries)
    }
   }

}

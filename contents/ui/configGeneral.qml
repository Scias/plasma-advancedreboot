import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.kcmutils

SimpleKCM {
  id: mainconfig

  //property alias cfg_hiddenEntries: menu.checked
  //property alias cfg_showEfi: efi.checked

  BootManager { id: bootMgr }

  PlasmaComponents.ScrollView {
    anchors.fill: parent
    focus: true

    ListView {
                model: bootMgr.bootEntries
                delegate: Controls.SwitchDelegate {
                  required property string fullTitle
                    width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                    text: fullTitle + modelData
                }
            }


  }
}

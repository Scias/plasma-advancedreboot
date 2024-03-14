import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.kcmutils

SimpleKCM {
  id: mainconfig

  property alias cfg_showWindows: windows.checked
  property alias cfg_showEfi: efi.checked

  Kirigami.FormLayout {
    anchors.fill: parent

    PlasmaComponents.Switch {
      id: windows
      Kirigami.FormData.label: i18n("Show Windows entry")
    }

    PlasmaComponents.Switch {
      id: efi
      Kirigami.FormData.label: i18n("Show EFI entry")
    }
  }
}

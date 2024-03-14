import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Kirigami.FormLayout {
  id: config
  anchors.fill: parent

  property alias cfg_showWindows: windows.checked
  property alias cfg_showEfi: efi.checked


  PlasmaComponents.Switch {
    id: windows
    Kirigami.FormData.label: i18n("Show Windows entry")
  }

  PlasmaComponents.Switch {
    id: efi
    Kirigami.FormData.label: i18n("Show EFI entry")
  }

}

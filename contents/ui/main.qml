import QtQuick

import org.kde.plasma.plasmoid

PlasmoidItem {
  id: root

  preferredRepresentation: compactRepresentation

  ListModel { id: bootEntries }
  BootManager { id: bootmgr }

  compactRepresentation: CompactRepresentation { id: compact }
  fullRepresentation: FullRepresentation { id: full }

  Component.onCompleted: {
    bootmgr.doChecks()
    bootmgr.getEntries()
  }

}

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Item {
    property string sIcon
    property string message
    property bool show: false
    //property var action: null

    implicitWidth: parent.width

    Kirigami.PlaceholderMessage {
        id: err
        width: parent.width - Kirigami.Units.largeSpacing * 2
        anchors.centerIn: parent
        icon.name: sIcon
        text: message
        visible: show
        //TODO: Configure button - Help link
        //helpfulAction: action
    }
}

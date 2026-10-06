import QtQuick
import QtQuick.Layouts
import "../config"

// Botão de ação da central (bluetooth, desligar...). `danger: true` dá o
// tom avermelhado usado para ações destrutivas (desligar o PC).
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property bool danger: false
    signal clicked()

    Layout.preferredHeight: 40
    radius: Theme.radiusSmall
    color: danger
        ? (mouse.containsMouse ? Qt.rgba(0.90, 0.30, 0.30, 0.28) : Qt.rgba(0.90, 0.30, 0.30, 0.14))
        : (mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.05))

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6
        Text { text: root.icon; color: Theme.islandText; font.pixelSize: Theme.fontSize + 2 }
        Text {
            text: root.label
            visible: root.label.length > 0
            color: Theme.islandText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

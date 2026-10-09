import QtQuick
import QtQuick.Layouts
import "../config"

// Bloco base reutilizável para os widgets laterais: ícone + rótulo,
// com hover suave e clique opcional (usado para abrir menus).
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property var contentColor: Theme.islandText
    property bool showLabel: true
    property bool isClickable: false
    signal clicked()

    color: "transparent"
    implicitHeight: Config.pillHeight
    implicitWidth: content.implicitWidth + 5

//  Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 4

        Text {
            id: iconText
            text: root.icon
            color: contentColor
            font.pixelSize: Theme.fontSize + 2
            font.weight: mouseArea.containsMouse ? Font.Bold : Font.Normal
            // Caixa do ícone presa à altura do rótulo e centralizada:
            // glifos de outra fonte (ex. o emoji ⏱) têm métricas de
            // baseline diferentes e subiam para o topo da pílula.
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: labelText.implicitHeight
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: labelText
            text: root.label
            visible: root.showLabel && root.label.length > 0
            color: contentColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: mouseArea.containsMouse ? Font.Bold : Font.Normal
            Layout.alignment: Qt.AlignVCenter
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: isClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
    
}

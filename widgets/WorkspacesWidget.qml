import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../config"

// Indicador minimalista de workspaces (Hyprland): um ponto por workspace
// com janela aberta; o ativo vira uma "pílula" mais larga. Clique muda
// para o workspace correspondente.
RowLayout {
    id: root
    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: dot
            property var ws: modelData
            implicitWidth: ws.focused ? 16 : 6
            implicitHeight: 6
            radius: 3
            color: ws.focused ? Theme.islandText : Theme.islandSubtle
            opacity: mouse.containsMouse ? 1.0 : 0.8
            Layout.alignment: Qt.AlignVCenter

            Behavior on implicitWidth { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutExpo } }
            Behavior on color        { ColorAnimation   { duration: Theme.animFast } }
            Behavior on opacity      { NumberAnimation { duration: Theme.animFast } }

            MouseArea {
                id: mouse
                anchors.fill: parent
                anchors.margins: -3
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: dot.ws.activate()
            }
        }
    }
}

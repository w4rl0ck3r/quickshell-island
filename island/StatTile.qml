import QtQuick
import QtQuick.Layouts
import "../config"

// Bloco de estatística clicável usado na central (memória, cpu, modos...).
// Sem onClicked conectado, continua clicável visualmente mas sem ação —
// prefira showAction: false nesse caso para não sugerir interação à toa.
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property string value: ""
    property bool showAction: true
    signal clicked()

    Layout.preferredHeight: 46
    radius: Theme.radiusSmall
    color: (showAction && mouse.containsMouse) ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 1

        RowLayout {
            spacing: 4
            Text { text: root.icon; color: Theme.islandSubtle; font.pixelSize: Theme.fontSize - 1 }
            Text {
                text: root.label
                color: Theme.islandSubtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Text {
            text: root.value
            color: Theme.islandText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.showAction
        hoverEnabled: true
        cursorShape: root.showAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}

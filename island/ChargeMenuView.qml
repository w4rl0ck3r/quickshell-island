import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"
import "../menus"

// Modo "charge" da ilha: escolhe o modo de carregamento da bateria.
// Linhas na linguagem dos cards do CentralView (dashCard sobre o
// corpo islandBg da ilha). Clique aplica e fecha; Esc fecha.
Item {
    id: root

    // Esc local (a barra tem foco: o menu sempre abre por clique).
    Shortcut { sequence: "Escape"; onActivated: ChargeModeMenu.close() }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Text {
            text: "Modo de carregamento"
            color: Theme.dashText
            font.bold: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Repeater {
            model: ChargeModeMenu.options

            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: mouse.containsMouse ? Theme.dashCardHover : Theme.dashCard

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: modelData.label
                        color: Theme.dashText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: modelData.value === Battery.currentMode
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: modelData.value === Battery.currentMode
                        text: "✓"
                        color: Theme.dashAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        ChargeModeMenu.apply(modelData.value)
                        ChargeModeMenu.close()
                    }
                }
            }
        }
    }
}

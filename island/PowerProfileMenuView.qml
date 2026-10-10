import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"
import "../menus"

// Modo "powerprofile" da ilha: escolhe o perfil de energia.
// Só mostra os perfis que o daemon oferece; o ativo leva ✓.
// Clique aplica e fecha; Esc fecha.
Item {
    id: root

    // Esc local (a barra tem foco: o menu sempre abre por clique).
    Shortcut { sequence: "Escape"; onActivated: PowerProfileMenu.close() }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Text {
            text: "Perfil de energia"
            color: Theme.dashText
            font.bold: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Repeater {
            model: PowerProfileMenu.options

            delegate: Rectangle {
                visible: PowerProfileMenu.offered.indexOf(modelData.value) !== -1
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
                        font.bold: modelData.value === PowerProfileMenu.current
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: modelData.value === PowerProfileMenu.current
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
                        PowerProfileMenu.apply(modelData.value)
                        PowerProfileMenu.close()
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"
import "../menus"

// Modo "power" da ilha: trancar ou desligar (com confirmação inline).
// A confirmação usa o tick1s do Heartbeat — sem Timer próprio.
Item {
    id: root

    // Esc local (a barra tem foco: o menu sempre abre por clique).
    Shortcut { sequence: "Escape"; onActivated: PowerMenu.close() }

    // Desligar: 1º clique arma ("Confirmar?"), 2º executa; desarma em 3s.
    property bool armed: false
    property int armTicks: 0

    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick1s() {
            if (root.armed) {
                root.armTicks++
                if (root.armTicks >= 3) {
                    root.armed = false
                    root.armTicks = 0
                }
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 28

        ColumnLayout {
            spacing: 6

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 60
                height: 60
                radius: 30
                color: lockMouse.containsMouse ? Theme.dashCardHover : Theme.dashCard

                Text {
                    anchors.centerIn: parent
                    text: "🔒"
                    font.pixelSize: 24
                }

                MouseArea {
                    id: lockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: PowerMenu.lock()
                }
            }

            Text {
                text: "Trancar"
                color: Theme.dashText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                Layout.alignment: Qt.AlignHCenter
            }
        }

        ColumnLayout {
            spacing: 6

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 60
                height: 60
                radius: 30
                color: root.armed ? Theme.alert
                    : (powerMouse.containsMouse ? Theme.dashCardHover : Theme.dashCard)

                Text {
                    anchors.centerIn: parent
                    text: "⏻"
                    color: root.armed ? Theme.islandText : Theme.dashText
                    font.pixelSize: 24
                }

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.armed) {
                            root.armed = false
                            root.armTicks = 0
                            PowerMenu.shutdown()
                        } else {
                            root.armed = true
                            root.armTicks = 0
                        }
                    }
                }
            }

            Text {
                text: root.armed ? "Confirmar?" : "Desligar"
                color: root.armed ? Theme.alert : Theme.dashText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.bold: root.armed
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}

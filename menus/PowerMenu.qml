pragma Singleton
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../config"

// Menu de sistema: trancar a sessão ou desligar.
QtObject {
    id: root
    property var barWindow: null

    property PopupWindow popup: PopupWindow {
        implicitWidth: 180
        implicitHeight: 96
        color: "transparent"
        visible: false
        grabFocus: true
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow ? (root.barWindow.width / 2 - implicitWidth / 2) : 0
        anchor.rect.y: Config.barHeight + 6

        Rectangle {
            anchors.fill: parent
            radius: Theme.radius
            color: Theme.base
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 52; height: 52; radius: 26
                        color: lockMouse.containsMouse ? Theme.hover : "transparent"
                        Text { anchors.centerIn: parent; text: "🔒"; font.pixelSize: 22 }
                        MouseArea {
                            id: lockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: { root.lock(); root.popup.visible = false }
                        }
                    }
                    Text {
                        text: "Trancar"; color: Theme.text; font.pixelSize: 11
                        font.family: Theme.fontFamily; Layout.alignment: Qt.AlignHCenter
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 52; height: 52; radius: 26
                        color: powerMouse.containsMouse ? Theme.hover : "transparent"
                        Text { anchors.centerIn: parent; text: "⏻"; font.pixelSize: 22 }
                        MouseArea {
                            id: powerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: { root.shutdown(); root.popup.visible = false }
                        }
                    }
                    Text {
                        text: "Desligar"; color: Theme.text; font.pixelSize: 11
                        font.family: Theme.fontFamily; Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }

    property Process lockProc: Process { command: ["sh", "-c", Config.lockCommand] }
    property Process shutdownProc: Process { command: ["sh", "-c", Config.shutdownCommand] }

    function lock() { lockProc.running = true }
    function shutdown() { shutdownProc.running = true }
    function toggle() { root.popup.visible = !root.popup.visible }
}

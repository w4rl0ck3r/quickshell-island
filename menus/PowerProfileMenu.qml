pragma Singleton
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../config"

// Menu de perfil de energia (performance/balanceado/economia) via
// power-profiles-daemon (`powerprofilesctl`).
QtObject {
    id: root
    property var barWindow: null

    readonly property var options: [
        { label: "🚀  Performance", value: "performance" },
        { label: "⚖  Balanceado", value: "balanced" },
        { label: "🌿  Economia", value: "power-saver" }
    ]

    property PopupWindow popup: PopupWindow {
        implicitWidth: 220
        implicitHeight: list.implicitHeight + 24
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

            ColumnLayout {
                id: list
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Text {
                    text: "Perfil de energia"
                    color: Theme.text
                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Repeater {
                    model: root.options
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        radius: Theme.radiusSmall
                        color: mouse.containsMouse ? Theme.hover : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.apply(modelData.value)
                                root.popup.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    property Process applyProc: Process { command: ["true"] }

    function apply(profile) {
        applyProc.command = ["powerprofilesctl", "set", profile]
        applyProc.running = true
    }

    function toggle() {
        root.popup.visible = !root.popup.visible
    }
}

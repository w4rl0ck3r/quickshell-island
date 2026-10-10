pragma Singleton
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../config"
import "../services"

// Menu de perfil de energia (performance/balanceado/economia) via
// power-profiles-daemon (`powerprofilesctl`).
// Requer o pacote instalado e o serviço ativo:
//   sudo pacman -S power-profiles-daemon && sudo systemctl enable --now power-profiles-daemon
QtObject {
    id: root
    property var barWindow: null

    readonly property var options: [
        { label: "🚀  Performance", value: "performance" },
        { label: "⚖  Balanceado", value: "balanced" },
        { label: "🌿  Economia", value: "power-saver" }
    ]

    // Perfil ativo no momento ("" = desconhecido).
    property string current: ""

    // Perfis que o daemon oferece. Padrão = os 3 canônicos; se o
    // `powerprofilesctl list` responder, restringe ao que o hardware
    // realmente suporta (ex. sem "performance" em muito notebook).
    property var offered: ["performance", "balanced", "power-saver"]
    property var _found: []

    property Process listProc: Process {
        command: ["powerprofilesctl", "list"]
        stdout: SplitParser {
            onRead: data => {
                const m = data.match(/^\s*\*?\s*(performance|balanced|power-saver)\s*:/)
                if (m && root._found.indexOf(m[1]) === -1)
                    root._found = root._found.concat([m[1]])
            }
        }
        onExited: code => {
            if (code === 0 && root._found.length > 0) root.offered = root._found
        }
    }

    property Process getProc: Process {
        command: ["powerprofilesctl", "get"]
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim()
                if (p.length > 0) root.current = p
            }
        }
    }

    function refresh() {
        if (!root.getProc.running) root.getProc.running = true
    }

    // Atualiza o perfil ao abrir e, com o menu aberto, a cada tick5s
    // (caso algo externo mude o perfil). Sem Timer próprio.
    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick5s() {
            if (root.popup.visible) root.refresh()
        }
    }

    Component.onCompleted: listProc.running = true

    property PopupWindow popup: PopupWindow {
        implicitWidth: 220
        implicitHeight: list.implicitHeight + 24
        color: "transparent"
        visible: false
        grabFocus: true
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow ? (root.barWindow.width / 2 - implicitWidth / 2) : 0
        anchor.rect.y: Config.barHeight + 6
        onVisibleChanged: if (visible) root.refresh()

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
                        visible: root.offered.indexOf(modelData.value) !== -1
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
                            font.bold: modelData.value === root.current
                        }

                        // Marca o perfil ativo no momento.
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: modelData.value === root.current
                            text: "✓"
                            color: Theme.ok
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
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
        // Re-lê o ativo (o tick5s corrige se o set ainda não aplicou).
        root.refresh()
    }

    function toggle() {
        root.popup.visible = !root.popup.visible
    }
}

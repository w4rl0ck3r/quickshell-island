pragma Singleton
import QtQuick
import Quickshell.Io
import "../services"

// Menu de perfil de energia (performance/balanceado/economia) via
// power-profiles-daemon (`powerprofilesctl`).
// O visual vive em island/PowerProfileMenuView.qml, como um modo da ilha
// (sem PopupWindow) — ver DynamicIsland.qml.
// Requer o pacote instalado e o serviço ativo:
//   sudo pacman -S power-profiles-daemon && sudo systemctl enable --now power-profiles-daemon
QtObject {
    id: root

    property bool open: false

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
            if (root.open) root.refresh()
        }
    }

    Component.onCompleted: listProc.running = true

    property Process applyProc: Process { command: ["true"] }

    function apply(profile) {
        applyProc.command = ["powerprofilesctl", "set", profile]
        applyProc.running = true
        // Re-lê o ativo (o tick5s corrige se o set ainda não aplicou).
        root.refresh()
    }

    function toggle() {
        if (!root.open) {
            ChargeModeMenu.close()
            PowerMenu.close()
            Wallpapers.close()
            root.refresh()
        }
        root.open = !root.open
    }

    function close() {
        root.open = false
    }
}

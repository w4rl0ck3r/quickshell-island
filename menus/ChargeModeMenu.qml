pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"
import "../services"

// Menu de modo de carregamento da bateria (fast/standard/long_life).
// O visual vive em island/ChargeMenuView.qml, como um modo da ilha
// (sem PopupWindow) — ver DynamicIsland.qml.
// ATENÇÃO: o comando real varia por fabricante — ajuste
// scripts/set-charge-mode.sh para o seu hardware (ver README).
QtObject {
    id: root

    property bool open: false

    readonly property var options: [
        { label: "⚡  Rápido",         value: "Fast" },
        { label: "🔋  Padrão",        value: "Standard" },
        { label: "🌱  Longa duração", value: "Long_Life" }
    ]

    property Process applyProc: Process { command: ["true"] }

    function apply(mode) {
        applyProc.command = ["sh", "-c", "sudo " + Config.chargeScriptPath + " " + mode]
        applyProc.running = true
    }

    function toggle() {
        if (!root.open) {
            PowerProfileMenu.close()
            PowerMenu.close()
            Wallpapers.close()
        }
        root.open = !root.open
    }

    function close() {
        root.open = false
    }
}

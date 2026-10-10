pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"
import "../services"
import "../services"

// Menu do sistema: trancar a sessão ou desligar.
// O visual vive em island/PowerMenuView.qml, como um modo da ilha
// (sem PopupWindow) — ver DynamicIsland.qml.
QtObject {
    id: root

    property bool open: false

    property Process lockProc: Process { command: ["sh", "-c", Config.lockCommand] }
    property Process shutdownProc: Process { command: ["sh", "-c", Config.shutdownCommand] }

    function lock() {
        lockProc.running = true
        root.close()
    }

    function shutdown() {
        shutdownProc.running = true
        root.close()
    }

    function toggle() {
        if (!root.open) {
            ChargeModeMenu.close()
            PowerProfileMenu.close()
            Wallpapers.close()
        }
        root.open = !root.open
    }

    function close() {
        root.open = false
    }
}

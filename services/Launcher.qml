pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"

// Dispara o rofi (tema próprio em rofi/theme.rasi) a partir da Dynamic
// Island, tanto por clique quanto pelo atalho global "search".
QtObject {
    property Process proc: Process {
        command: ["sh", "-c", Config.rofiCommand]
        onExited: proc.running = false
    }

    function launch() {
        proc.running = true
    }
}

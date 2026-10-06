pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"

// Serviço do seletor de wallpapers na Dynamic Island.
// Lista arquivos de Config.wallpapersDir (1x por open), filtra por
// `filter` e aplica via hyprpaper (hyprctl hyprpaper wallpaper).
QtObject {
    id: root

    property bool active: false
    property string filter: ""
    property var files: []
    property string lastError: ""

    // Suporta scroll com um texto vazio → mostra tudo.
    readonly property var shown: {
        if (!filter) return files
        const f = filter.toLowerCase()
        return files.filter(n => n.toLowerCase().includes(f))
    }

    property Process listProc: Process {
        command: ["sh", "-c", "ls -1 '" + Config.wallpapersDir + "'"]
        stdout: SplitParser {
            // SplitParser entrega UMA linha por onRead — acumula sem
            // sobrescrever, senão só o último arquivo sobrevive.
            onRead: data => {
                const l = data.trim()
                if (l.length > 0) root.files = root.files.concat([l])
            }
        }
    }

    property Process applyProc: Process {
        command: ["true"]
        stderr: SplitParser {
            onRead: data => root.lastError = data
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                errProc.command = ["notify-send", "-u", "critical", "Wallpaper",
                                   "Falhou (" + exitCode + "): " + root.lastError]
                errProc.running = true
            }
        }
    }

    property Process errProc: Process { command: ["true"] }

    function open() {
        root.filter = ""
        root.files = []
        root.active = true
        listProc.running = true
    }

    function close() {
        root.active = false
        root.filter = ""
    }

    function apply(fileName) {
        const path = Config.wallpapersDir + "/" + fileName
        applyProc.command = ["sh", "-c",
            "hyprctl hyprpaper wallpaper '" + Config.wallpaperMonitor + "," + path + ",cover'" +
            " && matugen image --mode smart --prefer saturation \"" + path + "\"" +
            " && hyprctl reload"
        ]
        applyProc.running = true
        close()
    }
}

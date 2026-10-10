pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config"
import "../menus"

// Serviço do seletor de wallpapers na Dynamic Island.
// Lista arquivos de Config.wallpapersDir (1x por open), filtra por
// `filter` e aplica via hyprpaper (hyprctl hyprpaper wallpaper).
// A seleção (`sel`) vive aqui — não na view — para que os atalhos
// alcancem sem foco na view.
//
// Teclado: as setas/Enter/Esc moram no submap `wallpaper` do Hyprland
// (binds.lua) — binds estáticos de teclas peladas comeriam as teclas
// no sistema todo. O picker entra no submap ao abrir e sai ao fechar,
// então fora dele as teclas passam normalmente pros apps.
QtObject {
    id: root

    property bool active: false
    property string filter: ""
    property var files: []
    property string lastError: ""

    property int sel: 0

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
        root.sel = 0
        root.active = true
        ChargeModeMenu.close()
        PowerProfileMenu.close()
        PowerMenu.close()
        // Entra no submap das teclas do picker (sai no close()).
        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.submap(\"wallpaper\")"])
        listProc.running = true
    }

    function close() {
        root.active = false
        root.filter = ""
        // Devolve as setas/Enter/Esc pros apps.
        Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.submap(\"reset\")"])
    }

    function nudge(d) {
        if (root.shown.length === 0) return
        root.sel = Math.max(0, Math.min(root.shown.length - 1, root.sel + d))
    }

    function applySel() {
        if (root.shown.length > 0) root.apply(root.shown[root.sel])
    }

    function apply(fileName) {
        const path = Config.wallpapersDir + "/" + fileName
        applyProc.command = ["sh", "-c",
            "hyprctl hyprpaper wallpaper '" + Config.wallpaperMonitor + "," + path + ",cover'" +
            " && matugen image -m 'smart' --type scheme-vibrant --prefer saturation \"" + path + "\"" +
            " && hyprctl reload" +
            // Persiste: atualiza o path no hyprpaper.conf para o próximo boot
            " && sed -i 's|path = .*|path = " + path + "|' \"$HOME/.config/hypr/hyprpaper.conf\""
        ]
        applyProc.running = true
        close()
    }
}

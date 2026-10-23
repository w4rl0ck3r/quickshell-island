pragma Singleton
import QtQuick
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

    // Entrada/saída do submap `wallpaper` (ver binds.lua) via Process
    // rastreado: um execDetached silencioso já nos deixou presos com o
    // submap armado uma vez — falha aqui aparece no log do quickshell.
    property Process submapEnterProc: Process {
        command: ["hyprctl", "dispatch", "hl.dsp.submap(\"wallpaper\")"]
        onExited: code => { if (code !== 0) console.warn("Wallpapers: entrar no submap falhou (" + code + ")") }
    }
    property Process submapExitProc: Process {
        command: ["hyprctl", "dispatch", "hl.dsp.submap(\"reset\")"]
        onExited: code => { if (code !== 0) console.warn("Wallpapers: sair do submap falhou (" + code + ")") }
    }

    function open() {
        root.filter = ""
        root.files = []
        root.sel = 0
        root.active = true
        ChargeModeMenu.close()
        PowerProfileMenu.close()
        PowerMenu.close()
        // Entra no submap das teclas Return/Esc (sai no close()).
        // (As setas são binds estáticos non_consuming: sempre passam.)
        if (!root.submapEnterProc.running) root.submapEnterProc.running = true
        listProc.running = true
    }

    function close() {
        root.active = false
        root.filter = ""
        // Devolve Return/Esc pros apps.
        if (!root.submapExitProc.running) root.submapExitProc.running = true
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
            // Paleta via wallust (duas passadas: clara p/ barra, escura p/
            // dash + hypr) fundidas com jq no Theme.json — ver wallust.toml.
            " && mkdir -p \"$HOME/.cache/wallust\"" +
            " && wallust run -C \"$HOME/.config/wallust/wallust.toml\" -s -q -n \"" + path + "\"" +
            " && wallust run -C \"$HOME/.config/wallust/wallust-dark.toml\" -s -q -n \"" + path + "\"" +
            " && jq -s '.[0] * .[1]' \"$HOME/.cache/wallust/bar.json\" \"$HOME/.cache/wallust/dash.json\"" +
            " > \"$HOME/.config/quickshell/config/Theme.json\"" +
            " && hyprctl reload" +
            // Persiste: atualiza o path no hyprpaper.conf para o próximo boot
            " && sed -i 's|path = .*|path = " + path + "|' \"$HOME/.config/hypr/hyprpaper.conf\""
        ]
        applyProc.running = true
        close()
    }
}

pragma Singleton
import QtQuick
import Quickshell.Io

// Aproximação de "tempo de tela" usando o uptime do sistema.
// Não existe uma API padrão de screen-time no Linux/Wayland; se você usar
// um tracker próprio (ex: script que soma tempo de sessão ativa em um
// arquivo), troque o comando abaixo para ler esse arquivo.
QtObject {
    id: root
    property int seconds: 0
    readonly property string formatted: {
        const h = Math.floor(root.seconds / 3600)
        const m = Math.floor((root.seconds % 3600) / 60)
        return (h > 0 ? (h + "h ") : "") + m + "m"
    }

    property Process proc: Process {
        command: ["sh", "-c", "cut -d. -f1 /proc/uptime"]
        stdout: SplitParser {
            onRead: data => {
                const v = parseInt(data)
                if (!isNaN(v)) root.seconds = v
            }
        }
    }

    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick60s() {
            proc.running = true
        }
    }
}

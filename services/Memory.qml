pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    readonly property int usedPercent: _totalKb> 0
        ? Math.round((_usedKb / _totalKb) * 100)
        : 0

    readonly property real usedGB: Math.round((_usedKb / 1048576) * 10 ) / 10

    // Propriedades internas privadas (evita alocação de objetos JS)
    property int _totalKb: 0
    property int _usedKb: 0

    property Connections _heartbeat: Connections {
        target: Heartbeat 
        function onTick3s() {
            root.memFile.reload()
        }
    }

    property FileView memFile: FileView {
        path: "/proc/meminfo"
        // Processa o arquivo sem bindings
        onLoaded: root._parseMeminfo()
    }

    // Função leve: faz busca simples sem regex ou alocações
    function _parseMeminfo() {
        const text = memFile.text()
        if (!text) return

        let total = 0
        let avail = 0

        // Parse sequencial
        const lines = text.split("\n")
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            if (line.startsWith("MemTotal:")) {
                total = parseInt(line.substring(9).trim(), 10)
            } else if (line.startsWith("MemAvailable:")) {
                avail = parseInt(line.substring(13).trim(), 10)
            }
            // Sai assim que encontra as métricas
            if (total > 0 && avail > 0) break
        }

        if (total > 0) {
            root._totalKb = total
            root._usedKb = total - avail
        }
    }
}

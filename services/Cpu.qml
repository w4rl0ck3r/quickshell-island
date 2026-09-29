pragma Singleton
import QtQuick
import Quickshell.Io

// Uso de CPU calculado a partir de /proc/stat (delta entre amostras).
QtObject {
    id: root
    
    property int usage: 0

    property double _prevIdle: 0
    property double _prevTotal: 0

    property FileView statFile: FileView {
        path: "/proc/stat"
        onLoaded: root._parseCpuStat()
    }

    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick3s() {
            root.statFile.reload()
        }
    }

    function _parseCpuStat() {
        const text = statFile.text()
        if (!text) return

        const endOfLine = text.indexOf("\n")
        if (endOfLine === -1) return
        const line = text.substring(0, endOfLine)

        let total = 0
        let idle = 0
        let col = 0
        let i = 3 // Pula o label "cpu"

        while (i < line.length) {
            // Pula os espaços em branco
            while (i < line.length && line.charCodeAt(i) === 32) i++
            if (i >= line.length) break 

            const start = i
            while (i < line.length && line.charCodeAt(i) !== 32) i++
            const val = parseInt(line.substring(start, i), 10)

            if (!isNaN(val)) {
                total += val
                if (col === 3 || col === 4) {
                    idle += val
                }
                col++
            }
        }

        if (root._prevTotal === 0) {
            root._prevIdle  = idle
            root._prevTotal = total
            return
        }

        const diffIdle  = idle - root._prevIdle
        const diffTotal = total - root._prevTotal

        if (diffTotal > 0) {
            const calculatedUsage = Math.round((1 - (diffIdle / diffTotal)) * 100)
            root.usage = Math.max(0, Math.min(100, calculatedUsage))
        }

        root._prevIdle  = idle
        root._prevTotal = total
    }
}

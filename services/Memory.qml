pragma Singleton
import QtQuick
import Quickshell.Io

// Percentual de memória usada, via `free`.
QtObject {
    id: root

    readonly property var _info: {
        const text  = root.memFile.text()
        const total = parseInt((text.match(/^MemTotal:\s+(\d+)/m)     || [0, 0]) [1])
        const avail = parseInt((text.match(/^MemAvailable:\s+(\d+)/m) || [0, 0]) [1])

        return { totalKb: total, usedKb: total - avail }
    }

    readonly property int usedPercent: _info.totalKb > 0
        ? Math.round((_info.usedKb / _info.totalKb) * 100)
        : 0

    readonly property real usedGB: Math.round((_info.usedKb / 1048576) * 10 ) / 10

    property FileView memFile: FileView {
        path: "/proc/meminfo"
    }


    property Timer timer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.memFile.reload()
    }
}

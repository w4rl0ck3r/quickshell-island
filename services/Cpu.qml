pragma Singleton
import QtQuick
import Quickshell.Io

// Uso de CPU calculado a partir de /proc/stat (delta entre amostras).
QtObject {
    id: root
    
    property int usage: 0
    property real _prevIdle: 0
    property real _prevTotal: 0

    property FileView statFile: FileView {
        path: "/proc/stat"
    }

    property var sample: {
        const line  = root.statFile.text().split("\n")[0]
        const parts = line.trim().split(/\s+/).slice(1).map(Number)

        return { idle: parts[3] + parts[4], total: parts.reduce((a, b) => a + b, 0) }
    }

    onSampleChanged: {
        const diffIdle  = sample.idle  - root._prevIdle
        const diffTotal = sample.total - root._prevTotal
        if (diffTotal > 0) root.usage = Math.round((1 - diffIdle / diffTotal) * 100)

        root._prevIdle  = sample.idle
        root._prevTotal = sample.total
    }

    property Timer timer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.statFile.reload()
    }
}

pragma Singleton
import QtQuick
import Quickshell.Io

// Aproximação de "tempo de tela" usando o uptime do sistema.
QtObject {
    id: root

    property int seconds: 0
    property string formatted: "0m"

    property FileView uptimeFile: FileView {
        path: "/proc/uptime"
        onLoaded: root._parseUptime()
    }

    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick60s() {
            root.uptimeFile.reload()
        }
    }

    function _parseUptime() {
        const text = uptimeFile.text()
        if (!text) return

        const spaceIdx = text.indexOf(" ")
        const dotIdx = text.indexOf(".")

        let endIdx = text.length
        if (dotIdx !== -1 && dotIdx < endIdx) endIdx =  dotIdx
        if (spaceIdx !== -1 && spaceIdx < endIdx) endIdx = spaceIdx

        const secs = parseInt(text.substring(0, endIdx), 10)

        if (!isNaN(secs) && secs !== root.seconds) {
            root.seconds = secs

            const h = Math.floor(secs / 3600)
            const m = Math.floor((secs % 3600) / 60)

            root.formatted = (h > 0 ? (h + "h ") : "") + m + "m"
        }
    }
}

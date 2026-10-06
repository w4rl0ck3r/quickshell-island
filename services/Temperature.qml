pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"


QtObject {
    id: root
    
    property int cpuTemp: 0
    property int gpuTemp: 0

    property string hwmonCpuPath: "/sys/class/hwmon/hwmon5"
    property string hwmonGpuPath: "/sys/class/hwmon/hwmon4"

    property FileView cpuTempFile: FileView {
        path: root.hwmonCpuPath + "/temp1_input"
        onLoaded: root._parseCpuTemp()
    }

    property FileView gpuTempFile: FileView {
        path: root.hwmonGpuPath + "/temp1_input"
        onLoaded: root._parseGpuTemp()
    }

    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick3s() {
            root.cpuTempFile.reload()
            root.gpuTempFile.reload()
        }
    }
    
    function _parseCpuTemp() {
        const text = cpuTempFile.text()
        if (!text) return

        const raw = parseInt(text.trim(), 10)
        if (!isNaN(raw) && raw > 0) {
            root.cpuTemp = Math.round(raw /1000)
        }
    }

    function _parseGpuTemp() {
        const text = gpuTempFile.text()
        if (!text) return

        const raw = parseInt(text.trim(), 10)
        if (!isNaN(raw) && raw > 0) {
            root.gpuTemp = Math.round(raw /1000)
        }
    }
}

// /hwmon2/name:BAT0
// /hwmon4/name:amdgpu
// /hwmmon5/name:k10temp
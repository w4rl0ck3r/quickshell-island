pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"


QtObject {
    id: root
    
    property string hwmonCpuPath: "/sys/class/hwmon/hwmon5"
    property string hwmonGpuPath: "/sys/class/hwmon/hwmon4"

    property int cpuTemp: {
        const raw = parseInt(cpuTempFile.text())

        return isNaN(raw) ? 0 : Math.round(raw / 1000)
    }

    property int gpuTemp: {
        const raw = parseInt(gpuTempFile.text())

        return isNaN(raw) ? 0 : Math.round(raw / 1000)
    }

    property FileView cpuTempFile: FileView {
        path: root.hwmonCpuPath + "/temp1_input"
    }

    property FileView gpuTempFile: FileView {
        path: root.hwmonGpuPath + "/temp1_input"
    }

    property Timer timer: Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.cpuTempFile.reload()
    }

    property Timer timer2: Timer {
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.gpuTempFile.reload()
    }

}

// /hwmon2/name:BAT0
// /hwmon4/name:amdgpu
// /hwmmon5/name:k10temp
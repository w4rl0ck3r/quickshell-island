pragma Singleton
import QtQuick
import Quickshell.Io

// Brilho via /sys/class/backlight (inotify, sem Process/Timer).
QtObject {
    id: root
    property string device: "amdgpu_bl1"

    property FileView curFile: FileView {
        path: "/sys/class/backlight/" + root.device + "/brightness"
        watchChanges: true
        onFileChanged: reload()
    }
    property FileView maxFile: FileView {
        path: "/sys/class/backlight/" + root.device + "/max_brightness"
    }
    
    readonly property int percent: maxFile.loaded && curFile.loaded && maxValue > 0
        ? Math.round((curValue / maxValue) * 100)
        : 0

    readonly property real curValue: parseFloat(curFile.text()) || 0
    readonly property real maxValue: parseFloat(maxFile.text()) || 0


}
import "../components"
import "../services"
import "../config"
import QtQuick

Pill {
    property bool showGpuTemp: false
    property string celsius: showGpuTemp ? Temperature.gpuTemp : Temperature.cpuTemp

    //--- Icons and StatusColor
    readonly property string statIcon: {
        if (celsius <= 30) return ""
        if (celsius <= 40) return ""
        if (celsius <= 69) return ""

        return ""
    }

    readonly property color statusColor: {
        if (celsius <= 30) return Theme.cool
        if (celsius <= 69) return Theme.islandText
        if (celsius <= 79) return Theme.warning

        return Theme.alert
    }

    icon: statIcon
    label: showGpuTemp ? celsius + "ºC - GPU" : celsius + "ºC"
    contentColor: statusColor
    isClickable: true
    onClicked: showGpuTemp = !showGpuTemp


}

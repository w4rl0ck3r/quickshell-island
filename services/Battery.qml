pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import "../config"

QtObject {
    id: root

    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging

    property FileView chargeModeFile: FileView {
        path: "/sys/class/power_supply/BAT0/charge_types"
        watchChanges: true
        onFileChanged: this.reload()
        
    }

    readonly property string currentMode: {
        const raw = chargeModeFile.text()
        const match = raw ? raw.match(/\[([^\]]+)\]/) : "error"
        return match[1]
    }

    readonly property color statusColor: {
        if (charging) return Theme.ok
        if (level <= 15) return Theme.alert
        if (level <= 30) return Theme.warning

        return Theme.text
    }
    readonly property var icon: {
        if (charging) {
            if (currentMode === "Fast") return "󱐋"      // Ícone para Modo Rápido
            if (currentMode === "Long_Life") return "󰌪" // Ícone para Vida Longa
            return ""                                  // Ícone para Padrão (Standard)
        } 
        if (level <= 10) return ""
        if (level <= 40) return ""
        if (level <= 60) return ""
        if (level <= 80) return ""
        
        return ""
    } 
    readonly property int level: Math.round(battery.percentage * 100)

    
}


 
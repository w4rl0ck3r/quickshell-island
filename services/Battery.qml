pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import "../config"

QtObject {
    id: root

    property var battery:        UPower.displayDevice
    property bool charging:      battery.state === UPowerDeviceState.Charging
    readonly property int level: Math.round(battery.percentage * 100)

    property bool notifiedLow:      false
    property bool notifiedCritical: false

    onLevelChanged: _checkThreshholds()
    onChargingChanged: {
        if (charging) {
            notifiedLow = false
            notifiedCritical = false
        } else {
            _checkThreshholds()
        }
    }

    function _checkThreshholds() {
        if (charging) return

        if (level <= 15 && !notifiedCritical) {
            notifiedCritical = true_sendNotification("Nível crítico: " + level + "%", true)
        } else if ( level <= 30 && !notifiedLow) {
            notifiedLow = true
            true_sendNotification("Nível baixo: " + level + "%", false)
        }

        if (level > 30) notifiedLow = false
        if (level > 15) notifiedCritical = false
    }

    property Process notifyProc: Process { command: ["true"] }

    function true_sendNotification(text, critical) {
        notifyProc.command = ["notify-send", "-u", critical ? "critical" : "normal", "Bateria", text]
        notifyProc.running = true
    }

    property FileView chargeModeFile: FileView {
        path: "/sys/class/power_supply/" + Config.batteryDevice + "/charge_types"
        watchChanges: true
        onFileChanged: this.reload()
        
    }

    readonly property string currentMode: {
        const raw = chargeModeFile.text()
        const match = raw ? raw.match(/\[([^\]]+)\]/) : null
        return match ? match[1] : "Standard"
    }

    readonly property color statusColor: {
        if (charging)    return Theme.ok
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
}


 
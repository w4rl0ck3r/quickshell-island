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

    // Cores semânticas FIXAS (hex direto, fora do Theme): o matugen
    // nunca as altera — aviso ≤30%, crítico ≤15%, carregando = ok.
    readonly property color battOk: "#a6e3a1"
    readonly property color battWarn: "#f9e2af"
    readonly property color battAlert: "#f38ba8"

    readonly property color statusColor: {
        if (charging)    return battOk
        if (level <= 15) return battAlert
        if (level <= 30) return battWarn
        return Theme.islandText
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


 
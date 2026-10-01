pragma Singleton
import QtQuick

// Parâmetros ajustáveis da barra: dimensões, comandos externos e caminhos.
QtObject {
    readonly property int barHeight: 30
    readonly property int margin: 10
    readonly property int spacing: 5
    readonly property int pillHeight: 28

    readonly property int islandCollapsedWidth: 92
    readonly property int islandCollapsedHeight: 30
    readonly property int islandExpandedWidth: 220
    readonly property int islandExpandedHeight: 150
    readonly property int islandNotifWidth: 360
    readonly property int islandNotifHeight: 84
    readonly property int islandCentralWidth: 260
    readonly property int islandCentralHeight: 280

    
    // Comandos externos (ajuste conforme seu sistema)
    readonly property string rofiCommand: "rofi -show drun -theme ~/.config/quickshell/rofi/theme.rasi"
    readonly property string lockCommand: "hyprlock"
    readonly property string shutdownCommand: "systemctl poweroff"
    readonly property string chargeScriptPath: "$HOME/.config/quickshell/scripts/set-charge-mode.sh"

    // Dispositivo de bateria (troque para BAT1 se necessário: ls /sys/class/power_supply/)
    readonly property string batteryDevice: "BAT0"
}

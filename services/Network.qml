pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell.Networking

// Status de Wi-Fi via NetworkManager (nmcli).
QtObject {
    id: root
    
    readonly property bool connected: Networking.devices.values[0].connected
    readonly property string ssid: `${Networking.devices.values[0].networks.values.find(n => n.connected).name}`
    readonly property string signal: `${String(Math.round(Networking.devices.values[0].networks.values.find(n => n.connected).signalStrength * 100))}%`
    
}
 
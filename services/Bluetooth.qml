pragma Singleton
import QtQuick
import Quickshell.Bluetooth

// Liga/desliga o adaptador Bluetooth padrão via API nativa (DBus/bluez) —
// sem Process, sem bluetoothctl.
QtObject {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled

    function toggle() {
        if (available) adapter.enabled = !adapter.enabled
    }
}

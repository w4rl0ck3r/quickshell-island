import "../components"
import "../services"

Pill {
    property bool showSsid : false

    icon: Network.connected ? "" : "󰌙"
    label: showSsid 
        ? Network.ssid
        : Network.signal
    showLabel: Network.connected
    isClickable: true

    onClicked: {
        showSsid = !showSsid
    }
}
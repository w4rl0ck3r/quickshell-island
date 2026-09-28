import "../components"
import "../services"

Pill {
    property bool showGB: false

    icon: ""
    label: showGB ? Memory.usedGB + "GB" :  Memory.usedPercent + "%"
    isClickable: true
    onClicked: showGB = !showGB
}

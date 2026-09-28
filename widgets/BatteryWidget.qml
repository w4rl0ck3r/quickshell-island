import "../components"
import "../services"
import "../menus"

// Clique abre o menu de modo de carregamento (fast/standard/long_life).
Pill {
    icon: Battery.icon
    label: Battery.level + "%"
    contentColor: Battery.statusColor
    onClicked: ChargeModeMenu.toggle()
}

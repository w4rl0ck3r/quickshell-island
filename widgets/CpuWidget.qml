import "../components"
import "../services"
import "../menus"

// Clique abre o menu de perfil de energia (performance/balanceado/economia).
Pill {
    icon: ""
    label: Cpu.usage + "%"
    onClicked: PowerProfileMenu.toggle()
}

import Quickshell.Hyprland
import "../menus"
import "../services"

// Atalhos globais via protocolo hyprland_global_shortcuts_v1.
// Vincule teclas reais no hyprland.conf, ex:
//   bind = SUPER, SPACE, global, quickshell:search
//   bind = SUPER, B, global, quickshell:chargeMode
//   bind = SUPER, P, global, quickshell:powerProfile
//   bind = SUPER, ESCAPE, global, quickshell:powerMenu
Item {
    GlobalShortcut {
        name: "search"
        description: "Abrir busca (rofi) pela barra"
        onPressed: Launcher.launch()
    }

    GlobalShortcut {
        name: "chargeMode"
        description: "Abrir menu de modo de carregamento da bateria"
        onPressed: ChargeModeMenu.toggle()
    }

    GlobalShortcut {
        name: "powerProfile"
        description: "Abrir menu de perfil de energia"
        onPressed: PowerProfileMenu.toggle()
    }

    GlobalShortcut {
        name: "powerMenu"
        description: "Abrir menu de desligar/trancar"
        onPressed: PowerMenu.toggle()
    }
}

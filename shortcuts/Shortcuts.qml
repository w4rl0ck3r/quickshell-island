import QtQuick
import Quickshell.Hyprland
import "../menus"
import "../services"

// Atalhos globais via protocolo hyprland_global_shortcuts_v1.
// Vincule teclas reais no hyprland.conf, ex:
//   bind = SUPER SHIFT, W, global, quickshell:wallpaper
//
// As setas/Enter/Esc do picker NÃO têm binds estáticos (isso comeria
// as teclas no sistema todo): elas vivem no submap `wallpaper`
// (binds.lua), onde o quickshell entra ao abrir o picker e de onde
// sai ao fechar. Estes objetos ficam registrados sempre — fora do
// submap nada é roteado pra cá — e os guards abaixo são só defesa.
Item {
    GlobalShortcut {
        name: "wallpaper"
        description: "Abrir seletor de wallpaper na Dynamic Island"
        onPressed: Wallpapers.open()
    }

    GlobalShortcut {
        name: "wallpaper-prev"
        description: "Seletor de wallpaper: anterior"
        onPressed: if (Wallpapers.active) Wallpapers.nudge(-1)
    }
    GlobalShortcut {
        name: "wallpaper-next"
        description: "Seletor de wallpaper: próximo"
        onPressed: if (Wallpapers.active) Wallpapers.nudge(1)
    }
    GlobalShortcut {
        name: "wallpaper-apply"
        description: "Seletor de wallpaper: aplicar"
        onPressed: if (Wallpapers.active) Wallpapers.applySel()
    }
    GlobalShortcut {
        name: "island-escape"
        description: "Fechar picker/menu da Dynamic Island"
        onPressed: {
            if (Wallpapers.active) {
                Wallpapers.close()
            } else {
                ChargeModeMenu.close()
                PowerProfileMenu.close()
                PowerMenu.close()
            }
        }
    }
}

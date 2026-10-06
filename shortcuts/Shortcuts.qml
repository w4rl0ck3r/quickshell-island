import QtQuick
import Quickshell.Hyprland
import "../menus"
import "../services"

// Atalhos globais via protocolo hyprland_global_shortcuts_v1.
// Vincule teclas reais no hyprland.conf, ex:
//   bind = SUPER SHIFT, W, global, quickshell:wallpaper
Item {
    GlobalShortcut {
        name: "wallpaper"
        description: "Abrir seletor de wallpaper na Dynamic Island"
        onPressed: Wallpapers.open()
    }
}

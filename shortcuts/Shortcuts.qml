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

    // Setas/Enter do seletor SÓ enquanto ele está aberto: o Loader
    // registra os nomes no compositor ao abrir e cancela ao fechar.
    // Fora disso as teclas passam normalmente pros apps. Sem isso as
    // setas só funcionariam com o mouse sobre a ilha, que é a única
    // hora em que a barra tem foco de teclado (follow_mouse).
    Loader {
        active: Wallpapers.active
        sourceComponent: Component {
            Item {
                GlobalShortcut {
                    name: "wallpaper-prev"
                    description: "Seletor de wallpaper: anterior"
                    onPressed: Wallpapers.nudge(-1)
                }
                GlobalShortcut {
                    name: "wallpaper-next"
                    description: "Seletor de wallpaper: próximo"
                    onPressed: Wallpapers.nudge(1)
                }
                GlobalShortcut {
                    name: "wallpaper-apply"
                    description: "Seletor de wallpaper: aplicar"
                    onPressed: Wallpapers.applySel()
                }
            }
        }
    }

    // Esc fecha o picker ou qualquer menu da ilha.
    Loader {
        active: Wallpapers.active || ChargeModeMenu.open || PowerProfileMenu.open || PowerMenu.open
        sourceComponent: Component {
            Item {
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
        }
    }
}

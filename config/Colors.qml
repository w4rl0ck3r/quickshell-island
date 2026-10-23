pragma Singleton
import QtQuick
import Quickshell.Io

// Cores geradas pelo wallust (config/Theme.json).
// WatchChanges: true faz o bar recarregar as cores ao trocar o wallpaper.
QtObject {
    id: root

    property color base: "#1D0000"
    property color text: "#D2BDBB"
    property color subtle: "#B69996"
    property color hover: "#47322F"
    property color border: "#7F6B69"
    property color dashBg: "#1D0000"
    property color dashCard: "#2E1613"
    property color dashCardHover: "#47322F"
    property color dashText: "#D2BDBB"
    property color dashSubtext: "#B69996"
    property color dashAccent: "#B69996"
    property color dashDivider: "#7F6B69"
    property color islandBg: "#FFF7F1"
    property color islandText: "#391E1C"
    property color islandSubtle: "#634F4D"
    property color islandTextSubtle: "#391E1C"
    property color islandAccent: "#811A1B"
    property color islandCard: "#F2EBE5"
    property color islandCardHover: "#E6DED9"
    property color alert: "#f38ba8"
    property color ok: "#a6e3a1"
    property color cool: "#89b4fa"
    property color warning: "#f9e2af"
    // Semânticas para a barra clara (superfície `islandBg`): tons joia
    // profundos com contraste ≥4.5:1 sobre fundo claro. São valores
    // FIXOS (também fixos no template do matugen) — nunca pastéis.
    property color islandAlert: "#B3261E"
    property color islandOk: "#386A1F"
    property color islandWarning: "#7E5700"
    property color islandCool: "#0F6B6E"

    property FileView themeFile: FileView {
        path: Qt.resolvedUrl("Theme.json").toString().replace("file://", "")
        watchChanges: true
        onLoaded: root._parse()
        onFileChanged: reload()
    }

    function _parse() {
        try {
            const t = themeFile.text()
            if (!t) return
            const json = JSON.parse(t)
            for (const key in json) {
                if (root.hasOwnProperty(key))
                    root[key] = json[key]
            }
        } catch (e) {
            console.warn("Colors.qml: failed to parse Theme.json:", e)
        }
    }
}

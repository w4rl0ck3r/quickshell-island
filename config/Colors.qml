pragma Singleton
import QtQuick
import Quickshell.Io

// Cores geradas pelo matugen (config/Theme.json).
// WatchChanges: true faz o bar recarregar as cores ao trocar o wallpaper.
QtObject {
    id: root

    property color base: "#f8f8f8"
    property color text: "#F8F8F8"
    property color subtle: "#8A8A8A"
    property color hover: "#ECECEC"
    property color border: "#E7E7E7"
    property color dashBg: "#FBF4F0"
    property color dashCard: "#F6E4DE"
    property color dashCardHover: "#F0D7CE"
    property color dashText: "#3B2420"
    property color dashSubtext: "#9C7D74"
    property color dashAccent: "#A84432"
    property color dashDivider: "#E8CFC5"
    property color islandBg: "#1C1C1E"
    property color islandText: "#F8F8F8"
    property color islandSubtle: "#8E8E93"
    property color islandTextSubtle: "#C7C7CC"
    property color islandAccent: "#E0A479"
    property color alert: "#f38ba8"
    property color ok: "#a6e3a1"
    property color cool: "#42a5f5"
    property color warning: "#f9e2af"

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

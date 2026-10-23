pragma Singleton
import QtQuick
import Quickshell.Io

// Paleta e tokens visuais centrais da barra.
// As cores vêm do wallust (config/Theme.json via Colors.qml); aqui ficam
// geometria, tipografia e animação fixas + os aliases para as cores.
QtObject {
    id: root

    // Esquema claro/escuro unificado: `dark` alterna os tokens `island*`
    // (barra e painéis claros) para os equivalentes escuros — tudo que
    // usa `island*`/`dash*` acompanha sem mexer em mais nenhum arquivo.
    // Persiste em config/thememode ("dark" ou "light"; ausente = claro).
    property bool dark: false
    property FileView modeFile: FileView {
        path: Qt.resolvedUrl("thememode").toString().replace("file://", "")
        watchChanges: true
        onLoaded: root._parseMode()
        onFileChanged: reload()
    }
    property Process modeProc: Process {
        onExited: code => { if (code !== 0) console.warn("Theme: gravar thememode falhou (" + code + ")") }
    }

    function _parseMode() {
        try {
            root.dark = (root.modeFile.text() || "").trim() === "dark"
        } catch (e) {
            root.dark = false
        }
    }

    function toggle() {
        const next = root.dark ? "light" : "dark"
        root.dark = !root.dark
        root.modeProc.command = ["sh", "-c", "printf '" + next + "' > '" + root.modeFile.path + "'"]
        if (!root.modeProc.running) root.modeProc.running = true
    }
    // Base da barra
    readonly property color base: root.dark ? Colors.base : Colors.islandBg
    readonly property color text: Colors.text
    readonly property color subtle: Colors.subtle
    readonly property color hover: Colors.hover
    readonly property color border: Colors.border

    // Central da ilha: no esquema claro tudo é claro (painéis = island*),
    // no escuro tudo é escuro (painéis = dash*) — sem mistura.
    readonly property color dashBg: root.dark ? Colors.dashBg : Colors.islandBg
    readonly property color dashCard: root.dark ? Colors.dashCard : Colors.islandCard
    readonly property color dashCardHover: root.dark ? Colors.dashCardHover : Colors.islandCardHover
    readonly property color dashText: root.dark ? Colors.dashText : Colors.islandText
    readonly property color dashSubtext: root.dark ? Colors.dashSubtext : Colors.islandSubtle
    readonly property color dashAccent: root.dark ? Colors.dashAccent : Colors.islandAccent
    readonly property color dashDivider: root.dark ? Colors.dashDivider : Colors.islandSubtle

    // Dynamic Island
    readonly property color islandBg: root.dark ? Colors.dashBg : Colors.islandBg
    readonly property color islandText: root.dark ? Colors.dashText : Colors.islandText
    readonly property color islandSubtle: root.dark ? Colors.dashSubtext : Colors.islandSubtle
    readonly property color islandTextSubtle: root.dark ? Colors.dashSubtext : Colors.islandTextSubtle
    readonly property color islandAccent: root.dark ? Colors.dashAccent : Colors.islandAccent

    // Status colors (superfícies escuras: pastéis do matugen)
    readonly property color warning: Colors.warning
    readonly property color alert: Colors.alert
    readonly property color ok: Colors.ok
    readonly property color cool: Colors.cool

    // Status colors (barra clara `islandBg`: joias profundas, AA)
    readonly property color islandWarning: root.dark ? Colors.warning : Colors.islandWarning
    readonly property color islandAlert: root.dark ? Colors.alert : Colors.islandAlert
    readonly property color islandOk: root.dark ? Colors.ok : Colors.islandOk
    readonly property color islandCool: root.dark ? Colors.cool : Colors.islandCool

    // Geometria
    readonly property int radius: 16
    readonly property int radiusSmall: 10

    // Tipografia
    readonly property string fontFamily: "Inter"
    readonly property int fontSize: 12

    // Animação
    readonly property int animFast: 130
    readonly property int animNormal: 260
}

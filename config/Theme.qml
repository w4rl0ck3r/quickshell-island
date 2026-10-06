pragma Singleton
import QtQuick

// Paleta e tokens visuais centrais da barra.
// As cores vêm do matugen (config/Theme.json via Colors.qml); aqui ficam
// geometria, tipografia e animação fixas + os aliases para as cores.
QtObject {
    // Base da barra
    readonly property color base: Colors.base
    readonly property color text: Colors.text
    readonly property color subtle: Colors.subtle
    readonly property color hover: Colors.hover
    readonly property color border: Colors.border

    // Central da ilha (fundo creme/escuro dependendo do modo do matugen)
    readonly property color dashBg: Colors.dashBg
    readonly property color dashCard: Colors.dashCard
    readonly property color dashCardHover: Colors.dashCardHover
    readonly property color dashText: Colors.dashText
    readonly property color dashSubtext: Colors.dashSubtext
    readonly property color dashAccent: Colors.dashAccent
    readonly property color dashDivider: Colors.dashDivider

    // Dynamic Island
    readonly property color islandBg: Colors.islandBg
    readonly property color islandText: Colors.islandText
    readonly property color islandSubtle: Colors.islandSubtle
    readonly property color islandTextSubtle: Colors.islandTextSubtle
    readonly property color islandAccent: Colors.islandAccent

    // Status colors
    readonly property color warning: Colors.warning
    readonly property color alert: Colors.alert
    readonly property color ok: Colors.ok
    readonly property color cool: Colors.cool

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

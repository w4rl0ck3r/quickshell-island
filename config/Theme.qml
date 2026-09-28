pragma Singleton
import QtQuick

// Paleta e tokens visuais centrais da barra.
// Alterar cores/raios aqui reflete em todos os componentes.
QtObject {
    // Base da barra
    readonly property color base: "#F8F8F8"
    readonly property color text: "#F8F8F8"
    readonly property color subtle: "#8A8A8A"
    readonly property color hover: "#ECECEC"
    readonly property color border: "#E7E7E7"

    // Dynamic Island (contraste estilo iPhone sobre a barra clara)
    readonly property color islandBg: "#F8F8F8"
    readonly property color islandText: "#313131"
    readonly property color islandSubtle: "#8E8E93"
    readonly property color islandTextSubtle: "#C7C7CC"

    // Status colors
    readonly property color warning: "#f9e2af"
    readonly property color alert: "#f38ba8"
    readonly property color ok: "#a6e3a1"
    readonly property color cool: "#42a5f5"

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
 
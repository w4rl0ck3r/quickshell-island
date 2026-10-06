import QtQuick
import QtQuick.Layouts
import Quickshell
import "../config"
import "../widgets"
import "../island"
import "../menus"

// Barra principal: PanelWindow fixado no topo, com widgets fixos nas
// laterais e a Dynamic Island centralizada.
//
// A janela ocupa a TELA INTEIRA desde o início (nunca é redimensionada em
// runtime) e só desenha/recebe clique na faixa da barra + na ilha, via
// `mask`. Isso evita o "jitter" de redimensionar a janela a cada frame de
// animação (o compositor pode aplicar o novo tamanho um frame antes/depois
// do buffer correspondente) e remove qualquer teto de altura pra futuros
// painéis maiores. Padrão usado por shells de referência como o impasto.
PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: screen ? screen.height : Config.barHeight
    color: "transparent"

    // exclusionMode "Auto" (padrão) reservaria a altura da JANELA, que
    // agora é a tela inteira — reservar isso quebraria o tiling. Por isso
    // fixamos a zona exclusiva no tamanho real da barra visível; setar
    // exclusiveZone também muda exclusionMode para Normal sozinho.
    exclusiveZone: Config.barHeight

    mask: Region {
        item: barBackground
        Region { item: island.maskItem }
    }

    // Conecta os menus (que vivem fora da árvore da barra, como
    // singletons) à janela desta barra para que possam se ancorar nela.
    Component.onCompleted: {
        if (!ChargeModeMenu.barWindow) ChargeModeMenu.barWindow = bar
        if (!PowerProfileMenu.barWindow) PowerProfileMenu.barWindow = bar
        if (!PowerMenu.barWindow) PowerMenu.barWindow = bar
        if (!Tray.barWindow) Tray.barWindow = bar
    }

    Rectangle {
        id: barBackground
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Config.barHeight
        color: "transparent"

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: Config.margin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Config.spacing

            MemoryWidget {}
            CpuWidget {}
            TemperatureWidget {}
            ScreenTimeWidget {}
        }

        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: Config.margin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Config.spacing
            
            TrayWidget {}
            WifiWidget {}
            VolumeWidget {}
            BrightnessWidget {}
            BatteryWidget {}
        }
    }

    DynamicIsland {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 0
    }
}

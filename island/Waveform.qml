import QtQuick
import "../config"
import "../services"

// Equalizador da ilha: 5 pílulas verticais movidas pelo áudio real
// (services/Cava.qml). Sem Timer e sem onda fake — cada frame do cava
// troca `Cava.levels` (0..1) e a altura segue com curva de loudness
// (0.55, o cava entrega amplitude linear) + 70ms de suavização.
//
// Sem playback as barras ficam retas no mínimo ("-----").
Item {
    id: root

    // false = achata tudo no mínimo (pausa, grace de 10s, sem faixa)
    property bool playing: false

    readonly property int barWidth: 4
    readonly property int barGap: 3
    readonly property int minH: 2     // reta: só o diâmetro da pílula
    readonly property int maxH: 18
    readonly property int count: 5
    readonly property real curve: 0.55

    implicitWidth: row.implicitWidth
    implicitHeight: maxH

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.barGap

        Repeater {
            model: root.count

            // Item de altura fixa com a barra centrada dentro: a linha
            // inteira não "pula" quando uma barra fica mais alta.
            delegate: Item {
                id: slot
                property int i: index

                width: root.barWidth
                height: root.maxH

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.barWidth
                    height: {
                        if (!root.playing) return root.minH
                        const v = Cava.levels[slot.i] ?? 0
                        return root.minH + (root.maxH - root.minH)
                            * Math.pow(Math.max(0, v), root.curve)
                    }
                    // Curta o bastante pra seguir a batida, longa o
                    // bastante pra esconder um frame perdido do cava.
                    Behavior on height { NumberAnimation { duration: 70; easing.type: Easing.OutQuad } }
                    radius: width / 2          // pílula, não quadrado
                    color: Theme.islandText
                }
            }
        }
    }
}

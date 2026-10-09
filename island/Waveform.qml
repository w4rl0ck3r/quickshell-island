import QtQuick
import "../config"

// Equalizador minimalista da ilha: 5 pílulas verticais que sobem e descem
// enquanto a música toca. Sem Timer — um único NumberAnimation alimenta a
// fase `t` e cada barra calcula a própria altura com um offset, formando a
// onda que atravessa o equalizador.
//
// Parado (faixa carregada, sem playback) as barras ficam retas no mínimo,
// formando uma linha fina "-----" no centro da pílula.
Item {
    id: root

    // true = animando; false = barras achatadas no mínimo
    property bool playing: false

    readonly property int barWidth: 4
    readonly property int barGap: 3
    readonly property int minH: 2     // reta: só o diâmetro da pílula
    readonly property int maxH: 18
    readonly property int count: 5

    implicitWidth: row.implicitWidth
    implicitHeight: maxH

    // Fase compartilhada 0..1; cada barra soma seu próprio offset.
    property real t: 0
    NumberAnimation on t {
        from: 0
        to: 1
        duration: 1400
        loops: Animation.Infinite
        running: root.playing
    }

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
                    height: root.playing
                        ? root.minH + (root.maxH - root.minH)
                          * (0.5 + 0.5 * Math.sin(2 * Math.PI * (root.t + slot.i * 0.18)))
                        : root.minH
                    radius: width / 2          // pílula, não quadrado
                    color: Theme.islandText
                }
            }
        }
    }
}

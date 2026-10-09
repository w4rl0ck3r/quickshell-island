pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Espectro de áudio via cava (scripts/cava.conf: 5 bandas mono, raw
// ASCII no stdout, um frame por linha). Sem Timer e sem polling: o
// SplitParser entrega cada frame e `levels` é trocado por um array
// novo (0..1), o que notifica os bindings das barras.
//
// O processo vive SÓ enquanto há playback (running: Music.playing) —
// pausou, o cava morre e o Waveform achata por conta própria.
QtObject {
    id: root

    readonly property int bars: 5
    property var levels: [0, 0, 0, 0, 0]

    property Process proc: Process {
        command: ["cava", "-p", Quickshell.shellPath("scripts/cava.conf")]
        running: Music.playing
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root._parse(line)
        }
    }

    function _parse(line) {
        const fields = line.split(";")
        const next = []
        for (let i = 0; i < root.bars; i++) {
            const v = Number(fields[i])
            next.push(Number.isFinite(v) ? Math.max(0, Math.min(1, v / 100)) : 0)
        }
        // Silêncio repetido: não reatribui, não acorda bindings à toa.
        let same = next.length === root.levels.length
        if (same) {
            for (let i = 0; i < next.length; i++) {
                if (next[i] !== root.levels[i]) {
                    same = false
                    break
                }
            }
        }
        if (!same) root.levels = next
    }
}

pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

// Volume/mute via PipeWire (wpctl). Requer `pipewire` + `wireplumber`.
QtObject {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready && sink.audio !== null

    readonly property bool muted: ready && sink.audio.muted
    readonly property int volume: ready ? Math.round(sink.audio.volume * 100) : 0

    // Mantém o sink atual sob observação do Pipewire. Precisa se
    // re-registrar sempre que o sink padrão mudar (daí o binding
    // reativo em vez de uma lista fixa).
    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    function toggleMute() {
        if (root.ready) sink.audio.muted = !sink.audio.muted
    }

    function setVolume(percent) {
        if (root.ready) sink.audio.volume = Math.max(0, Math.min(1.5, percent / 100))
    }
}



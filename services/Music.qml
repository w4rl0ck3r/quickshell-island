pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell.Services.Mpris

// Faixa atual: MPRIS (navegadores, mpv...) + spotify_player via CLI.
//
// O spotify_player NÃO expõe MPRIS no D-Bus, então o estado dele vem de
// `spotify_player get key playback` (JSON), sem Timer próprio: o poll
// roda no tick3s do Heartbeat, como Temperature.qml faz com FileView.
//
// Prioridade fixa: spotify_player com faixa carregada SEMPRE vence,
// mesmo que outro player esteja tocando (pedido do usuário).
QtObject {
    id: root

    // ---- MPRIS -----------------------------------------------------

    // Escolhe o player MPRIS: prefere "spotify" no identity/dbusName
    // (cobre spotify_player, caso um dia ele exponha MPRIS, e o client
    // oficial), senão quem está tocando, senão o primeiro com título.
    readonly property var mprisCurrent: {
        const list = Mpris.players.values
        if (list === null || list.length === undefined) return null

        function isSpotify(p) {
            const id = (p.identity + " " + p.dbusName).toLowerCase()
            return id.indexOf("spotify") !== -1
        }

        let playing = null
        let withTitle = null
        for (let i = 0; i < list.length; i++) {
            const p = list[i]
            if (p.trackTitle.length === 0) continue
            if (isSpotify(p)) return p
            if (playing === null && p.isPlaying) playing = p
            if (withTitle === null) withTitle = p
        }
        if (playing !== null) return playing
        return withTitle
    }

    // ---- spotify_player (CLI, sem MPRIS) ----------------------------

    property string spTitle: ""
    property string spArtist: ""
    property bool spPlaying: false
    property bool spHas: false

    // Cooldown em ticks de 3s após falha (daemon fechado): evita
    // ressuscitar processo falho a cada tick; tenta de novo em ~60s.
    property int _spCooldown: 0

    property Process spProc: Process {
        command: ["spotify_player", "get", "key", "playback"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data)
                    if (json.item === null || json.item === undefined) {
                        root.spHas = false
                        return
                    }
                    root.spTitle = json.item.name
                    root.spArtist = (json.item.artists && json.item.artists.length > 0)
                        ? json.item.artists[0].name : ""
                    root.spPlaying = json.is_playing === true
                    root.spHas = root.spTitle.length > 0
                    root._spCooldown = 0
                } catch (e) {
                    root.spHas = false
                }
            }
        }
        onExited: exitCode => {
            // Daemon fechado ou CLI quebrou: limpa a faixa e espera ~60s.
            if (exitCode !== 0) {
                root.spHas = false
                root._spCooldown = 20
            }
        }
    }

    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick3s() {
            if (root._spCooldown > 0) {
                root._spCooldown--
                return
            }
            if (!root.spProc.running) root.spProc.running = true
        }
    }

    Component.onCompleted: spProc.running = true

    // ---- saída (spotify_player sempre no topo) ----------------------

    readonly property bool active: root.spHas
        || (root.mprisCurrent !== null && root.mprisCurrent.trackTitle.length > 0)
    readonly property bool playing: root.spHas
        ? root.spPlaying
        : (root.mprisCurrent !== null && root.mprisCurrent.isPlaying)
    readonly property string title: root.spHas
        ? root.spTitle
        : (root.mprisCurrent !== null ? root.mprisCurrent.trackTitle : "")
    readonly property string artist: root.spHas
        ? root.spArtist
        : (root.mprisCurrent !== null ? root.mprisCurrent.trackArtists : "")
}

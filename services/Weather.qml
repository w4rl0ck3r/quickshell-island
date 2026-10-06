pragma Singleton
import QtQuick
import Quickshell.Io
import "../config"

// Clima atual via Open-Meteo (API pública, sem chave). Requer `curl` e
// internet; se falhar, mantém o último valor conhecido silenciosamente.
// Ajuste Config.weatherLatitude/weatherLongitude para a sua localização.
QtObject {
    id: root
    property real temperature: NaN
    property int weatherCode: -1
    property bool ready: false

    readonly property string icon: {
        if (!root.ready) return "…"
        const c = root.weatherCode
        if (c === 0) return "󰖙"
        if (c <= 2) return "🌤"
        if (c === 3) return "☁"
        if (c === 45 || c === 48) return "🌫"
        if (c >= 51 && c <= 57) return "🌦"
        if ((c >= 61 && c <= 67) || (c >= 80 && c <= 82)) return "🌧"
        if (c >= 71 && c <= 77) return "❄"
        if (c >= 95) return "⛈"
        return "🌡"
    }

    readonly property string condition: {
        if (!root.ready) return "Carregando..."
        const c = root.weatherCode
        if (c === 0) return "Céu limpo"
        if (c <= 2) return "Poucas nuvens"
        if (c === 3) return "Nublado"
        if (c === 45 || c === 48) return "Neblina"
        if (c >= 51 && c <= 57) return "Garoa"
        if ((c >= 61 && c <= 67) || (c >= 80 && c <= 82)) return "Chuva"
        if (c >= 71 && c <= 77) return "Neve"
        if (c >= 95) return "Tempestade"
        return "—"
    }

    property Process proc: Process {
        command: ["curl", "-s", "--max-time", "5",
            "https://api.open-meteo.com/v1/forecast?latitude=" + Config.weatherLatitude
            + "&longitude=" + Config.weatherLongitude
            + "&current=temperature_2m,weather_code&timezone=auto"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data)
                    root.temperature = json.current.temperature_2m
                    root.weatherCode = json.current.weather_code
                    root.ready = true
                } catch (e) {
                    // offline ou resposta inválida — mantém o último valor
                }
            }
        }
    }

    // Conecta ao Heartbeat no tick de 60s
    property int _minuteCounter: 0
    property Connections _heartbeat: Connections {
        target: Heartbeat
        function onTick60s() {
            root._minuteCounter++
            // 20 minutos = 20 ciclos de 60s
            if (root._minuteCounter >= 20 || !root.ready) {
                root._minuteCounter = 0
                proc.running = true
            }
        }
    }
}

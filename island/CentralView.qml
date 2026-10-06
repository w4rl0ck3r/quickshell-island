import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../config"
import "../services"
import "../menus"

// Painel "central" da ilha (modo "central" em DynamicIsland.qml):
// relógio grande com data por extenso, clima, calendário do mês,
// estatísticas (memória, CPU, tempo de tela, bluetooth) e ações rápidas
// (modo de carregamento, perfil de energia e desligar com confirmação).
Item {
    id: root

    property bool showMemoryGB: false
    property var now: new Date()

    // Confirmação inline do desligamento: 1º clique arma, 2º executa.
    property bool powerArmed: false

    readonly property var weekdays: ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"]
    readonly property var months:   ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]

    // Rótulo amigável do modo de carregamento atual (vem do sysfs via Battery)
    readonly property string chargeLabel: {
        switch (Battery.currentMode) {
        case "Fast":      return "Rápido"
        case "Long_Life": return "Longa duração"
        default:          return "Padrão"
        }
    }

    // Perfil de energia atual, consultado via power-profiles-daemon.
    property string powerProfile: "balanced"
    readonly property string powerLabel: {
        switch (powerProfile) {
        case "performance": return "Performance"
        case "power-saver": return "Economia"
        default:            return "Balanceado"
        }
    }

    Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: root.now = new Date()
    }

    Timer {
        id: powerArmTimer
        interval: 3000
        onTriggered: root.powerArmed = false
    }

    // Consulta o perfil de energia a cada 5s (powerprofilesctl get).
    Process {
        id: powerProfileProc
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: line => { root.powerProfile = line.trim() }
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: powerProfileProc.running = true
    }

    Process {
        id: shutdownProc
        command: ["sh", "-c", Config.shutdownCommand]
    }

    Process {
        id: brightnessProc
        command: ["true"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // ---- Cabeçalho: relógio + data | clima ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            radius: Theme.radius
            color: Theme.dashCard

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: Qt.formatTime(root.now, "HH:mm")
                    color: Theme.dashText
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 42
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: root.weekdays[root.now.getDay()] + ", " + root.now.getDate() + " de " + root.months[root.now.getMonth()]
                    color: Theme.dashSubtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // ---- Calendário + controles de brilho/volume ----
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Card do calendário
            Rectangle {
                id: calendarCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radius
                color: Theme.dashCard

                // Escala o calendário para preencher a área disponível da
                // card, mantendo a proporção e centralizando.
                CalendarView {
                    id: calendar
                    anchors.centerIn: parent
                    // ColumnLayout não herda tamanho implícito automaticamente
                    // como Item raiz — precisamos declarar explicitamente.
                    width: implicitWidth
                    height: implicitHeight
                    scale: {
                        const sx = (calendarCard.width - 24) / calendar.implicitWidth
                        const sy = (calendarCard.height - 24) / calendar.implicitHeight
                        return Math.min(sx, sy, 2.2)
                    }
                    transformOrigin: Item.Center
                }
            }

            // Card do clima (entre calendário e sliders)
            Rectangle {
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                radius: Theme.radius
                color: Theme.dashCard

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: Weather.icon
                        font.pixelSize: 30
                        color: Theme.dashText
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: Weather.ready ? Math.round(Weather.temperature) + "°C" : "—"
                        color: Theme.dashText
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pixelSize: Theme.fontSize + 6
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: Weather.condition
                        color: Theme.dashSubtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Dois cards de slider lado a lado, à direita do calendário
            RowLayout {
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                spacing: 6

                Rectangle {
                    Layout.preferredWidth: 47
                    Layout.fillHeight: true
                    radius: Theme.radius
                    color: Theme.dashCard

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Text { text: ""; color: Theme.dashSubtext; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }

                        VerticalSlider {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.preferredWidth: 24
                            value: Brightness.percent / 100
                            onMoved: v => {
                                brightnessProc.command = ["brightnessctl", "set", Math.round(v * 100) + "%"]
                                brightnessProc.running = true
                            }
                        }

                        Text {
                            text: Brightness.percent + "%"
                            color: Theme.dashText
                            font.family: Theme.fontFamily
                            font.bold: true
                            font.pixelSize: Theme.fontSize - 2
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 47
                    Layout.fillHeight: true
                    radius: Theme.radius
                    color: Theme.dashCard

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Text { text: Audio.muted ? "" : ""; color: Theme.dashSubtext; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }

                        VerticalSlider {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillHeight: true
                            Layout.preferredWidth: 24
                            value: Audio.volume / 100
                            onMoved: v => Audio.setVolume(Math.round(v * 100))
                        }

                        Text {
                            text: Audio.volume + "%"
                            color: Theme.dashText
                            font.family: Theme.fontFamily
                            font.bold: true
                            font.pixelSize: Theme.fontSize - 2
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ---- Estatísticas ----
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            rowSpacing: 8
            columnSpacing: 8

            StatTile {
                Layout.fillWidth: true
                icon: "▦"
                label: "Memória"
                value: root.showMemoryGB ? (Memory.usedGB + " GB") : (Memory.usedPercent + "%")
                onClicked: root.showMemoryGB = !root.showMemoryGB
            }

            StatTile {
                Layout.fillWidth: true
                icon: "⚙"
                label: "CPU"
                value: Cpu.usage + "%"
                showAction: false
            }

            StatTile {
                Layout.fillWidth: true
                icon: "⏱"
                label: "Tela"
                value: ScreenTime.formatted
                showAction: false
            }

            StatTile {
                Layout.fillWidth: true
                icon: ""
                label: "Bluetooth"
                value: !Bluetooth.available ? "—" : (Bluetooth.enabled ? "Ligado" : "Desligado")
                onClicked: Bluetooth.toggle()
            }
        }

        // ---- Ações rápidas ----
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ActionPill {
                Layout.fillWidth: true
                icon: "🔋"
                label: root.chargeLabel
                caption: "Carregamento"
                onClicked: ChargeModeMenu.toggle()
            }

            ActionPill {
                Layout.fillWidth: true
                icon: "⚡"
                label: root.powerLabel
                caption: "Energia"
                onClicked: PowerProfileMenu.toggle()
            }

            ActionPill {
                Layout.fillWidth: true
                danger: true
                icon: "⏻"
                label: root.powerArmed ? "Confirmar?" : "Desligar"
                caption: root.powerArmed ? "Toque de novo" : "Sistema"
                onClicked: {
                    if (root.powerArmed) {
                        powerArmTimer.stop()
                        root.powerArmed = false
                        shutdownProc.running = true
                    } else {
                        root.powerArmed = true
                        powerArmTimer.restart()
                    }
                }
            }
        }
    }

    // Slider vertical simples: trilho + preenchimento + alça.
    component VerticalSlider: Item {
        id: slider
        property real value: 0  // 0..1
        signal moved(real v)

        Rectangle {
            id: track
            anchors.centerIn: parent
            width: 8
            height: parent.height
            radius: 4
            color: Qt.rgba(0.23, 0.14, 0.13, 0.08)

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max(8, track.height * slider.value)
                radius: 4
                color: Theme.dashAccent
            }
        }

        MouseArea {
            anchors.centerIn: parent
            width: 24
            height: parent.height
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            function update(mouse) {
                slider.moved(Math.max(0, Math.min(1, 1 - mouse.y / height)))
            }
            onPressed: update(mouse)
            onPositionChanged: if (pressed) update(mouse)
        }
    }

    // Botão de ação em formato "pílula" adaptado ao tema claro da central.
    component ActionPill: Rectangle {
        id: pill
        property string icon: ""
        property string label: ""
        property string caption: ""
        property bool danger: false
        signal clicked()

        Layout.preferredHeight: 52
        radius: Theme.radiusSmall
        color: danger
            ? (mouse.containsMouse ? Qt.rgba(0.72, 0.25, 0.20, 0.18) : Qt.rgba(0.72, 0.25, 0.20, 0.08))
            : (mouse.containsMouse ? Theme.dashCardHover : Theme.dashCard)

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Text {
                text: pill.icon
                font.pixelSize: 18
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    text: pill.caption
                    color: pill.danger ? Qt.rgba(0.66, 0.26, 0.20, 0.7) : Theme.dashSubtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                }
                Text {
                    text: pill.label
                    color: pill.danger ? "#A84432" : Theme.dashText
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: Theme.fontSize - 1
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.clicked()
        }
    }
}

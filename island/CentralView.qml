import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"
import "../menus"

// Painel "central" da ilha (modo "central" em DynamicIsland.qml): data/hora
// por extenso, uso de memória (clique alterna % <-> GB) e CPU, atalhos para
// os menus de carregamento e perfil de energia, Bluetooth e desligar.
Item {
    id: root

    property bool showMemoryGB: false
    property var now: new Date()

    readonly property var weekdays: ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"]
    readonly property var months: ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // --- Hora + data por extenso ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: Qt.formatTime(root.now, "HH:mm")
                color: Theme.islandText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 12
                font.bold: true
            }

            Text {
                text: root.weekdays[root.now.getDay()] + ", " + root.now.getDate() + " de " + root.months[root.now.getMonth()]
                color: Theme.islandTextSubtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.islandSubtle
            opacity: 0.25
        }

        // --- Memória / CPU ---
        GridLayout {
            Layout.fillWidth: true
            columns: 2
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
        }

        // --- Carregamento / Perfil de energia ---
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 8
            columnSpacing: 8

            StatTile {
                Layout.fillWidth: true
                icon: ""
                label: "Carregamento"
                value: ChargeModeMenu.currentLabel
                onClicked: ChargeModeMenu.toggle()
            }

            StatTile {
                Layout.fillWidth: true
                icon: "⚡"
                label: "Energia"
                value: PowerProfileMenu.currentLabel
                onClicked: PowerProfileMenu.toggle()
            }
        }

        // --- Bluetooth / Desligar ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ActionButton {
                Layout.fillWidth: true
                icon: Bluetooth.enabled ? "" : "󰂲"
                label: Bluetooth.enabled ? "Bluetooth ligado" : "Bluetooth desligado"
                onClicked: Bluetooth.toggle()
            }

            ActionButton {
                icon: "⏻"
                danger: true
                onClicked: PowerMenu.shutdown()
            }
        }
    }
}

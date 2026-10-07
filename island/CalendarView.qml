import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"

// Mini calendário do mês atual, gerado em QML puro (sem dependências).
ColumnLayout {
    id: root

    spacing: 6
    property var today: new Date()
    readonly property var monthNames: ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"]
    readonly property var weekDays: ["D","S","T","Q","Q","S","S"]

    // Atualiza a data no tick60s do Heartbeat — sem Timer próprio.
    property Connections _todayTick: Connections {
        target: Heartbeat
        function onTick60s() { root.today = new Date() }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: monthNames[root.today.getMonth()] + " " + root.today.getFullYear()
        color: Theme.dashText
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fontSize
    }

    Grid {
        Layout.alignment: Qt.AlignHCenter
        columns: 7
        spacing: 4

        Repeater {
            model: root.weekDays
            delegate: Text {
                text: modelData
                width: 18
                horizontalAlignment: Text.AlignHCenter
                color: Theme.dashSubtext
                font.family: Theme.fontFamily
                font.pixelSize: 9
            }
        }

        Repeater {
            model: {
                const y = root.today.getFullYear(), m = root.today.getMonth()
                const firstDay = new Date(y, m, 1).getDay()
                const daysInMonth = new Date(y, m + 1, 0).getDate()
                const cells = []
                for (let i = 0; i < firstDay; i++) cells.push(0)
                for (let d = 1; d <= daysInMonth; d++) cells.push(d)
                return cells
            }
            delegate: Rectangle {
                width: 18
                height: 18
                radius: 9
                color: modelData === root.today.getDate() ? Theme.dashAccent : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: modelData === 0 ? "" : modelData
                    color: modelData === root.today.getDate() ? Theme.base : Theme.dashText
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                }
            }
        }
    }
}

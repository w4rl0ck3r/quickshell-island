import QtQuick
import "../config"

// Mini calendário do mês atual, gerado em QML puro (sem dependências).
Column {
    id: root
    spacing: 4
    property var today: new Date()
    readonly property var monthNames: ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"]
    readonly property var weekDays: ["D","S","T","Q","Q","S","S"]

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.monthNames[root.today.getMonth()] + " " + root.today.getFullYear()
        color: Theme.islandText
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: Theme.fontSize - 1
    }

    Grid {
        columns: 7
        spacing: 3
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: root.weekDays
            delegate: Text {
                text: modelData
                width: 15
                horizontalAlignment: Text.AlignHCenter
                color: Theme.islandSubtle
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
                width: 15
                height: 15
                radius: 7
                color: modelData === root.today.getDate() ? Theme.islandText : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: modelData === 0 ? "" : modelData
                    color: modelData === root.today.getDate() ? Theme.islandBg : Theme.islandTextSubtle
                    font.pixelSize: 8
                }
            }
        }
    }
}

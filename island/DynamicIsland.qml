import QtQuick
import "../config"
import "../services"

// Ilha dinâmica: relógio por padrão, calendário no hover, e um "pulso"
// visual ao clicar/atalho que dispara a busca (rofi) de forma fluida.
Item {
    id: root
    implicitWidth: bg.width
    implicitHeight: bg.height

    readonly property bool showingNotif: Notifications.current !== null
    readonly property bool showingCalendar: hoverArea.containsMouse && !showingNotif
    
    property alias maskItem: bg

    Rectangle {
        id: bg
        radius: Math.min(height / 2, 28)
        color: Theme.islandBg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        scale: pulse.running ? 1.08 : 1.0

        // width: root.expanded ? 220 : 92
        // height: root.expanded ? 150 : 30
        width: root.showingNotif ? Config.islandNotifWidth
             : root.showingCalendar ? Config.islandExpandedWidth
             : Config.islandCollapsedWidth
        height: root.showingNotif ? Config.islandNotifHeight
              : root.showingCalendar ? Config.islandExpandedHeight
              : Config.islandCollapsedHeight

        border.width: root.showingNotif && Notifications.critical ? 1 : 0
        border.color: Theme.alert

        Behavior on width { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutExpo } }
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

        Text {
            id: clockText
            visible: !root.showingNotif && ! root.showingCalendar
            anchors.centerIn: parent
            color: Theme.islandText
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: Theme.fontSize
            text: clock.timeString

            property Connections _heartbeat: Connections {
                target: Heartbeat
                function onTick1s() {
                    clock.updateTime()
                }
            }
        }

        QtObject {
            id: clock

            property string timeString: Qt.formatTime(new Date(), "HH:mm")

            property int _lastMinute: -1

            function updateTime() {
                const now = new Date()
                const currentMinute = now.getMinutes()

                if (currentMinute !== clock._lastMinute) {
                    clock._lastMinute = currentMinute
                    clock.timeString = Qt.formatTime(now, "HH:mm")
                }
            }
        }

        CalendarView {
            visible: root.showingCalendar
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }

        NotificationView {
            anchors.fill: parent
            visible: root.showingNotif
            notification: Notifications.current
            opacity: root.showingNotif ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        }

        Timer {
            id: pulse
            interval: 140
        }
    }

    Connections {
        target: Notifications
        function onCurrentChanged() {
            if (Notifications.current !== null) pulse.restart()
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: bg
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.showingNotif) {
                Notifications.dimissCurrent()
            } else {
                pulse.restart()
                Launcher.launch()
            }
        }
    }
}

pragma Singleton
import QtQuick

QtObject {
    id: root

    signal tick1s()
    signal tick3s()
    signal tick5s()
    signal tick60s()

    property int _ticks: 0

    property Timer timer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            root._ticks++

            root.tick1s()

            if (root._ticks % 3 === 0) {
                root.tick3s()
            }

            if (root._ticks % 5 === 0) {
                root.tick5s()
            }

            if (root._ticks % 60 === 0) {
                root.tick60s()
            }

            if (root._ticks >= 60) {
                root._ticks = 0
            }
        }
    }
}
pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

// Servidor de notificações + fila para a Dynamic Island.
//  - Uma notificação por vez aparece na ilha (`current`); as demais esperam
//    em `queue`.
//  - Normais somem sozinhas após 5s; críticas só somem ao clicar.
// Só uma instância de servidor pode existir no D-Bus: feche mako/dunst/swaync.
QtObject {
    id: root

    property var current: null
    property var queue: []

    readonly property bool critical: current !== null
        && current.urgency === NotificationUrgency.Critical

    property NotificationServer server: NotificationServer {
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false

        onNotification: n => root.push(n)
    }

    property Timer timer: Timer {
        interval: 5000
        repeat: false
        onTriggered: root.expireCurrent()
    }

    function push(n) {
        n.tracked = true

        // Se o app fechar a notificação por conta própria, tiramos da ilha.
        if (n.closed) n.closed.connect(() => root._remove(n))

        if (root.current === null) {
            root.current = n
            root._armTimer()
        } else {
            root.queue = root.queue.concat([n])
        }
    }

    // Clique do usuário
    function dismissCurrent() {
        const n = root.current
        if (!n) return
        n.dismiss()
        root._remove(n)
    }

    // Fim dos 5s
    function expireCurrent() {
        const n = root.current
        if (!n) return
        n.expire()
        root._remove(n)
    }

    // Idempotente: pode ser chamada pelo sinal `closed` e pelas funções acima.
    function _remove(n) {
        if (root.current === n) {
            root.current = root.queue.length > 0 ? root.queue[0] : null
            root.queue = root.queue.slice(1)
            root._armTimer()
        } else {
            root.queue = root.queue.filter(x => x !== n)
        }
    }

    function _armTimer() {
        root.timer.stop()
        if (root.current !== null && !root.critical) root.timer.restart()
    }
}

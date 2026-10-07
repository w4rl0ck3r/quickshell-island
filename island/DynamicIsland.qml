import QtQuick
import QtQuick.Shapes
import "../config"
import "../services"

// Ilha dinâmica orientada a "modos"
// Percebi que para ter vários modos com diferentes widgets preciso modificar o código para suportar 
// a criação e implementação de novos modos sem ter if/ternários em width, weight, etc...
//
// Cada modo é um item de `modes`: { name, active, width, height, component }.
// A ORDEM da lista é a prioridade — a ilha usa o primeiro modo com
// `active: true`. O último item deve ser sempre `active: true` (é o
// estado de repouso / fallback, hoje o relógio).
//
// Para adicionar um widget novo (central de notificações, painel de
// controle, player de música, launcher...), basta:
//   1. Criar o visual em island/AlgumaCoisaView.qml (ou inline aqui).
//   2. Declarar um `Component { id: algumaCoisaMode; ... }` abaixo.
//   3. Inserir um item em `modes` na posição de prioridade desejada.

Item {
    id: root
    
    implicitWidth: bg.width
    implicitHeight: bg.height

    property alias maskItem: bg

    property bool hovering: hoverHandler.hovered

    scale: pulse.running ? 1.08 : 1.0
    transformOrigin: Item.Top
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

    readonly property var modes: [
        {
            name: "notification",
            active: Notifications.current !== null,
            width: Config.islandNotifWidth,
            height: Config.islandNotifHeight,
            bg: Theme.islandBg,
            component: notificationMode
        },
        {
            name: "wallpaper",
            active: Wallpapers.active,
            width: Config.islandCentralWidth,
            height: 300,
            bg: Theme.dashBg,
            component: wallpaperMode
        },
        {
            nname: "central",
            active: root.hovering,
            width: Config.islandCentralWidth,
            height: Config.islandCentralHeight,
            bg: Theme.dashBg,
            component: centralMode
        },
        {
            name: "clock",
            active: true,
            width: Config.islandCollapsedWidth,
            height: Config.islandCollapsedHeight,
            bg: Theme.islandBg,
            component: clockMode
        }
    ]

    readonly property var mode: modes.find(m => m.active)

    Rectangle {
        id: bg
        radius: Math.min(height / 2, 28)
        color: Theme.islandBg
        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: root.mode.width
        height: root.mode.height

        // Top corners are squared off so the wings (concave arcs) below
        // can merge smoothly into the top edge of the screen.
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height / 2
            color: Theme.islandBg
        }

        border.width: root.mode.name === "notification" && Notifications.critical ? 1 : 0
        border.color: Theme.alert

        Behavior on color  { ColorAnimation  { duration: Theme.animNormal } }
        Behavior on width  { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutExpo } }

        HoverHandler {
            id:hoverHandler
        }
        // Para instanciar somente o modo ativo, o anterior é destruído
        Loader {
            anchors.fill: parent
            sourceComponent: root.mode.component
            opacity: item ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }
    }

    // Wings: concave "inverted corners" that make the island look like it
    // hangs from the top edge of the screen. Same color as the island.
    readonly property int wing: 19

    Shape {
        anchors.top: bg.top
        anchors.right: bg.left
        width: root.wing
        height: root.wing
        ShapePath {
            fillColor: Theme.islandBg
            strokeWidth: 0
            PathSvg { path: "M 0 0 L " + root.wing + " 0 L " + root.wing + " " + root.wing + " A " + root.wing + " " + root.wing + " 0 0 0 0 0 Z" }
        }
    }
    Shape {
        anchors.top: bg.top
        anchors.left: bg.right
        width: root.wing
        height: root.wing
        ShapePath {
            fillColor: Theme.islandBg
            strokeWidth: 0
            PathSvg { path: "M " + root.wing + " 0 L 0 0 L 0 " + root.wing + " A " + root.wing + " " + root.wing + " 0 0 1 " + root.wing + " 0 Z" }
        }
    }

    // ---- DEFINIÇÃO DOS MODOS ---------------------------------

    Component {
        id: clockMode
        Item {
            anchors.fill : parent

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
            
            Text {
                id: clockText
               
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

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pulse.restart()
                    Launcher.launch()
                }
            }
        } 
    }

    Component {
        id: wallpaperMode
        WallpaperView { anchors.fill: parent }
    }

    Component {
        id: centralMode
        CentralView { anchors.fill: parent }
    }

    Component {
        id: notificationMode
        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
                cursorShape: QtPointingHandCursor
                onClicked: Notifications.dimissCurrent()
            }

            NotificationView {
                anchors.fill: parent
                notification: Notifications.current
            }
        }
    }


// ---- comportamento gerla ----------------------

    Connections {
        target: Notifications
        function onCurrentChanged() {
            if (Notifications.current !== null) pulse.restart()
        }
    }

    Timer { id: pulse; interval: 140 }


}

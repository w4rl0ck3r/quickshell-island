import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"

// Pill com os ícones da bandeja do sistema. Fica com largura 0 (invisível,
// sem ocupar espaço) quando não há nenhum ícone publicado.
Rectangle {
    id: root
    visible: Tray.items.value.lenght > 0
    implicitHeight: Config.pillHeight
    implicitWidth: visible ? row.implicitWidth + 12 : 0
    radius: Theme.radiusSmall
    color: "transparent"
    clip: true

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Tray.items

            delegate: Item {
                id: iconDelegate
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                    sourceSize: Qt.size(32, 32)
                    smooth: true
                    asynchronous: true
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouseEvent => {
                        if (mouseEvent.button === Qt.LeftButton) {
                            modelData.activate()
                        } else if (mouseEvent.button === Qt.MiddleButton) {
                            modelData.secondaryActivate()
                        } else if (mouseEvent.button === Qt.RightButton) {
                            if (modelData.hasMenu && Tray.barWindow) {
                                const pos = mouse.mapToItem(null, mouseEvent.x, mouseEvent.y)
                                modelData.display(Tray.barWindow, pos.x, pos.y)
                            }
                        }
                    }

                    onWheel: wheelEvent => modelData.scroll(wheelEvent.angleDelta.y, false)
                }

                // Tooltip simples (título do app), aparece embaixo do ícone.
                Rectangle {
                    visible: mouse.containsMouse
                        && (modelData.tooltipTitle.length > 0 || modelData.title.length > 0)
                    anchors.top: parent.bottom
                    anchors.topMargin: 6
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: Theme.radiusSmall
                    color: Theme.base
                    border.color: Theme.border
                    border.width: 1
                    implicitWidth: tooltipText.implicitWidth + 16
                    implicitHeight: tooltipText.implicitHeight + 8
                    z: 10

                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: modelData.tooltipTitle.length > 0 ? modelData.tooltipTitle : modelData.title
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import "../config"

// Conteúdo da ilha quando há uma notificação: imagem/ícone, título e corpo.
Item {
    id: root
    property var notification: null

    readonly property bool critical: notification !== null
        && notification.urgency === NotificationUrgency.Critical

    // `image` pode ser caminho absoluto ou URL (image://...); `appIcon` é
    // um nome de ícone do tema.
    readonly property string imageSource: {
        if (!notification) return ""
        const img = notification.image
        if (img && img.length > 0) return img.startsWith("/") ? "file://" + img : img
        if (notification.appIcon && notification.appIcon.length > 0)
            return Quickshell.iconPath(notification.appIcon)
        return "file://home/w4rl0ck3r/.config/quickshell/assets/icons/bell-solid-full.svg"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 18
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        spacing: 12

        // Miniatura arredondada
        Item {
            id: thumb
            visible: root.imageSource.length > 0
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: img
                anchors.fill: parent
                source: root.imageSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(96, 96)
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: thumbMask
                }
            }

            Item {
                id: thumbMask
                anchors.fill: parent
                visible: false
                layer.enabled: true
                Rectangle { anchors.fill: parent; radius: 12 }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    visible: root.critical
                    width: 6; height: 6; radius: 3
                    color: Theme.statusCritical
                }

                Text {
                    Layout.fillWidth: true
                    text: root.notification ? root.notification.summary : ""
                    color: Theme.islandText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 1
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: root.notification ? root.notification.body : ""
                color: Theme.islandSubtle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                textFormat: Text.PlainText
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }
}

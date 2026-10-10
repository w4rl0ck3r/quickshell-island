import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"

// Painel de seleção de wallpapers da ilha: busca no topo + filmstrip
// com nome embaixo de cada thumb. Sem dicas de teclado na tela.
//
// Navegação (setas/Enter/Esc) via atalhos GLOBAIS (Shortcuts.qml,
// válidos só com o picker aberto) — funciona com o mouse em qualquer
// lugar, já que a barra só tem foco de teclado quando o mouse está
// sobre ela (Hyprland follow_mouse). A seleção vive no serviço
// (Wallpapers.sel) para os atalhos alcançarem sem foco na view.
//
// O deslize é animado: ListView não-interativa + Behavior com mola no
// contentX, seleção sempre centralizada.
Item {
    id: root

    onVisibleChanged: if (visible) searchInput.forceActiveFocus()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ---- Barra de busca ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            radius: Theme.radiusSmall
            color: Theme.dashCard

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text { text: "🔍"; color: Theme.dashSubtext; font.pixelSize: Theme.fontSize }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    text: Wallpapers.filter
                    color: Theme.dashText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    focus: true
                    clip: true
                    onTextChanged: {
                        Wallpapers.filter = text
                        Wallpapers.sel = 0
                    }
                }

                Text {
                    text: Wallpapers.shown.length + (Wallpapers.shown.length === 1 ? " imagem" : " imagens")
                    color: Theme.dashSubtext
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }

        // ---- Filmstrip ----
        ListView {
            id: thumbs
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            interactive: false
            model: Wallpapers.shown
            currentIndex: Wallpapers.sel
            onCurrentIndexChanged: positionViewAtIndex(Wallpapers.sel, ListView.Center)

            // O deslize programa desliza com mola em vez de pular.
            Behavior on contentX { SpringAnimation { spring: 10; damping: 0.6 } }

            delegate: Item {
                id: slot
                property int i: index

                width: 184
                height: thumbs.height

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        id: thumb
                        Layout.preferredWidth: 184
                        Layout.preferredHeight: 104
                        radius: 12
                        color: Theme.dashCard
                        border.width: Wallpapers.sel === slot.i ? 3 : 0
                        border.color: Theme.dashAccent
                        clip: true
                        scale: Wallpapers.sel === slot.i ? 1.05 : 1.0
                        opacity: (Wallpapers.shown.length === 0 || Wallpapers.sel === slot.i) ? 1.0 : 0.6

                        Behavior on scale { SpringAnimation { spring: 10; damping: 0.55 } }
                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: "file://" + Config.wallpapersDir + "/" + modelData
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(368, 208)
                            asynchronous: true
                            smooth: true
                            cache: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Wallpapers.sel = slot.i
                                Wallpapers.apply(modelData)
                            }
                        }
                    }

                    Text {
                        Layout.preferredWidth: 184
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData
                        color: Wallpapers.sel === slot.i ? Theme.dashText : Theme.dashSubtext
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}

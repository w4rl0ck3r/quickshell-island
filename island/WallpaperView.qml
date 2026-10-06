import QtQuick
import QtQuick.Layouts
import "../config"
import "../services"

// Painel de seleção de wallpapers da ilha: busca no topo, preview das
// imagens em linha, clique aplica e Setas/Enter/Esc controlam.
Item {
    id: root

    property int sel: 0

    onVisibleChanged: if (visible) searchInput.forceActiveFocus()

    // Setas / Enter / Esc precisam funcionar mesmo com foco no TextInput.
    Shortcut { sequence: "Left";  onActivated: if (root.sel > 0) root.sel-- }
    Shortcut { sequence: "Right"; onActivated: if (root.sel < Wallpapers.shown.length - 1) root.sel++ }
    Shortcut { sequence: "Return"; onActivated: if (Wallpapers.shown.length > 0) Wallpapers.apply(Wallpapers.shown[root.sel]) }
    Shortcut { sequence: "Escape"; onActivated: Wallpapers.close() }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // ---- Barra de busca ----
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: Theme.radiusSmall
            color: Theme.dashCard

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
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
                        root.sel = 0
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

        // ---- Preview em linha ----
        ListView {
            id: thumbs
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            orientation: ListView.Horizontal
            spacing: 10
            clip: true
            model: Wallpapers.shown
            currentIndex: root.sel
            onCurrentIndexChanged: positionViewAtIndex(root.sel, ListView.Contain)

            delegate: Rectangle {
                id: thumb
                width: 150
                height: 84
                radius: 12
                color: Theme.dashCard
                border.width: root.sel === index ? 2 : 0
                border.color: Theme.dashAccent
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 2
                    source: "file://" + Config.wallpapersDir + "/" + modelData
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(300, 180)
                    asynchronous: true
                    smooth: true
                    cache: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wallpapers.apply(modelData)
                }
            }
        }

        // ---- Dica / nome atual ----
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Wallpapers.shown.length > 0
                  ? (Wallpapers.shown[root.sel] + "  •  Enter aplica • Esc fecha")
                  : "Nenhum wallpaper encontrado"
            color: Theme.dashSubtext
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 2
            elide: Text.ElideMiddle
        }
    }
}

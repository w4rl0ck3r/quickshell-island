import "../components"
import "../services"

Pill {
    icon: Audio.muted ? "" : ""
    label: Audio.muted ? "" : Audio.volume + "%"
    isClickable: true
    onClicked: Audio.toggleMute()
}

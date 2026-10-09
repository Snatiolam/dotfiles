import QtQuick
import qs.config
import qs.components

// Power button: opens the centered menu.
BarButton {
    id: root

    popoutId: "power"
    activeColor: Theme.tint(Theme.red, 0.22)

    onClicked: Ui.togglePopout("power")

    Text {
        anchors.centerIn: parent
        text: Icons.power
        color: Ui.powerMenu ? Theme.red : Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
    }
}

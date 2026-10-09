import QtQuick
import qs.config
import qs.components

// Control Center button (grid). Click opens the macOS-style panel.
BarButton {
    id: root

    popoutId: "controlcenter"

    onClicked: Ui.togglePopout("controlcenter")

    Text {
        anchors.centerIn: parent
        text: Icons.sliders
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
    }
}

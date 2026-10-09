import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules

// Visual lockscreen for a single monitor, created once per screen by the
// WlSessionLock surface component in LockScreen.qml.
Rectangle {
    id: root

    required property LockContext context

    color: Theme.crust

    // ── Clock ─────────────────────────────────────────────────────
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.22
        text: Qt.formatTime(now.date, "HH:mm")
        color: Theme.text
        font.family: Theme.font
        font.pixelSize: 88
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        anchors.topMargin: 2
        text: Qt.formatDate(now.date, "dddd, d MMMM")
        color: Theme.subtext0
        font.family: Theme.font
        font.pixelSize: 17
    }

    // ── Password prompt ───────────────────────────────────────────
    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 40
        width: 320
        height: 48
        radius: Theme.radius
        color: Theme.surface0
        border.width: 1
        border.color: field.activeFocus ? Theme.mauve : Theme.surface2

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10

            Text {
                text: Icons.lock
                color: field.activeFocus ? Theme.mauve : Theme.overlay1
                font.family: Theme.font
                font.pixelSize: 16
            }

            TextInput {
                id: field
                Layout.fillWidth: true
                focus: true
                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14
                selectByMouse: true
                inputMethodHints: Qt.ImhSensitiveData

                onTextChanged: root.context.currentText = text
                onAccepted: root.context.tryUnlock()

                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    visible: field.text.length === 0
                    text: "Enter password"
                    color: Theme.overlay0
                    font: field.font
                }

                // Keep every monitor's field in sync with the shared text.
                Connections {
                    target: root.context
                    function onCurrentTextChanged(): void {
                        if (field.text !== root.context.currentText)
                            field.text = root.context.currentText;
                    }
                }
            }
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: card.bottom
        anchors.topMargin: 12
        visible: root.context.showFailure
        text: "Incorrect password"
        color: Theme.red
        font.family: Theme.font
        font.pixelSize: 13
    }

    // ── Clock ticker ──────────────────────────────────────────────
    QtObject {
        id: now
        property date date: new Date()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: now.date = new Date()
    }
}

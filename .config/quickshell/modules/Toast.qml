import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// Notification toast: appears top-right and hides itself.
PanelWindow {
    id: win

    anchors.top: true
    anchors.right: true
    margins.top: Theme.popupGap
    margins.right: 10

    exclusiveZone: 0
    aboveWindows: true
    focusable: false
    color: "transparent"

    property bool showing: false
    visible: showing

    // Copies the data so we don't depend on the Notification object's lifetime.
    property string nApp: ""
    property string nSummary: ""
    property string nBody: ""
    property int nUrgency: 0
    property var nRef: null

    implicitWidth: 360
    implicitHeight: Math.max(72, toastContent.implicitHeight + 24)

    function push(n): void {
        nRef = n;
        nApp = n.appName || "";
        nSummary = n.summary || "";
        nBody = n.body || "";
        nUrgency = n.urgency;
        showing = true;
        hideTimer.restart();
    }

    function close(): void {
        showing = false;
        const ref = nRef;
        nRef = null;
        if (ref)
            ref.dismiss();
    }

    Connections {
        target: Notifs
        function onReceived(n): void {
            if (Notifs.dnd) return;
            win.push(n);
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: win.showing = false
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Theme.cardBg
        border.width: 1
        border.color: win.nUrgency >= 2 ? Theme.red : Theme.cardBorder

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignTop
                width: 4
                height: 36
                radius: 2
                color: win.nUrgency >= 2 ? Theme.red : Theme.mauve
            }

            ColumnLayout {
                id: toastContent
                Layout.fillWidth: true
                spacing: 3

                Text {
                    Layout.fillWidth: true
                    text: win.nApp || "Application"
                    color: Theme.mauve
                    font.family: Theme.font
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: win.nSummary
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: win.nBody
                    color: Theme.subtext0
                    font.family: Theme.font
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: win.close()
        }
    }
}

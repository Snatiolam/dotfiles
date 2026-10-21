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
    property string nImage: ""
    property string nAppIcon: ""
    property int nUrgency: 0
    property var nRef: null

    // Resolved icon source, plus a secondary source used when the first one
    // cannot be loaded. Both are empty when there is nothing to show.
    property string nIconUrl: ""
    property string nIconAltUrl: ""

    implicitWidth: 360
    implicitHeight: Math.max(72, toastContent.implicitHeight + 24)

    // Quickshell draws a magenta placeholder when a themed icon does not
    // resolve, so every icon request gets a fallback icon attached.
    function themedIconUrl(name: string, fallback: string): string {
        if (name === "") return "";
        let url = "image://icon/" + name;
        if (fallback !== "" && fallback !== name)
            url += "?fallback=" + fallback;
        return url;
    }

    // A themed icon name never contains a slash; anything else is a file path.
    function iconNameOf(value: string): string {
        if (value === "" || value.indexOf("/") !== -1 || value.startsWith("file:"))
            return "";
        return value;
    }

    // Picks the best icon for a notification:
    //   1. the icon name or image attached by the app
    //   2. the app icon
    //   3. a generic "missing image" icon
    function resolveIcon(image: string, appIcon: string): void {
        // Reset first: a notification without an icon must not inherit the
        // icon of the previous one.
        nIconUrl = "";
        nIconAltUrl = "";
        const appName = iconNameOf(appIcon);

        if (image.startsWith("image://icon/")) {
            // Quickshell turned the "image-path" hint into a themed icon.
            const name = image.substring("image://icon/".length).split("?")[0];
            const fb = (appName !== "" && appName !== name) ? appName : "image-missing";
            nIconUrl = themedIconUrl(name, fb);
            nIconAltUrl = themedIconUrl(fb, "image-missing");
        } else if (image !== "") {
            // A real picture sent by the app.
            nIconUrl = image;
            nIconAltUrl = appName !== "" ? themedIconUrl(appName, "image-missing") : "";
        } else if (appName !== "") {
            // No image, but the app advertised an icon.
            nIconUrl = themedIconUrl(appName, "image-missing");
            nIconAltUrl = themedIconUrl("image-missing", "");
        } else if (appIcon !== "") {
            // The app icon was given as a path instead of a name.
            nIconUrl = appIcon;
            nIconAltUrl = themedIconUrl("image-missing", "");
        }
    }

    function push(n): void {
        nRef = n;
        nApp = n.appName || "";
        nImage = n.image || "";
        nAppIcon = n.appIcon || "";
        nSummary = n.summary || "";
        nBody = n.body || "";
        nUrgency = n.urgency;
        resolveIcon(nImage, nAppIcon);
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
        radius: Theme.popupRadius
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

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                visible: win.nIconUrl !== ""
                radius: 8
                color: Theme.surface1
                clip: true

                Image {
                    id: iconImg
                    anchors.fill: parent
                    source: win.nIconUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    // If the primary source fails to load, fall back to the
                    // secondary one. Writing to the window property keeps the
                    // binding of `source` intact.
                    onStatusChanged: {
                        if (status === Image.Error && win.nIconAltUrl !== "") {
                            const alt = win.nIconAltUrl;
                            win.nIconAltUrl = "";
                            win.nIconUrl = alt;
                        }
                    }
                }
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

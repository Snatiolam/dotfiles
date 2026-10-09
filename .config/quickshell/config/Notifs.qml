pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification server (replaces mako/dunst) + shared state.
Singleton {
    id: notifs

    signal received(var notification)

    // Focus / do-not-disturb: suppress toast popups while notifications
    // keep landing in the notification center.
    property bool dnd: false

    readonly property var server: serverObj
    readonly property int count: serverObj.trackedNotifications.values.length

    NotificationServer {
        id: serverObj
        keepOnReload: true

        onNotification: (notification) => {
            notification.tracked = true;
            notifs.received(notification);
        }
    }

    function clearAll(): void {
        const values = serverObj.trackedNotifications.values.slice();
        for (let i = 0; i < values.length; i++)
            values[i].dismiss();
    }
}

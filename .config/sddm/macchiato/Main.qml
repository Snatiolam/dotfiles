import QtQuick 2.11
import QtQuick.Controls 2.4

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#181926"

    // Catppuccin Macchiato palette
    readonly property color crust:    "#181926"
    readonly property color mantle:   "#1e2030"
    readonly property color base:     "#24273a"
    readonly property color surface0: "#363a4f"
    readonly property color surface1: "#494d64"
    readonly property color text:     "#cad3f5"
    readonly property color subtext0: "#a5adcb"
    readonly property color overlay0: "#6e738d"
    readonly property color blue:     "#8aadf4"
    readonly property color mauve:    "#c6a0f6"
    readonly property color red:      "#ed8796"

    function tryLogin() {
        if (userInput.text.trim().length === 0) {
            userInput.forceActiveFocus()
            return
        }
        if (passwordInput.text.length === 0) {
            passwordInput.forceActiveFocus()
            return
        }
        passwordInput.enabled = false
        loginButton.enabled = false
        sddm.login(userInput.text.trim(), passwordInput.text, sessionModel.currentIndex)
    }

    Image {
        id: background
        anchors.fill: parent
        source: "cat-waves.png"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        id: vignette
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#AA181926" }
            GradientStop { position: 0.45; color: "#55181926" }
            GradientStop { position: 0.7; color: "#77181926" }
            GradientStop { position: 1.0; color: "#CC181926" }
        }
    }

    // Clock
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 110
        spacing: 8

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.text
            font.pixelSize: 88
            font.weight: Font.ExtraLight
            font.family: "MonaspiceNe Nerd Font"
        }

        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.blue
            font.pixelSize: 22
            font.weight: Font.Medium
            font.family: "MonaspiceNe Nerd Font"
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var d = new Date()
                clockText.text = Qt.formatTime(d, "HH:mm")
                dateText.text = Qt.formatDate(d, "dddd, MMMM d")
            }
        }
    }

    // Login card
    Rectangle {
        id: card
        width: 440
        height: 380
        anchors.centerIn: parent
        radius: 16
        color: root.base
        opacity: 0.96

        Column {
            anchors.fill: parent
            anchors.margins: 36
            spacing: 14

            Rectangle {
                id: avatar
                width: 72
                height: 72
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 36
                color: root.mantle
                border.color: root.surface1
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: userInput.text.trim().length > 0
                          ? userInput.text.trim().charAt(0).toUpperCase()
                          : "?"
                    color: root.mauve
                    font.pixelSize: 34
                    font.bold: true
                    font.family: "MonaspiceNe Nerd Font"
                }
            }

            TextField {
                id: userInput
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 44
                placeholderText: "Username"
                placeholderTextColor: root.overlay0
                color: root.text
                font.pixelSize: 16
                font.family: "MonaspiceNe Nerd Font"
                background: Rectangle {
                    radius: 10
                    color: root.mantle
                    border.color: userInput.activeFocus ? root.blue : root.surface0
                    border.width: 1
                }
                onAccepted: tryLogin()
            }

            TextField {
                id: passwordInput
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 44
                placeholderText: "Password"
                placeholderTextColor: root.overlay0
                echoMode: TextInput.Password
                color: root.text
                font.pixelSize: 16
                font.family: "MonaspiceNe Nerd Font"
                background: Rectangle {
                    radius: 10
                    color: root.mantle
                    border.color: passwordInput.activeFocus ? root.blue : root.surface0
                    border.width: 1
                }
                onAccepted: tryLogin()
            }

            Button {
                id: loginButton
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 44
                text: "Login"
                font.family: "MonaspiceNe Nerd Font"
                font.pixelSize: 16
                font.bold: true
                contentItem: Text {
                    text: loginButton.text
                    color: root.base
                    font: loginButton.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 10
                    color: loginButton.enabled ? root.blue : root.surface1
                }
                onPressed: tryLogin()
            }

            Text {
                id: errorText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: text.length > 0
                color: root.red
                font.pixelSize: 13
                font.family: "MonaspiceNe Nerd Font"
            }
        }
    }

    Connections {
        target: sddm
        onLoginFailed: {
            passwordInput.enabled = true
            loginButton.enabled = true
            passwordInput.text = ""
            errorText.text = "Incorrect username or password"
            passwordInput.forceActiveFocus()
        }
        onLoginSucceeded: {
            Qt.quit()
        }
    }

    Component.onCompleted: {
        sessionModel.currentIndex = sessionModel.lastIndex
        userInput.text = userModel.lastUser || ""
        if (userInput.text.length > 0) {
            passwordInput.forceActiveFocus()
        } else {
            userInput.forceActiveFocus()
        }
    }
}
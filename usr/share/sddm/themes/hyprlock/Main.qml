// SDDM theme — layout mirrored from the user's hyprlock config.
// Clock + date top-right, circular avatar center-top, password field below,
// plus the login-only extras SDDM needs: session selector + power buttons.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: colBase

    // --- Palette (catppuccin mocha; config overrides via theme.conf) ---
    readonly property color colText:    config.colorText    ? config.colorText    : "#cdd6f4"
    readonly property color colAccent:  config.colorAccent  ? config.colorAccent  : "#cba6f7"
    readonly property color colBase:    config.colorBase    ? config.colorBase    : "#1e1e2e"
    readonly property color colSurface: config.colorSurface ? config.colorSurface : "#313244"
    readonly property color colRed:     config.colorRed     ? config.colorRed     : "#f38ba8"
    readonly property color colYellow:  config.colorYellow  ? config.colorYellow  : "#f9e2af"
    readonly property string fontFamily: config.fontFamily  ? config.fontFamily   : "JetBrainsMono Nerd Font"

    property int attempts: 0
    readonly property string targetUser: userModel.lastUser ? userModel.lastUser : ""

    // --- Background ---
    Image {
        id: background
        anchors.fill: parent
        source: "Backgrounds/" + (config.background ? config.background : "current_wallpaper.png")
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: true
        visible: status === Image.Ready
    }

    // --- Time (top-right) ---
    Text {
        id: timeLabel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 30
        anchors.topMargin: 30
        color: root.colText
        font.family: root.fontFamily
        font.pixelSize: 90
        text: Qt.formatTime(new Date(), "HH:mm")

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: timeLabel.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    // --- Date (below time) ---
    Text {
        anchors.right: timeLabel.right
        anchors.top: timeLabel.bottom
        anchors.topMargin: 10
        color: root.colText
        font.family: root.fontFamily
        font.pixelSize: 25
        text: Qt.formatDate(new Date(), "dddd, d MMMM yyyy")
    }

    // --- Avatar (center, above input) ---
    Rectangle {
        id: avatarRing
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -140
        width: 208
        height: 208
        radius: width / 2
        color: "transparent"
        border.color: root.colAccent
        border.width: 4

        Image {
            id: avatar
            anchors.fill: parent
            anchors.margins: 4
            source: config.avatar ? config.avatar : "Assets/avatar.jpg"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            visible: false
        }
        OpacityMask {
            anchors.fill: avatar
            source: avatar
            maskSource: Rectangle {
                width: avatar.width
                height: avatar.height
                radius: width / 2
                visible: false
            }
        }
    }

    // --- Password input ---
    Rectangle {
        id: passwordFrame
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 35
        width: 300
        height: 60
        radius: 8
        color: root.colSurface
        border.width: 4
        border.color: root.attempts > 0
            ? root.colRed
            : (keyboard.capsLock ? root.colYellow : root.colAccent)

        TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            color: root.colText
            font.family: root.fontFamily
            font.pixelSize: 20
            echoMode: TextInput.Password
            passwordCharacter: "●"
            verticalAlignment: TextInput.AlignVCenter
            focus: true
            clip: true

            Keys.onReturnPressed: root.tryLogin()
            Keys.onEnterPressed: root.tryLogin()
            Keys.onEscapePressed: passwordInput.text = ""
        }

        Text {
            anchors.fill: passwordInput
            verticalAlignment: Text.AlignVCenter
            color: root.colText
            opacity: 0.55
            font.family: root.fontFamily
            font.pixelSize: 20
            font.italic: true
            text: "  Logged in as " + root.targetUser
            visible: passwordInput.text.length === 0
        }
    }

    // --- Error text (shown only on failure) ---
    Text {
        id: errorLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordFrame.bottom
        anchors.topMargin: 15
        color: root.colRed
        font.family: root.fontFamily
        font.pixelSize: 16
        font.italic: true
        text: ""
    }

    // --- Session selector (bottom-center) ---
    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        spacing: 10

        Text {
            color: root.colText
            opacity: 0.7
            font.family: root.fontFamily
            font.pixelSize: 14
            text: "Session:"
        }

        ComboBox {
            id: sessionBox
            Layout.preferredWidth: 220
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            font.family: root.fontFamily
            font.pixelSize: 14
        }
    }

    // --- Power buttons (bottom-right) ---
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        spacing: 28

        Text {
            id: btnPower
            color: root.colText
            opacity: 0.85
            font.family: root.fontFamily
            font.pixelSize: 28
            text: ""  // nf-fa-power_off
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: btnPower.color = root.colRed
                onExited:  btnPower.color = root.colText
                onClicked: sddm.powerOff()
            }
        }

        Text {
            id: btnReboot
            color: root.colText
            opacity: 0.85
            font.family: root.fontFamily
            font.pixelSize: 28
            text: ""  // nf-fa-refresh
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: btnReboot.color = root.colYellow
                onExited:  btnReboot.color = root.colText
                onClicked: sddm.reboot()
            }
        }

        Text {
            id: btnSuspend
            color: root.colText
            opacity: 0.85
            font.family: root.fontFamily
            font.pixelSize: 28
            text: ""  // nf-fa-moon_o
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: btnSuspend.color = root.colAccent
                onExited:  btnSuspend.color = root.colText
                onClicked: sddm.suspend()
            }
        }
    }

    function tryLogin() {
        sddm.login(root.targetUser, passwordInput.text, sessionBox.currentIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.attempts += 1
            errorLabel.text = "Wrong  (" + root.attempts + ")"
            passwordInput.text = ""
            passwordInput.focus = true
        }
        function onLoginSucceeded() {
            errorLabel.text = ""
        }
    }
}

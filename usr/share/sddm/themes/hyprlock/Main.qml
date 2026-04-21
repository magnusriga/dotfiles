// SDDM theme — layout mirrored from the user's hyprlock config.
// Clock + date top-right, circular avatar center-top, password field below,
// plus the login-only extras SDDM needs: session selector + power buttons.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects

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

    // Shared sizing for the three input-like boxes (user, password, session)
    // so they stay visually locked together. Matches hyprlock's input-field:
    // 300x60, 4px outline, default rounding = -1 → half-height (pill).
    readonly property int boxWidth: 300
    readonly property int boxHeight: 60
    readonly property int boxBorder: 4
    readonly property int boxRadius: boxHeight / 2
    readonly property int boxFontSize: 20

    // Popup/menu styling for the ComboBox dropdowns. Deliberately NOT reusing
    // boxRadius: the closed ComboBox is a short pill (radius = half-height
    // reads as fully rounded), but a tall popup with the same radius blows
    // out the corners and makes per-item hover highlights look pill-shaped.
    // Use a modest outer corner + inner padding so hovered items have room
    // to breathe inside the rounded shell.
    readonly property int popupRadius: 12
    readonly property int popupItemRadius: 6
    readonly property int popupPadding: 8

    // Hover highlight: full accent is too loud behind white text; blend it
    // down with alpha so the surface shows through (reads as a muted purple).
    readonly property color colHoverBg: Qt.rgba(colAccent.r, colAccent.g, colAccent.b, 0.35)

    property int attempts: 0
    readonly property string targetUser: userBox.currentText

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
            source: userBox.currentValue ? userBox.currentValue : (config.avatar ? config.avatar : "Assets/avatar.jpg")
            fillMode: Image.PreserveAspectCrop
            smooth: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: avatar.width
                    height: avatar.height
                    radius: width / 2
                }
            }
        }
    }

    // --- User selector (between avatar and password) ---
    ComboBox {
        id: userBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: avatarRing.bottom
        anchors.topMargin: 16
        width: root.boxWidth
        height: root.boxHeight
        model: userModel
        textRole: "name"
        valueRole: "icon"
        font.family: root.fontFamily
        font.pixelSize: root.boxFontSize
        clip: true

        background: Rectangle {
            color: root.colSurface
            border.color: root.colAccent
            border.width: root.boxBorder
            radius: root.boxRadius
        }

        contentItem: Text {
            leftPadding: 20
            rightPadding: userBox.indicator.width + 20
            text: userBox.displayText
            font: userBox.font
            color: root.colText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Text {
            x: userBox.width - width - 20
            y: userBox.topPadding + (userBox.availableHeight - height) / 2
            text: "▾"
            font.family: root.fontFamily
            font.pixelSize: root.boxFontSize
            color: root.colText
        }

        delegate: ItemDelegate {
            width: userBox.width - 2 * root.popupPadding
            height: 40
            highlighted: userBox.highlightedIndex === index
            contentItem: Text {
                leftPadding: 16
                text: model[userBox.textRole]
                font: userBox.font
                color: root.colText
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                color: highlighted ? root.colHoverBg : "transparent"
                radius: root.popupItemRadius
            }
        }

        popup: Popup {
            y: userBox.height + 6
            width: userBox.width
            implicitHeight: contentItem.implicitHeight + 2 * root.popupPadding
            padding: root.popupPadding

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: userBox.popup.visible ? userBox.delegateModel : null
                currentIndex: userBox.highlightedIndex
            }

            background: Rectangle {
                color: root.colSurface
                border.color: root.colAccent
                border.width: root.boxBorder
                radius: root.popupRadius
            }
        }

        Component.onCompleted: {
            if (userModel && userModel.lastIndex !== undefined)
                currentIndex = userModel.lastIndex
        }
    }

    // --- Password input ---
    Rectangle {
        id: passwordFrame
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: userBox.bottom
        anchors.topMargin: 16
        width: root.boxWidth
        height: root.boxHeight
        radius: root.boxRadius
        color: root.colSurface
        border.width: root.boxBorder
        border.color: root.attempts > 0
            ? root.colRed
            : (keyboard.capsLock ? root.colYellow : root.colAccent)

        TextInput {
            id: passwordInput
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            color: root.colText
            font.family: root.fontFamily
            font.pixelSize: root.boxFontSize
            echoMode: TextInput.Password
            passwordCharacter: "●"
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            focus: true
            clip: true

            Keys.onReturnPressed: root.tryLogin()
            Keys.onEnterPressed: root.tryLogin()
            Keys.onEscapePressed: passwordInput.text = ""
        }

        Text {
            anchors.fill: passwordInput
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.colText
            opacity: 0.55
            font.family: root.fontFamily
            font.pixelSize: root.boxFontSize
            font.italic: true
            text: keyboard.capsLock ? "Password (Caps Lock on)" : "Password"
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

    // --- Session selector (bottom-center; plain text styled like the
    // power icons — no box, no border, just a clickable label with a ▾). ---
    ComboBox {
        id: sessionBox
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        width: 240
        height: 44
        padding: 0
        model: sessionModel
        textRole: "name"
        font.family: root.fontFamily
        font.pixelSize: 18

        background: Rectangle {
            color: "transparent"
            border.width: 0
        }

        contentItem: Text {
            text: sessionBox.displayText + "  ▾"
            font: sessionBox.font
            color: root.colText
            opacity: 0.85
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        indicator: Item { width: 0; height: 0 }

        delegate: ItemDelegate {
            width: sessionBox.popup.width - 2 * root.popupPadding
            height: 40
            highlighted: sessionBox.highlightedIndex === index
            contentItem: Text {
                leftPadding: 16
                text: model[sessionBox.textRole]
                font.family: root.fontFamily
                font.pixelSize: 18
                color: root.colText
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            background: Rectangle {
                color: highlighted ? root.colHoverBg : "transparent"
                radius: root.popupItemRadius
            }
        }

        popup: Popup {
            y: -implicitHeight - 6
            width: Math.max(sessionBox.width, 240)
            implicitHeight: contentItem.implicitHeight + 2 * root.popupPadding
            padding: root.popupPadding

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: sessionBox.popup.visible ? sessionBox.delegateModel : null
                currentIndex: sessionBox.highlightedIndex
            }

            background: Rectangle {
                color: root.colSurface
                border.color: root.colAccent
                border.width: root.boxBorder
                radius: root.popupRadius
            }
        }

        Component.onCompleted: {
            if (sessionModel && sessionModel.lastIndex !== undefined)
                currentIndex = sessionModel.lastIndex
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

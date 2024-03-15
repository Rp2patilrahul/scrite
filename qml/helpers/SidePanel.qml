/****************************************************************************
**
** Copyright (C) VCreate Logic Pvt. Ltd. Bengaluru
** Author: Prashanth N Udupa (prashanth@scrite.io)
**
** This code is distributed under GPL v3. Complete text of the license
** can be found here: https://www.gnu.org/licenses/gpl-3.0.txt
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
****************************************************************************/

import QtQuick 2.15
import QtQuick.Controls 2.15

import io.scrite.components 1.0

import "qrc:/qml/globals"
import "qrc:/qml/controls"

Item {
    id: sidePanel

    property real buttonY: 0
    property string label: ""
    property alias buttonColor: expandCollapseButton.color
    property alias backgroundColor: panelBackground.color
    property color borderColor: Runtime.colors.primary.borderColor
    property real borderWidth: 1

    property bool expanded: false
    property alias contentData: contentLoader.contentData
    property alias content: contentLoader.sourceComponent
    property alias contentInstance: contentLoader.item

    property alias cornerComponent: cornerLoader.sourceComponent

    width: expanded ? maxPanelWidth : minPanelWidth

    property real buttonSize: Math.min(100, height)
    readonly property real minPanelWidth: 25
    property real maxPanelWidth: 450
    Behavior on width {
        enabled: Runtime.applicationSettings.enableAnimations
        NumberAnimation { duration: 50 }
    }

    BorderImage {
        source: "qrc:/icons/content/shadow.png"
        anchors.fill: panelBackground
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
        anchors { leftMargin: -11; topMargin: -11; rightMargin: -10; bottomMargin: -10 }
        border { left: 21; top: 21; right: 21; bottom: 21 }
        opacity: 0.25
        visible: contentLoader.visible
    }

    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: "white"
        visible: contentLoader.visible
        opacity: contentLoader.opacity
        border.color: borderColor
        border.width: borderWidth
    }

    Item {
        id: contentLoaderArea
        anchors.top: parent.top
        anchors.left: expandCollapseButton.right
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        anchors.leftMargin: 0
        clip: true

        Rectangle {
            id: textLabelBackground
            anchors.fill: textLabel
            color: Qt.darker(expandCollapseButton.color)
            visible: textLabel.visible
            opacity: textLabel.opacity
        }

        VclText {
            id: textLabel
            anchors.top: parent.top
            text: sidePanel.label
            leftPadding: 5; rightPadding: 5
            topPadding: 8; bottomPadding: 8
            font.bold: true
            font.pixelSize: expandCollapseButton.width * 0.45
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            elide: Text.ElideRight
            opacity: contentLoader.opacity
            visible: contentLoader.visible && text !== ""
            color: Scrite.app.isLightColor(textLabelBackground.color) ? "black" : "white"
        }

        Loader {
            id: contentLoader
            anchors.topMargin: textLabel.visible ? 2 : 0
            anchors.top: textLabel.visible ? textLabel.bottom : parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            visible: opacity > 0
            opacity: sidePanel.expanded ? 1 : 0
            property var contentData
            Behavior on opacity {
                enabled: Runtime.applicationSettings.enableAnimations
                NumberAnimation { duration: 50 }
            }
            active: opacity > 0
        }
    }

    Rectangle {
        id: expandCollapseButton
        x: sidePanel.expanded ? 4 : -radius
        y: sidePanel.expanded ? 4 : parent.buttonY
        color: Runtime.colors.primary.button.background
        width: parent.minPanelWidth
        height: sidePanel.expanded ? parent.height-8 : sidePanel.buttonSize
        radius: (1.0-contentLoader.opacity) * 6
        border.width: contentLoader.visible ? 0 : 1
        border.color: sidePanel.expanded ? Runtime.colors.primary.windowColor : borderColor

        Behavior on height {
            enabled: Runtime.applicationSettings.enableAnimations
            NumberAnimation { duration: 50 }
        }

        Item {
            width: parent.width
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: sidePanel.expanded ? 0 : parent.radius/2

            Image {
                id: iconImage
                width: parent.width
                height: width
                anchors.centerIn: parent
                source: sidePanel.expanded ? "qrc:/icons/navigation/arrow_left.png" : "qrc:/icons/navigation/arrow_right.png"
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                onClicked: sidePanel.expanded = !sidePanel.expanded
                anchors.fill: parent
            }

            Loader {
                id: cornerLoader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: iconImage.top
                // anchors.topMargin: 2
                anchors.bottomMargin: 2
                anchors.leftMargin: -2
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: Math.abs(parent.x)
            width: 1
            color: borderColor
            visible: parent.x < 0
        }
    }
}

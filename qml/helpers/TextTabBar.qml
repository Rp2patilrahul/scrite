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

Item {
    id: textTabBar
    property int tabIndex: -1
    property string name: "Tabs"
    property var tabs: []
    property alias spacing: tabsRow.spacing
    height: tabsRow.height + Runtime.idealFontMetrics.descent + currentTabUnderline.height

    Row {
        id: tabsRow
        width: parent.width
        spacing: 16

        Label {
            id: nameText
            font.pointSize: Runtime.idealFontMetrics.font.pointSize
            font.family: Runtime.idealFontMetrics.font.family
            font.capitalization: Font.AllUppercase
            font.bold: true
            text: name + ": "
            rightPadding: 10
        }

        Repeater {
            id: tabsRepeater
            model: tabs

            Label {
                font: Runtime.idealFontMetrics.font
                color: textTabBar.tabIndex === index ? Runtime.colors.accent.c900.background : Runtime.colors.primary.c700.background
                text: modelData

                MouseArea {
                    anchors.fill: parent
                    onClicked: textTabBar.tabIndex = index
                }
            }
        }
    }

    ItemPositionMapper {
        id: currentTabItemPositionMapper
        from: tabsRepeater.count > 0 ? tabsRepeater.itemAt(textTabBar.tabIndex) : null
        to: textTabBar
        onMappedPositionChanged: Qt.callLater( function() { currentTabUnderline.placedOnce = true } )
    }

    Rectangle {
        id: currentTabUnderline
        x: currentTabItemPositionMapper.mappedPosition.x
        height: 2
        color: Runtime.colors.accent.c900.background
        width: currentTabItemPositionMapper.from.width
        anchors.top: tabsRow.bottom
        anchors.topMargin: Runtime.idealFontMetrics.descent
        property bool placedOnce: false
        Behavior on x {
            enabled: currentTabUnderline.placedOnce && Runtime.applicationSettings.enableAnimations
            NumberAnimation { duration: 100 }
        }
        Behavior on width {
            enabled: currentTabUnderline.placedOnce && Runtime.applicationSettings.enableAnimations
            NumberAnimation { duration: 100 }
        }
    }
}


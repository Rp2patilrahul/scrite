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
import QtQuick.Controls.Material 2.15

import io.scrite.components 1.0

import "../globals"

Button {
    id: button

    Material.background: Runtime.colors.primary.button.background
    Material.foreground: Runtime.colors.primary.button.text

    font.pointSize: Runtime.idealFontMetrics.font.pointSize

    width: Math.max(_private.textRect.width + 40, 120)
    height: Math.max(_private.textRect.height + 20, 50)

    Component {
        id: backgroundComponent

        Rectangle {
            implicitWidth: 120
            implicitHeight: 30
            color: button.down ? border.color : Runtime.colors.primary.button.background
            border.width: 1
            border.color: Qt.darker(Runtime.colors.primary.button.background,1.25)
        }
    }

    Component.onCompleted: {
        if(!Scrite.app.usingMaterialTheme) {
            background = backgroundComponent.createObject(button)
            font.pointSize = Runtime.idealFontMetrics.font.pointSize
        }
    }

    QtObject {
        id: _private

        property rect textRect: Scrite.app.boundingRect(text, font)
    }
}

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

import "qrc:/qml/globals"

GroupBox {
    id: control

    property color labelBackground: Runtime.colors.accent.c500.background
    property color labelText: Runtime.colors.accent.c500.text

    topPadding: label.height + Runtime.idealFontMetrics.height

    label: Rectangle {
        // x: control.leftPadding
        width: Math.min(labelItem.width, availableWidth)
        height: labelItem.height
        color: control.labelBackground

        VclLabel {
            id: labelItem
            padding: 5
            text: control.title
            font.bold: true
            color: control.labelText
        }
    }
}

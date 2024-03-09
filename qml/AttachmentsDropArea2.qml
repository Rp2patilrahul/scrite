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

import io.scrite.components 1.0

import "./globals"

AttachmentsDropArea {
    id: attachmentsDropArea
    enabled: !Scrite.document.readOnly
    property real noticeWidthFactor: 0.5

    property string attachmentNoticeSuffix: "Add as attachment by dropping it here."

    Rectangle {
        anchors.fill: parent
        visible: attachmentsDropArea.active
        color: Scrite.app.translucent(ScritePrimaryColors.c500.background, 0.5)

        Rectangle {
            anchors.fill: attachmentNotice
            anchors.margins: -30
            radius: 4
            color: ScritePrimaryColors.c700.background
        }

        Text {
            id: attachmentNotice
            anchors.centerIn: parent
            width: parent.width * noticeWidthFactor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: ScritePrimaryColors.c700.text
            text: parent.visible ? "<b>" + attachmentsDropArea.attachment.title + "</b><br/><br/>" + attachmentNoticeSuffix : ""
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
        }
    }
}

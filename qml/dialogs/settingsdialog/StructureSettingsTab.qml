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
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import io.scrite.components 1.0

import "qrc:/js/utils.js" as Utils
import "qrc:/qml/globals"
import "qrc:/qml/controls"
import "qrc:/qml/helpers"

PageView {
    id: root

    pagesArray: ["Options", "Story Beats"]
    currentIndex: 0
    pageContent: Loader {
        width: root.availablePageContentWidth
        height: root.availablePageContentHeight
        source: {
            var ret = "./Structure"
            switch(root.currentIndex) {
            case 0:
                ret += "Options"
                break
            case 1:
                ret += "StoryBeats"
                break
            }
            ret += "Page.qml"
            return ret
        }
    }
}

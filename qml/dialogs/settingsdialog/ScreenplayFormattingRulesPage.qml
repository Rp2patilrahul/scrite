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
import "qrc:/qml/helpers"
import "qrc:/qml/controls"

Item {
    id: root

    clip: true

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 10
        anchors.leftMargin: 0

        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 10

            spacing: 5

            VclComboBox {
                id: paragraphTypeComboBox
                Layout.fillWidth: true
                visible: layout.width >= 800
                model: GenericArrayModel {
                    array: [
                        { "key": "Heading", "value": SceneElement.Heading },
                        { "key": "Action", "value": SceneElement.Action },
                        { "key": "Character", "value": SceneElement.Character },
                        { "key": "Dialogue", "value": SceneElement.Dialogue },
                        { "key": "Parenthetical", "value": SceneElement.Parenthetical },
                        { "key": "Shot", "value": SceneElement.Shot },
                        { "key": "Transition", "value": SceneElement.Transition }
                    ]
                    objectMembers: ["key", "value"]

                    function longestKeyWidth() {
                        var ret = 0
                        for(var i=0; i<count; i++) {
                            const item = at(i)
                            ret = Math.max(ret, Runtime.idealFontMetrics.boundingRect(item.key).width)
                        }
                        return Math.ceil(ret)
                    }
                }
                textRole: "key"
                valueRole: "value"
            }

            VclComboBox {
                id: languageComboBox
                Layout.preferredWidth: model.longestKeyWidth() + 50
                model: GenericArrayModel {
                    array: Scrite.app.enumerationModelForType("SceneElementFormat", "DefaultLanguage")
                    objectMembers: ["key", "value"]

                    function longestKeyWidth() {
                        var ret = 0
                        for(var i=0; i<count; i++) {
                            const item = at(i)
                            ret = Math.max(ret, Runtime.idealFontMetrics.boundingRect(item.key).width)
                        }
                        return Math.ceil(ret)
                    }
                }
                textRole: "key"
                valueRole: "value"
                onCurrentValueChanged: {
                    _private.printElementFormat.defaultLanguage = currentValue
                    _private.displayElementFormat.defaultLanguage = currentValue
                }
            }

            VclComboBox {
                id: fontSizesComboBox
                readonly property var systemFonts: Scrite.app.systemFontInfo()
                model: systemFonts.standardSizes
                onCurrentIndexChanged: {
                    const fontSize = model[currentIndex]
                    _private.printElementFormat.setFontPointSize(fontSize)
                    _private.displayElementFormat.setFontPointSize(fontSize)
                }
            }

            RowLayout {
                spacing: 0

                SimpleToolButton {
                    id: boldButton
                    down: checked
                    iconSource: "qrc:/icons/editor/format_bold.png"
                    onClicked: {
                        checked = !checked
                        _private.printElementFormat.setFontBold(checked)
                        _private.displayElementFormat.setFontBold(checked)
                    }
                }

                SimpleToolButton {
                    id: italicsButton
                    down: checked
                    iconSource: "qrc:/icons/editor/format_italics.png"
                    onClicked: {
                        checked = !checked
                        _private.printElementFormat.setFontItalics(checked)
                        _private.displayElementFormat.setFontItalics(checked)
                    }
                }

                SimpleToolButton {
                    id: underlineButton
                    down: checked
                    iconSource: "qrc:/icons/editor/format_underline.png"
                    onClicked: {
                        checked = !checked
                        _private.printElementFormat.setFontUnderline(checked)
                        _private.displayElementFormat.setFontUnderline(checked)
                    }
                }
            }

            SimpleToolButton {
                id: textAlignment
                property int value: Qt.AlignLeft
                iconSource: {
                    switch(value) {
                    case Qt.AlignLeft:
                        return "qrc:/icons/editor/format_align_left.png"
                    case Qt.AlignHCenter:
                        return "qrc:/icons/editor/format_align_center.png"
                    case Qt.AlignRight:
                        return "qrc:/icons/editor/format_align_right.png"
                    case Qt.AlignJustify:
                        return "qrc:/icons/editor/format_align_justify.png"
                    }
                    return "qrc:/icons/editor/format_align_left.png"
                }
                onClicked: textAlignmentMenu.open()

                Item {
                    width: parent.width
                    anchors.bottom: parent.bottom

                    VclMenu {
                        id: textAlignmentMenu

                        VclMenuItem {
                            text: "Left"
                            icon.source: "qrc:/icons/editor/format_align_left.png"
                            font.bold: textAlignment.value === Qt.AlignLeft
                            onClicked: {
                                textAlignment.value = Qt.AlignLeft
                                _private.printElementFormat.textAlignment = textAlignment.value
                                _private.displayElementFormat.textAlignment = textAlignment.value
                            }
                        }

                        VclMenuItem {
                            text: "Center"
                            icon.source: "qrc:/icons/editor/format_align_center.png"
                            font.bold: textAlignment.value === Qt.AlignHCenter
                            onClicked: {
                                textAlignment.value = Qt.AlignHCenter
                                _private.printElementFormat.textAlignment = textAlignment.value
                                _private.displayElementFormat.textAlignment = textAlignment.value
                            }
                        }

                        VclMenuItem {
                            text: "Right"
                            icon.source: "qrc:/icons/editor/format_align_right.png"
                            font.bold: textAlignment.value === Qt.AlignRight
                            onClicked: {
                                textAlignment.value = Qt.AlignRight
                                _private.printElementFormat.textAlignment = textAlignment.value
                                _private.displayElementFormat.textAlignment = textAlignment.value
                            }
                        }

                        VclMenuItem {
                            text: "Justify"
                            icon.source: "qrc:/icons/editor/format_align_justify.png"
                            font.bold: textAlignment.value === Qt.AlignJustify
                            onClicked: {
                                textAlignment.value = Qt.AlignJustify
                                _private.printElementFormat.textAlignment = textAlignment.value
                                _private.displayElementFormat.textAlignment = textAlignment.value
                            }
                        }
                    }
                }
            }

            ColorToolButton {
                id: textForeground

                ToolTip.text: "Text Color"
                ToolTip.visible: containsMouse

                hoverEnabled: true
                onColorPicked: (newColor) => {
                                   textForeground.selectedColor = newColor
                                   _private.printElementFormat.textColor = newColor
                                   _private.displayElementFormat.textColor = newColor
                               }

                Rectangle {
                    anchors.centerIn: parent

                    width: Math.min(parent.width,parent.height) * 0.8
                    height: width
                    color: "white"
                    border.width: parent.colorsMenuVisible ? 2 : 0

                    VclText {
                        anchors.centerIn: parent

                        color: textForeground.selectedColor === Runtime.colors.transparent ? "black" : textForeground.selectedColor

                        font.bold: true
                        font.pixelSize: parent.height * 0.70
                        font.underline: true

                        text: "A"
                    }
                }
            }

            // FIXME: Make this visible once we figure out a way to show background colors
            ColorToolButton {
                id: textBackground

                ToolTip.text: "Background Color"
                ToolTip.visible: containsMouse

                visible: false
                hoverEnabled: true
                onColorPicked: (newColor) => {
                                   textBackground.selectedColor = newColor
                                   _private.printElementFormat.backgroundColor = newColor
                                   _private.displayElementFormat.backgroundColor = newColor
                               }

                Rectangle {
                    anchors.centerIn: parent

                    width: Math.min(parent.width,parent.height) * 0.8
                    height: width

                    border.width: parent.colorsMenuVisible ? 2 : 1
                    border.color: "black"
                    color: textBackground.selectedColor === Runtime.colors.transparent ? "white" : textBackground.selectedColor

                    VclText {
                        anchors.centerIn: parent

                        color: textForeground.selectedColor === Runtime.colors.transparent ? "black" : textForeground.selectedColor

                        font.bold: true
                        font.pixelSize: parent.height * 0.70

                        text: "A"
                    }
                }
            }

            ToolButton {
                id: textLineHeight
                property real value: 0.85
                text: "Line Height: " + Math.round(value*100) + "%"
                onClicked: textLineHeightEditor.open()
                down: textLineHeightEditor.visible

                Item {
                    width: parent.width
                    anchors.bottom: parent.bottom

                    Popup {
                        id: textLineHeightEditor
                        closePolicy: Popup.CloseOnEscape|Popup.CloseOnPressOutside
                        contentItem: SpinBox {
                            from: 25
                            to: 300
                            stepSize: 5
                            editable: true
                            value: textLineHeight.value * 100
                            onValueModified: {
                                const v = value/100
                                textLineHeight.value = v
                                _private.printElementFormat.lineHeight = v
                                _private.displayElementFormat.lineHeight = v
                            }
                        }
                    }
                }
            }

            SimpleToolButton {
                ToolTip.visible: containsMouse
                ToolTip.text: "Copy " + paragraphTypeComboBox.currentText + " properties to other paragraph types."

                hoverEnabled: true
                iconSource: "qrc:/icons/action/done_all.png"
                onClicked: {
                    displayElementFormat.applyToAll(SceneElementFormat.AllProperties)
                    printElementFormat.applyToAll(SceneElementFormat.AllProperties)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextArea {
                id: previewText

                scale: (parent.width-100)/width
                width: Scrite.document.printFormat.pageLayout.contentWidth
                anchors.centerIn: parent

                font: Scrite.document.printFormat.defaultFont
                readOnly: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                background: Item { }

                SceneDocumentBinder {
                    id: previewTextBinder
                    screenplayFormat: Scrite.document.printFormat
                    applyFormattingEvenInTransaction: true
                    scene: Scene {
                        elements: [
                            SceneElement {
                                type: SceneElement.Heading
                                text: "INT. SOMEPLACE - DAY"
                            },
                            SceneElement {
                                type: SceneElement.Action
                                text: "Dr. Rajkumar enters the club house like a boss. He makes eye contact with everybody in the room."
                            },
                            SceneElement {
                                type: SceneElement.Character
                                text: "Dr. Rajkumar"
                            },
                            SceneElement {
                                type: SceneElement.Parenthetical
                                text: "(singing)"
                            },
                            SceneElement {
                                type: SceneElement.Dialogue
                                text: "If you come today, its too early. If you come tomorrow, its too late."
                            },
                            SceneElement {
                                type: SceneElement.Shot
                                text: "EXTREME CLOSEUP on Dr. Rajkumar's smiling face."
                            },
                            SceneElement {
                                type: SceneElement.Transition
                                text: "CUT TO"
                            }
                        ]
                    }
                    textWidth: previewText.width
                    textDocument: previewText.textDocument
                    cursorPosition: -1
                    forceSyncDocument: true
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: (mouse) => {
                                   var cpos = previewText.positionAt(mouse.x, mouse.y)
                                   var sceneElement = previewTextBinder.sceneElementAt(cpos)
                                   if(sceneElement)
                                   paragraphTypeComboBox.currentIndex = paragraphTypeComboBox.model.firstIndexOf("value", sceneElement.type)
                               }

                    // This rectangle follows actively selected paragraph type in the dialog box
                    SceneElementIndicator {
                        id: activeElementIndicator

                        opacity: 0.2
                        backgroundColor: Scrite.app.translucent(Runtime.colors.accent.c600.background, 0.5)

                        function updateSceneElement() {
                            for(var i=0; i<previewTextBinder.scene.elementCount; i++) {
                                var _sceneElement = previewTextBinder.scene.elementAt(i)
                                if(_sceneElement.type === paragraphTypeComboBox.currentValue) {
                                    sceneElement = _sceneElement
                                    return
                                }
                            }
                        }

                        Component.onCompleted: {
                            updateSceneElement()
                            paragraphTypeComboBox.currentValueChanged.connect(updateSceneElement)
                        }
                    }

                    // This rectangle follows paragraph under the mouse cursor
                    SceneElementIndicator {
                        id: hoveredElementIndicator

                        property int cursorPosition: parent.containsMouse ? previewText.positionAt(parent.mouseX, parent.mouseY) : -1
                        sceneElement: previewTextBinder.sceneElementAt(cursorPosition)

                        opacity: activeElementIndicator.sceneElement === sceneElement ? 0 : 0.5
                        backgroundColor: Scrite.app.translucent(Runtime.colors.primary.c600.background, 0.5)

                        ToolTip.text: sceneElement ? sceneElement.typeAsString : ""
                        ToolTip.visible: opacity > 0 && sceneElement
                    }

                    component SceneElementIndicator : Item {
                        id: sceneElementIndicator
                        property SceneElement sceneElement
                        property rect sceneElementRect

                        property color backgroundColor: Scrite.app.translucent(Runtime.colors.accent.c600.background, 0.5)

                        property bool valid: sceneElementRect.width > 0 && sceneElementRect.height > 0
                        visible: valid
                        x: 0
                        y: valid ? previewText.topInset + previewText.topPadding + sceneElementRect.y : 0
                        width: parent.width
                        height: valid ? sceneElementRect.height : 0

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -5
                            color: parent.backgroundColor
                            radius: 5
                        }

                        Connections {
                            target: _private.printElementFormat
                            function onElementFormatChanged() {
                                Qt.callLater(sceneElementIndicator.determineSceneElementRect, true)
                            }
                        }

                        onSceneElementChanged: Qt.callLater(determineSceneElementRect)

                        function determineSceneElementRect(reload) {
                            if(reload === true)
                                previewTextBinder.reload()
                            sceneElementRect = previewTextBinder.sceneElementBoundingRect(sceneElement)
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            spacing: 20

            VclButton {
                text: "Factory Reset"
                ToolTip.text: "Restores formatting options to defaults for current document only."
                ToolTip.visible: hovered
                onClicked: {
                    Scrite.document.formatting.resetToFactoryDefaults()
                    Scrite.document.printFormat.resetToFactoryDefaults()
                }
            }

            VclButton {
                text: "Make Default"
                ToolTip.visible: hovered
                ToolTip.text: "Saves current formatting options as default for all current and future documents."
                onClicked: Scrite.document.formatting.saveAsUserDefaults()
            }
        }
    }

    // Private implementation
    QtObject {
        id: _private

        property SceneElementFormat printElementFormat: Scrite.document.printFormat.elementFormat(paragraphTypeComboBox.currentValue)
        property SceneElementFormat displayElementFormat: Scrite.document.formatting.elementFormat(paragraphTypeComboBox.currentValue)

        onPrintElementFormatChanged: {
            languageComboBox.currentIndex = languageComboBox.model.firstIndexOf("value", printElementFormat.defaultLanguageInt);
            fontSizesComboBox.currentIndex = fontSizesComboBox.model.indexOf(printElementFormat.font.pointSize)
            boldButton.checked = printElementFormat.font.bold
            italicsButton.checked = printElementFormat.font.italic
            underlineButton.checked = printElementFormat.font.underline
            textForeground.selectedColor = printElementFormat.textColor
            textBackground.selectedColor = Scrite.app.translucent(printElementFormat.backgroundColor, 4)
            textAlignment.value = printElementFormat.textAlignment
            textLineHeight.value = printElementFormat.lineHeight
        }
    }

    Component.onCompleted: {
        Scrite.document.formatting.beginTransaction();
        Scrite.document.printFormat.beginTransaction();
    }

    Component.onDestruction: {
        Scrite.document.formatting.commitTransaction();
        Scrite.document.printFormat.commitTransaction();
    }
}


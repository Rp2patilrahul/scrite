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

import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import io.scrite.components 1.0

import "./globals"

Column {
    id: formField
    spacing: 10

    property string questionKey: questionNumber
    property alias questionNumber: questionNumberText.text
    property alias question: questionText.text
    property string answer
    property string placeholderText
    property bool enableUndoRedo: true
    property rect cursorRectangle: {
        var cr = answerItemLoader.lod === answerItemLoader.eHIGH ? answerItemLoader.item.cursorRectangle : Qt.rect(0,0,1,12)
        return mapFromItem(answerItemLoader, cr.x, cr.y, cr.width, cr.height)
    }
    property bool cursorVisible: answerItemLoader.lod === answerItemLoader.eHIGH ? answerItemLoader.item.cursorVisible : false
    property TextArea textFieldItem: answerText
    property TabSequenceManager tabSequenceManager
    property bool textFieldHasActiveFocus: answerItemLoader.lod === answerItemLoader.eHIGH ? answerItemLoader.item.activeFocus : false
    property real minHeight: questionRow.height + answerArea.minHeight + spacing
    property int tabSequenceIndex: 0
    property int nrQuestionDigits: 2
    property int indentation: 0
    property int answerLength: FormQuestion.LongParagraph

    signal focusNextRequest()
    signal focusPreviousRequest()

    function assumeFocus(pos) {
        answerItemLoader.assumeFocus(pos)
    }

    Row {
        id: questionRow
        width: parent.width-indentation
        anchors.right: parent.right

        spacing: 10

        Label {
            id: questionNumberText
            font.bold: true
            font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize + 2
            horizontalAlignment: Text.AlignRight
            width: ScriteRuntime.idealFontMetrics.averageCharacterWidth * nrQuestionDigits
            anchors.top: parent.top
        }

        Label {
            id: questionText
            font.bold: true
            font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize + 2
            width: parent.width - questionNumberText.width - parent.spacing
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            anchors.top: parent.top
        }
    }

    Rectangle {
        id: answerArea
        width: questionText.width
        anchors.right: parent.right
        color: Scrite.app.translucent(ScritePrimaryColors.c100.background, 0.75)
        border.width: 1
        border.color: Scrite.app.translucent(ScritePrimaryColors.borderColor, 0.25)
        height: Math.max(minHeight, answerItemLoader.item ? answerItemLoader.item.height : 0)
        property real minHeight: (ScriteRuntime.idealFontMetrics.lineSpacing + ScriteRuntime.idealFontMetrics.descent + ScriteRuntime.idealFontMetrics.ascent) * (answerLength == FormQuestion.ShortParagraph ? 1.1 : 3)

        LodLoader {
            id: answerItemLoader
            width: answerArea.width
            height: Math.max(answerArea.minHeight-topPadding-bottomPadding, item ? item.contentHeight+20 : 0)
            lod: eLOW
            TabSequenceItem.manager: tabSequenceManager
            TabSequenceItem.sequence: tabSequenceIndex
            TabSequenceItem.onAboutToReceiveFocus: lod = eHIGH

            function assumeFocus(position) {
                if(lod === eLOW)
                    lod = eHIGH
                Qt.callLater( (pos) => { item.assumeFocus(pos) }, position )
            }

            lowDetailComponent: TextArea {
                font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: formField.answer === "" ? formField.placeholderText : formField.answer
                opacity: formField.answer === "" ? 0.5 : 1
                leftPadding: 5; rightPadding: 5
                topPadding: 5; bottomPadding: 5
                Transliterator.defaultFont: font
                Transliterator.textDocument: textDocument
                Transliterator.applyLanguageFonts: ScriteRuntime.screenplayEditorSettings.applyUserDefinedLanguageFonts
                Transliterator.spellCheckEnabled: formField.answer !== ""
                readOnly: true
                selectByMouse: false
                selectByKeyboard: false
                background: Item { }
                onPressed:  (mouse) => {
                                const position = answerItemLoader.item.positionAt(mouse.x, mouse.y)
                                answerItemLoader.assumeFocus(position)
                            }
            }

            highDetailComponent: TextArea {
                id: answerText
                font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                selectByMouse: true
                selectByKeyboard: true
                leftPadding: 5; rightPadding: 5
                topPadding: 5; bottomPadding: 5
                Transliterator.defaultFont: font
                Transliterator.textDocument: textDocument
                Transliterator.cursorPosition: cursorPosition
                Transliterator.hasActiveFocus: activeFocus
                Transliterator.applyLanguageFonts: ScriteRuntime.screenplayEditorSettings.applyUserDefinedLanguageFonts
                Transliterator.textDocumentUndoRedoEnabled: enableUndoRedo
                Transliterator.spellCheckEnabled: ScriteRuntime.screenplayEditorSettings.enableSpellCheck
                readOnly: Scrite.document.readOnly
                background: Item { }
                SpecialSymbolsSupport {
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    textEditor: answerText
                    textEditorHasCursorInterface: true
                    enabled: !Scrite.document.readOnly
                }
                UndoHandler {
                    enabled: !answerText.readOnly && answerText.activeFocus && enableUndoRedo
                    canUndo: answerText.canUndo
                    canRedo: answerText.canRedo
                    onUndoRequest: answerText.undo()
                    onRedoRequest: answerText.redo()
                }
                SpellingSuggestionsMenu2 { }
                onActiveFocusChanged: {
                    if(!activeFocus && !persistentSelection) {
                        if(dialogUnderlay.visible)
                            return
                        answerItemLoader.lod = answerItemLoader.eLOW
                    }
                }
                Component.onCompleted: {
                    forceActiveFocus()
                    enableSpellCheck()
                }
                text: formField.answer
                onTextChanged: formField.answer = text

                Keys.onUpPressed: (event) => {
                                      if(TextDocument.canGoUp())
                                          event.accepted = false
                                      else {
                                          event.accepted = true
                                          Qt.callLater(focusPreviousRequest)
                                      }
                                  }

                Keys.onDownPressed: (event) => {
                                        if(TextDocument.canGoDown())
                                            event.accepted = false
                                        else {
                                            event.accepted = true
                                            Qt.callLater(focusNextRequest)
                                        }
                                    }

                function assumeFocus(pos) {
                    forceActiveFocus()
                    cursorPosition = pos < 0 ? TextDocument.lastCursorPosition() : pos
                }
            }
        }
    }
}

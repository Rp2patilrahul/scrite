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
import io.scrite.components 1.0

import "../js/utils.js" as Utils

import "./globals"

Rectangle {
    id: crGraphView
    property alias scene: crGraph.scene
    property alias character: crGraph.character
    property alias structure: crGraph.structure
    property alias graphIsEmpty: crGraph.empty
    property bool editRelationshipsEnabled: false
    property bool showBusyIndicator: false

    signal characterDoubleClicked(string characterName, Item chNodeItem)
    signal addNewRelationshipRequest(Item sourceItem)
    signal removeRelationshipWithRequest(Character otherCharacter, Item sourceItem)

    color: Scrite.app.translucent(ScritePrimaryColors.c100.background, 0.5)
    border.width: 1
    border.color: ScritePrimaryColors.borderColor

    function resetGraph() { crGraph.reset() }
    function exportToPdf(popupSource) {
        modalDialog.closeable = false
        modalDialog.arguments = crGraph.createExporterObject()
        modalDialog.sourceComponent = exporterConfigurationComponent
        modalDialog.popupSource = popupSource
        modalDialog.active = true
    }

    CharacterRelationshipGraph {
        id: crGraph
        structure: Scrite.document.loading ? null : Scrite.document.structure
        nodeSize: Qt.size(150,150)
        maxTime: ScriteRuntime.notebookSettings.graphLayoutMaxTime
        maxIterations: ScriteRuntime.notebookSettings.graphLayoutMaxIterations
        leftMargin: 1000
        topMargin: 1000
        onUpdated: {
            Utils.execLater(crGraph, 250, function() {
                canvasScroll.animatePanAndZoom = false
                canvas.zoomFit()
                canvasScroll.animatePanAndZoom = true
                canvas.selectedNodeItem = canvas.mainCharacterNodeItem
            })
        }
    }

    onVisibleChanged: {
        if(visible) {
            canvas.reloadIfDirty()
            canvas.zoomFit()
            canvas.selectedNodeItem = canvas.mainCharacterNodeItem
        }
    }

    ScrollArea {
        id: canvasScroll
        clip: true
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: statusBar.top
        contentWidth: canvas.width * canvas.scale
        contentHeight: canvas.height * canvas.scale
        initialContentWidth: canvas.width
        initialContentHeight: canvas.height
        showScrollBars: true
        handlePinchZoom: true
        zoomOnScroll: ScriteRuntime.workspaceSettings.mouseWheelZoomsInCharacterGraph
        minimumScale: nodeItemsBoxEvaluator.itemCount > 0 ? Math.min(0.25, width/nodeItemsBoxEvaluator.width, height/nodeItemsBoxEvaluator.height) : 0.25

        function zoomOneMiddleArea() {
            nodeItemsBoxEvaluator.recomputeBoundingBox()
            var bboxCenter = nodeItemsBoxEvaluator.center
            var middleArea = Qt.rect(bboxCenter.x - canvasScroll.width/2,
                                     bboxCenter.y - canvasScroll.height/2,
                                     canvasScroll.width,
                                     canvasScroll.height)
            canvasScroll.zoomOne()
            canvasScroll.ensureVisible(middleArea)
        }

        function zoomOneToItem(item) {
            if(item === null)
                return
            var bbox = nodeItemsBoxEvaluator.boundingBox
            var itemRect = Qt.rect(item.x, item.y, item.width, item.height)
            var atBest = Qt.size(canvasScroll.width, canvasScroll.height)
            var visibleArea = Scrite.app.querySubRectangle(bbox, itemRect, atBest)
            canvasScroll.zoomFit(visibleArea)
        }

        Item {
            id: canvas
            width: 120000
            height: 120000
            transformOrigin: Item.TopLeft
            scale: canvasScroll.suggestedScale

            MouseArea {
                anchors.fill: parent
                enabled: canvas.selectedNodeItem || crGraph.dirty
                onClicked: {
                    canvas.selectedNodeItem = null;
                    canvas.reloadIfDirty();
                }
            }

            property Character activeCharacter: selectedNodeItem ? selectedNodeItem.character : null
            property Item selectedNodeItem
            property Item mainCharacterNodeItem

            Rectangle {
                id: nodeItemsBox
                x: crGraph.nodes.objectCount > 0 ? (nodeItemsBoxEvaluator.boundingBox.x - 50) : 0
                y: crGraph.nodes.objectCount > 0 ? nodeItemsBoxEvaluator.boundingBox.y - 50 : 0
                width: crGraph.nodes.objectCount > 0 ? (nodeItemsBoxEvaluator.boundingBox.width + 100) : Math.floor(Math.min(canvasScroll.width,canvasScroll.height)/100)*100
                height: crGraph.nodes.objectCount > 0 ? (nodeItemsBoxEvaluator.boundingBox.height + 100) : width
                color: Qt.rgba(0,0,0,0)
                border.width: crGraph.nodes.objectCount > 0 ? 1 : 0
                border.color: ScritePrimaryColors.borderColor
                radius: 6
            }

            BoundingBoxEvaluator {
                id: nodeItemsBoxEvaluator
            }

            function reloadIfDirty() {
                if(crGraph.dirty)
                    crGraph.reload()
            }

            function zoomFit() {
                if(nodeItemsBox.width > canvasScroll.width || nodeItemsBox.height > canvasScroll.height)
                    canvasScroll.zoomFit(Qt.rect(nodeItemsBox.x,nodeItemsBox.y,nodeItemsBox.width,nodeItemsBox.height))
                else {
                    var centerX = nodeItemsBox.x + nodeItemsBox.width/2
                    var centerY = nodeItemsBox.y + nodeItemsBox.height/2
                    var w = canvasScroll.width
                    var h = canvasScroll.height
                    var x = centerX - w/2
                    var y = centerY - h/2
                    canvasScroll.zoomFit(Qt.rect(x,y,w,h))
                }
            }

            Item {
                id: edgeItems

                Repeater {
                    id: edgeItemsRepeater
                    model: crGraph.edges
                    delegate: crGraphEdgeDelegate
                }
            }

            Item {
                id: nodeItems

                Repeater {
                    id: nodeItemsRepeater
                    model: crGraph.nodes
                    delegate: crGraphNodeDelegate
                }

                Item {
                    anchors.fill: canvas.selectedNodeItem
                    visible: canvas.selectedNodeItem

                    BoxShadow {
                        anchors.fill: floatingToolBar
                        visible: floatingToolBar.visible
                    }

                    Rectangle {
                        id: floatingToolBar
                        height: floatingToolbarLayout.height + 4
                        width: floatingToolbarLayout.width + 6
                        color: ScritePrimaryColors.windowColor
                        border.width: 1
                        border.color: ScritePrimaryColors.borderColor
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.top
                        anchors.bottomMargin: canvas.selectedNodeItem ? Math.min(canvas.selectedNodeItem.width,canvas.selectedNodeItem.height)*0.075+5 : 5
                        enabled: !removeRelationshipConfirmation.active
                        opacity: enabled ? 1 : 0.5
                        visible: canvas.activeCharacter

                        Row {
                            id: floatingToolbarLayout
                            height: 42
                            anchors.centerIn: parent

                            ToolButton3 {
                                id: floatingRefreshButton
                                onClicked: crGraph.reset()
                                iconSource: "../icons/navigation/refresh.png"
                                autoRepeat: true
                                ToolTip.text: "Refresh"
                                visible: !Scrite.document.readOnly && (crGraph.character ? crGraph.character === canvas.activeCharacter : true)
                                suggestedWidth: parent.height
                                suggestedHeight: parent.height
                            }

                            ToolButton3 {
                                id: floatingPdfExportButton
                                onClicked: crGraphView.exportToPdf(floatingPdfExportButton)
                                iconSource: "../icons/file/generate_pdf.png"
                                autoRepeat: true
                                ToolTip.text: "Export to PDF"
                                visible: !Scrite.document.readOnly && (crGraph.character ? crGraph.character === canvas.activeCharacter : true)
                                suggestedWidth: parent.height
                                suggestedHeight: parent.height
                            }

                            ToolButton3 {
                                id: floatingAddButton
                                onClicked: { canvas.reloadIfDirty(); addNewRelationshipRequest(this) }
                                iconSource: "../icons/content/add_circle_outline.png"
                                autoRepeat: false
                                ToolTip.text: "Add A New Relationship"
                                enabled: visible
                                visible: crGraph.character && (crGraph.character && crGraph.character === canvas.activeCharacter) && editRelationshipsEnabled && !Scrite.document.readOnly
                                suggestedWidth: parent.height
                                suggestedHeight: parent.height
                            }

                            ToolButton3 {
                                id: floatingDeleteButton
                                onClicked: removeRelationshipConfirmation.active = true
                                iconSource: "../icons/action/delete.png"
                                autoRepeat: false
                                ToolTip.text: canvas.activeCharacter ? ("Remove relationship with " + canvas.activeCharacter.name) : "Remove Relationship"
                                enabled: visible
                                visible: crGraph.character && canvas.activeCharacter !== crGraph.character && canvas.activeCharacter && editRelationshipsEnabled && !Scrite.document.readOnly
                                suggestedWidth: parent.height
                                suggestedHeight: parent.height
                            }
                        }
                    }
                }
                Item {
                    anchors.fill: canvas.selectedNodeItem
                    visible: canvas.selectedNodeItem
                    z: 10

                    Loader {
                        id: removeRelationshipConfirmation
                        anchors.centerIn: parent
                        active: false
                        sourceComponent: Rectangle {
                            id: removeRelationshipConfirmationItem
                            color: Scrite.app.translucent(ScritePrimaryColors.c600.background,0.85)
                            focus: true
                            width: removeRelationshipConfirmationContentLayout.width + 45
                            height: removeRelationshipConfirmationContentLayout.height + 40
                            Component.onCompleted: {
                                if(canvasScroll.zoomScale !== 1) {
                                    canvasScroll.zoomOne()
                                    zoomTimer.start()
                                } else
                                    zoom()
                            }
                            property bool initialized: false

                            function zoom() {
                                var area = mapToItem(canvas, 0, 0, width, height)
                                canvasScroll.ensureVisible(area)
                                forceActiveFocus()
                                initialized = true
                            }

                            Timer {
                                id: zoomTimer
                                running: false
                                interval: 250
                                repeat: false
                                onTriggered: removeRelationshipConfirmationItem.zoom()
                            }

                            property Item currentItem: canvas.selectedNodeItem
                            onCurrentItemChanged: if(initialized) removeRelationshipConfirmation.active = false

                            MouseArea {
                                anchors.fill: parent
                            }

                            Column {
                                id: removeRelationshipConfirmationContentLayout
                                width: buttonRow.width * 1.4
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 5
                                spacing: 40

                                Text {
                                    text: "<b>Are you sure you want to delete this relationship?</b><br/><br/>NOTE: This action cannot be undone!!"
                                    font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    color: ScritePrimaryColors.c600.text
                                }

                                Row {
                                    id: buttonRow
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 20

                                    Button2 {
                                        text: "Yes"
                                        focusPolicy: Qt.NoFocus
                                        onClicked: {
                                            removeRelationshipWithRequest(canvas.activeCharacter, this);
                                            canvas.reloadIfDirty();
                                            removeRelationshipConfirmation.active = false
                                        }
                                    }

                                    Button2 {
                                        text: "No"
                                        focusPolicy: Qt.NoFocus
                                        onClicked: removeRelationshipConfirmation.active = false
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: statusBar
        height: 30
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: ScritePrimaryColors.windowColor
        border.width: 1
        border.color: ScritePrimaryColors.borderColor
        clip: true

        Row {
            id: statusBarControls
            height: parent.height-6
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            ToolButton3 {
                iconSource: "../icons/hardware/mouse.png"
                autoRepeat: false
                ToolTip.text: "Mouse wheel currently " + (checked ? "zooms" : "scrolls") + ". Click this button to make it " + (checked ? "scroll" : "zoom") + "."
                checkable: true
                checked: ScriteRuntime.workspaceSettings.mouseWheelZoomsInCharacterGraph
                onCheckedChanged: ScriteRuntime.workspaceSettings.mouseWheelZoomsInCharacterGraph = checked
                suggestedWidth: parent.height
                suggestedHeight: parent.height
            }

            ToolButton3 {
                onClicked: {
                    canvas.reloadIfDirty()
                    var item = canvas.selectedNodeItem
                    if(item)
                        canvasScroll.zoomOneToItem(item)
                    else
                        canvasScroll.zoomOneMiddleArea()
                }
                iconSource: "../icons/navigation/zoom_one.png"
                autoRepeat: true
                ToolTip.text: "Zoom One"
                suggestedWidth: parent.height
                suggestedHeight: parent.height
            }

            ToolButton3 {
                onClicked: { canvas.reloadIfDirty(); canvas.zoomFit() }
                iconSource: "../icons/navigation/zoom_fit.png"
                autoRepeat: true
                ToolTip.text: "Zoom Fit"
                suggestedWidth: parent.height
                suggestedHeight: parent.height
            }

            ZoomSlider {
                id: zoomSlider
                from: canvasScroll.minimumScale
                to: canvasScroll.maximumScale
                stepSize: 0.0
                anchors.verticalCenter: parent.verticalCenter
                value: canvas.scale
                onSliderMoved: Qt.callLater(applyZoom)
                onZoomInRequest: canvasScroll.zoomIn()
                onZoomOutRequest: canvasScroll.zoomOut()
                height: parent.height
                function applyZoom() {
                    canvasScroll.animatePanAndZoom = false
                    canvasScroll.zoomTo(zoomLevel)
                    canvasScroll.animatePanAndZoom = true
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: crGraph.dirty

        Text {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 25
            font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
            width: parent.width * 0.65
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: "Graph will be refreshed when you use it next."
            color: ScritePrimaryColors.c900.background
        }

        MouseArea {
            anchors.fill: parent
            enabled: crGraph.busy
        }
    }

    BusyIcon {
        running: crGraph.busy || showBusyIndicator
        anchors.centerIn: parent
    }

    Component {
        id: relationshipNameEditorDialog

        Rectangle {
            property Relationship relationship
            property Character ofCharacter: relationship.direction === Relationship.OfWith ? relationship.ofCharacter : relationship.withCharacter
            property Character withCharacter: relationship.direction === Relationship.OfWith ? relationship.withCharacter : relationship.ofCharacter
            width: 800
            height: dialogLayout.height + 50

            Component.onCompleted: {
                Utils.execLater(dialogLayout, 100, function() {
                    txtRelationshipName.forceActiveFocus()
                })
            }

            Column {
                id: dialogLayout
                spacing: 30
                width: parent.width - 50
                anchors.centerIn: parent

                Text {
                    font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize + 4
                    text: "Edit Relationship"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.bold: true
                }

                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Column {
                        spacing: 10
                        width: 180

                        Rectangle {
                            width: 150; height: 150
                            color: ofCharacter.photos.length === 0 ? "white" : Qt.rgba(0,0,0,0)
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.width: 1
                            border.color: "black"

                            Image {
                                anchors.fill: parent
                                source: {
                                    if(ofCharacter.hasKeyPhoto > 0)
                                        return "file:///" + ofCharacter.keyPhoto
                                    return "../icons/content/character_icon.png"
                                }
                                fillMode: Image.PreserveAspectCrop
                                mipmap: true; smooth: true
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            text: Scrite.app.camelCased(ofCharacter.name)
                            font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
                        }
                    }

                    TextField2 {
                        id: txtRelationshipName
                        anchors.verticalCenter: parent.verticalCenter
                        text: relationship.name
                        label: "Relationship:"
                        font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
                        placeholderText: "husband of, wife of, friends with, reports to ..."
                        maximumLength: 50
                        width: 300
                        enableTransliteration: true
                        readOnly: Scrite.document.readOnly
                        onReturnPressed: doneButton.click()
                        focus: true
                    }

                    Column {
                        spacing: 10
                        width: 180

                        Rectangle {
                            width: 150; height: 150
                            color: withCharacter.photos.length === 0 ? "white" : Qt.rgba(0,0,0,0)
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.width: 1
                            border.color: "black"

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: {
                                    if(withCharacter.hasKeyPhoto > 0)
                                        return "file:///" + withCharacter.keyPhoto
                                    return "../icons/content/character_icon.png"
                                }
                                fillMode: Image.PreserveAspectCrop
                                mipmap: true; smooth: true
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            text: Scrite.app.camelCased(withCharacter.name)
                            font.pointSize: ScriteRuntime.idealFontMetrics.font.pointSize
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: Math.max(revertButton.height, doneButton.height)

                    Button {
                        id: revertButton
                        text: "Revert"
                        enabled: txtRelationshipName.text !== relationship.name
                        onClicked: {
                            txtRelationshipName.text = relationship.name
                        }
                        anchors.left: parent.left
                    }

                    Button {
                        id: doneButton
                        text: revertButton.enabled ? "Change" : "Ok"
                        enabled: txtRelationshipName.length > 0
                        onClicked: click()
                        function click() {
                            relationship.name = txtRelationshipName.text.trim()
                            modalDialog.close()
                        }
                        anchors.right: parent.right
                    }
                }
            }
        }
    }

    Component {
        id: crGraphNodeDelegate

        Rectangle {
            id: nodeItem
            property CharacterRelationshipGraphNode node: modelData
            property Character character: node.character
            x: node.rect.x
            y: node.rect.y
            z: canvas.selectedNodeItem == nodeItem ? 1 : 0
            width: node.rect.width
            height: node.rect.height
            color: character.photos.length === 0 ? Qt.tint(character.color, "#C0FFFFFF") : Qt.rgba(0,0,0,0)
            Component.onCompleted: {
                node.item = nodeItem
                if(crGraph.character === node.character)
                    canvas.mainCharacterNodeItem = nodeItem
            }

            BoundingBoxItem.evaluator: nodeItemsBoxEvaluator

            Rectangle {
                visible: character.photos.length > 0
                anchors.fill: parent
                radius: Math.min(width,height)*0.0375
                anchors.margins: -Math.min(width,height)*0.075
                color: Scrite.app.translucent(character.color, 0.15)
                border.width: 1
                border.color: Scrite.app.translucent(character.color, 0.5)
            }

            Image {
                anchors.fill: parent
                source: {
                    if(character.hasKeyPhoto > 0)
                        return "file:///" + character.keyPhoto
                    return "../icons/content/character_icon.png"
                }
                fillMode: Image.PreserveAspectCrop
                mipmap: true; smooth: true
                z: character === canvas.activeCharacter ? 1 : 0

                Rectangle {
                    anchors.fill: infoLabel
                    anchors.margins: -4
                    radius: 4
                    color: node.marked ? ScriteAccentColors.a700.background : Qt.tint(character.color, "#C0FFFFFF")
                    opacity: character.photos.length === 0 ? 1 : 0.8
                    border.width: 1
                    border.color: node.marked ? ScriteAccentColors.a700.text : "black"
                }

                Text {
                    id: infoLabel
                    width: parent.width - 30
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 15
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 10
                    maximumLineCount: 3
                    color: node.marked ? ScriteAccentColors.a700.text : "black"
                    text: {
                        var fields = []
                        fields.push("<b>" + character.name + "</b>");
                        if(character.designation !== "")
                            fields.push("<i>" + character.designation + "</i>")
                        return fields.join("<br/>")
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    border.width: character === canvas.activeCharacter ? 3 : 1
                    border.color: character === canvas.activeCharacter ? "black" : ScritePrimaryColors.borderColor
                    color: Qt.rgba(1,1,1,alpha)
                    property real alpha: {
                        if(!canvas.activeCharacter || character === canvas.activeCharacter)
                            return 0
                        return character.isDirectlyRelatedTo(canvas.activeCharacter) ? 0 : 0.75
                    }
                    Behavior on alpha {
                        enabled: ScriteRuntime.applicationSettings.enableAnimations
                        NumberAnimation { duration: 250 }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                drag.target: !Scrite.document.readOnly ? parent : null
                drag.axis: Drag.XAndYAxis
                hoverEnabled: true
                onPressed: {
                    canvasScroll.interactive = false
                    canvas.selectedNodeItem = parent
                    canvas.reloadIfDirty()
                }
                onReleased: canvasScroll.interactive = true
                onDoubleClicked: characterDoubleClicked(character.name, parent)
                ToolTip.text: (crGraph.character && character.name === crGraph.character.name) ?
                              "Double click to add a relationship to this character." :
                              "Double click to switch to " + character.name + "'s notes."
                ToolTip.delay: 1500
                ToolTip.visible: containsMouse && !removeRelationshipConfirmation.active && !pressed
            }
        }
    }

    Component {
        id: crGraphEdgeDelegate

        PainterPathItem {
            outlineWidth: Scrite.app.devicePixelRatio * canvas.scale * ScriteRuntime.structureCanvasSettings.lineWidthOfConnectors
            outlineColor: ScritePrimaryColors.c700.background
            renderType: PainterPathItem.OutlineOnly
            renderingMechanism: PainterPathItem.UseOpenGL
            opacity: {
                if(canvas.activeCharacter)
                    return (modelData.relationship.of === canvas.activeCharacter || modelData.relationship.withCharacter === canvas.activeCharacter) ? 1 : 0.2
                return 1
            }
            z: opacity
            Behavior on opacity {
                enabled: ScriteRuntime.applicationSettings.enableAnimations
                NumberAnimation { duration: 250 }
            }

            property string pathString: modelData.pathString
            onPathStringChanged: setPathFromString(pathString)

            Rectangle {
                x: modelData.labelPosition.x - width/2
                y: modelData.labelPosition.y - height/2
                rotation: modelData.labelAngle
                width: nameLabel.width + 10
                height: nameLabel.height + 4
                color: nameLabelMouseArea.containsMouse ? ScriteAccentColors.c700.background : ScritePrimaryColors.c700.background

                Text {
                    id: nameLabel
                    text: modelData.relationship.name
                    font.pointSize: Math.floor(ScriteRuntime.idealFontMetrics.font.pointSize*0.75)
                    anchors.centerIn: parent
                    color: nameLabelMouseArea.containsMouse ? ScriteAccentColors.c700.text : ScritePrimaryColors.c700.text
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: nameLabelMouseArea
                    hoverEnabled: enabled
                    anchors.fill: parent
                    enabled: !Scrite.document.readOnly
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        modalDialog.closeable = false
                        modalDialog.popupSource = parent
                        modalDialog.initItemCallback = function(item) {
                            item.relationship = modelData.relationship
                        }
                        modalDialog.sourceComponent = relationshipNameEditorDialog
                        modalDialog.active = true
                    }
                }
            }
        }
    }
}



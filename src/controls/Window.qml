/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 6.0
import QtQuick.Window 6.0

// 注意：不要在此 import QtQuick.Controls 6.0。
// 当 QT_QUICK_CONTROLS_STYLE=fish-style 时，import QtQuick.Controls 会初始化
// QtQuick.Controls 主题系统，导致本 QtQuick.Window 的整个场景内容不上屏（窗口全透明）。
// 本文件不使用任何 QtQuick.Controls 控件（窗口头按钮为 FishUI.Item 组件），故无需该 import。
import QtQuick.Layouts 6.0
import QtQuick.Shapes 1.12
import Qt5Compat.GraphicalEffects 6.0
import FishUI 1.0 as FishUI

Window {
    id: control
    width: 640
    height: 480
    visible: true
    flags: Qt.FramelessWindowHint
    color: "transparent"

    default property alias content : _content.data
    property alias background: _background
    property alias header: _header
    property alias headerBackground: _headerBackground
    property Item headerItem

    // Window helper
    property alias compositing: windowHelper.compositing
    property var contentTopMargin: _header.height
    property var windowRadius: compositing ? FishUI.Theme.windowRadius : 0
    property alias helper: windowHelper

    // Other
    property bool isMaximized: control.visibility === Window.Maximized
    property bool isFullScreen: control.visibility === Window.FullScreen
    property var edgeSize: windowRadius <= 0 ? 8 : windowRadius / 2

    // Resize
    property bool widthResizable: maximumWidth > minimumWidth
    property bool heightResizable: maximumHeight > minimumHeight

    // 拉伸优化：窗口尺寸持续变化(用户拉伸/程序调整)期间置 true，
    // 此时禁用 layer(FBO离屏渲染)+圆角遮罩，尺寸稳定 300ms 后恢复。
    // 避免每次拉伸都触发全场景 FBO 重渲染 + OpacityMask，在虚拟GPU/慢机器上尤其卡顿。
    property bool resizing: false

    property bool minimizeButtonVisible: true

    onHeaderItemChanged: {
        if (headerItem) {
            headerItem.parent = _headerContent
            headerItem.anchors.fill = _headerContent
        }
    }

    FishUI.WindowHelper {
        id: windowHelper
    }

    // Window shadows
    FishUI.WindowShadow {
        view: control
        radius: _background.radius
        strength: control.active ? 1.5 : 0.9
    }

    // 尺寸变化 → 进入"拉伸中"状态并重启空闲定时器；
    // 尺寸连续变化时 resizing 保持 true，尺寸稳定 300ms 后恢复圆角/layer。
    onWidthChanged: _onResizeTick()
    onHeightChanged: _onResizeTick()

    function _onResizeTick() {
        resizing = true
        _resizeIdleTimer.restart()
    }

    Timer {
        id: _resizeIdleTimer
        interval: 300
        repeat: false
        onTriggered: control.resizing = false
    }

    // ========== 窗口缩放边缘 ==========
    // 使用 DragHandler + windowHelper.startSystemResize()。
    // ⚠ 关键：不能在 QML 中使用 QCursor（C++ 类，QML 默认不可用）！
    // 之前用 QCursor.pos() 导致 Window.qml 加载时报 ReferenceError，
    // 使所有 FishUI.Window 应用崩溃 → 黑屏。这里必须用 DragHandler。
    // DragHandler 激活时 Qt grab 已建立，windowHelper.startSystemResize()
    // 会交给窗口管理器处理缩放。热区 z:999 防止被内容区覆盖。

    // Right bottom corner
    Item {
        id: bottomRightResizeArea
        width: edgeSize * 2
        height: edgeSize * 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 999
        visible: !isMaximized && !isFullScreen
                 && control.widthResizable
                 && control.heightResizable

        DragHandler {
            id: bottomRightResize
            target: null
            cursorShape: Qt.SizeFDiagCursor
            onActiveChanged: if (active) {
                windowHelper.startSystemResize(control, Qt.RightEdge | Qt.BottomEdge)
            }
        }
    }

    // Bottom edge
    Item {
        id: bottomResizeArea
        height: edgeSize
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: edgeSize * 2
        anchors.rightMargin: edgeSize * 2
        z: 999
        visible: !isMaximized && !isFullScreen && control.heightResizable

        DragHandler {
            id: bottomResize
            target: null
            cursorShape: Qt.SizeVerCursor
            onActiveChanged: if (active) {
                windowHelper.startSystemResize(control, Qt.BottomEdge)
            }
        }
    }

    // Right edge
    Item {
        id: rightResizeArea
        width: edgeSize
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: edgeSize * 2
        anchors.bottomMargin: edgeSize * 2
        z: 999
        visible: !isMaximized && !isFullScreen && control.widthResizable

        DragHandler {
            id: rightResize
            target: null
            cursorShape: Qt.SizeHorCursor
            onActiveChanged: if (active) {
                windowHelper.startSystemResize(control, Qt.RightEdge)
            }
        }
    }

    // Left bottom corner
    Item {
        id: bottomLeftResizeArea
        width: edgeSize * 2
        height: edgeSize * 2
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        z: 999
        visible: !isMaximized && !isFullScreen
                 && control.widthResizable
                 && control.heightResizable

        DragHandler {
            id: bottomLeftResize
            target: null
            cursorShape: Qt.SizeBDiagCursor
            onActiveChanged: if (active) {
                windowHelper.startSystemResize(control, Qt.LeftEdge | Qt.BottomEdge)
            }
        }
    }

    // Left edge
    Item {
        id: leftResizeArea
        width: edgeSize
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: edgeSize * 2
        anchors.bottomMargin: edgeSize * 2
        z: 999
        visible: !isMaximized && !isFullScreen && control.widthResizable

        DragHandler {
            id: leftResize
            target: null
            cursorShape: Qt.SizeHorCursor
            onActiveChanged: if (active) {
                windowHelper.startSystemResize(control, Qt.LeftEdge)
            }
        }
    }

    // Top edge
    Item {
        id: topResizeArea
        height: edgeSize
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: edgeSize * 2
        anchors.rightMargin: edgeSize * 2
        z: 999
        visible: !isMaximized && !isFullScreen && control.heightResizable

        DragHandler {
            id: topResize
            target: null
            cursorShape: Qt.SizeVerCursor
            onActiveChanged: if (active) {
                windowHelper.startSystemResize(control, Qt.TopEdge)
            }
        }
    }

    // Background
    Rectangle {
        id: _background
        anchors.fill: parent
        anchors.margins: 0
        radius: !isMaximized && !isFullScreen && windowHelper.compositing && !control.resizing ? control.windowRadius : 0
        color: FishUI.Theme.backgroundColor
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    // Border line
    Rectangle {
        anchors.fill: parent

        property var borderColor: compositing ? FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                                      : Qt.rgba(0, 0, 0, 0.2) : FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                                                                                                      : Qt.rgba(0, 0, 0, 0.15)
        color: "transparent"
        radius: control.resizing ? 0 : control.windowRadius
        border.color: borderColor
        border.width: 1 / Screen.devicePixelRatio
        border.pixelAligned: Screen.devicePixelRatio > 1 ? false : true
        antialiasing: true
        visible: !isMaximized && !isFullScreen
        z: 999
    }

    // Content
    Item {
        id: _contentItem
        anchors.fill: parent

        // Header
        Item {
            id: _header
            z: 2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 35

            property int buttonSize: 31
            property int spacing: (_header.height - _header.buttonSize) / 2

            Rectangle {
                id: _headerBackground
                anchors.fill: parent
                color: "transparent"
            }

            TapHandler {
                enabled: !control.isFullScreen
                onTapped: if (tapCount === 2) toggleMaximized()
                gesturePolicy: TapHandler.DragThreshold
            }

        DragHandler {
            target: null
            // Qt6中PointerDevice枚举可能已更改，使用默认值
            // acceptedDevices: PointerDevice.GenericPointer
            grabPermissions: DragHandler.TakeOverForbidden
            onActiveChanged: if (active) { windowHelper.startSystemMove(control) }
        }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    id: _headerContent
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: FishUI.Units.smallSpacing
                    Layout.alignment: Qt.AlignTop

                    // Window buttons
                    RoundImageButton {
                        size: _header.buttonSize
                        source: "qrc:/fishui/kit/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "minimize.svg"
                        onClicked: windowHelper.minimizeWindow(control)
                        visible: control.minimizeButtonVisible
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: _header.spacing
                        image.smooth: false
                        image.antialiasing: true
                        iconMargins: 2
                    }

                    RoundImageButton {
                        size: _header.buttonSize
                        source: "qrc:/fishui/kit/images/" +
                            (FishUI.Theme.darkMode ? "dark/" : "light/") +
                            (control.visibility === Window.Maximized ? "restore.svg" : "maximize.svg")
                        onClicked: control.toggleMaximized()
                        visible: !control.isFullScreen &&  control.minimumWidth !== control.maximumWidth && control.maximumHeight !== control.minimumHeight
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: _header.spacing
                        image.smooth: false
                        image.antialiasing: true
                        iconMargins: 2
                    }

                    RoundImageButton {
                        size: _header.buttonSize
                        source: "qrc:/fishui/kit/images/" + (FishUI.Theme.darkMode ? "dark/" : "light/") + "close.svg"
                        onClicked: control.close()
                        // visible: !control.isFullScreen
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: _header.spacing
                        image.smooth: false
                        image.antialiasing: true
                        iconMargins: 2
                    }
                }

                Item {
                    width: _header.spacing
                }
            }
        }

        // Content item.
        ColumnLayout {
            id: _contentLayout
            anchors.fill: parent
            anchors.topMargin: control.contentTopMargin
            spacing: 0

            Item {
                id: _content
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        // Mask：fishui 侧真圆角（无黑角）。拉伸期间临时禁用 layer(FBO) 以保持流畅，
        // 尺寸稳定后自动恢复圆角。
        // 软件渲染（QSG software）下 layer(FBO)+OpacityMask 会导致整个内容区无法上屏
        // （窗口只剩背景和边框），因此软件渲染时必须禁用 layer（同时放弃圆角裁剪）。
        layer.enabled: !control.resizing && _background.radius > 0 && !windowHelper.softwareRendering
        layer.effect: OpacityMask {
            maskSource: Item {
                width: _contentItem.width
                height: _contentItem.height

                Rectangle {
                    anchors.fill: parent
                    radius: _background.radius
                }
            }
        }
    }

    QtObject {
        id: internal
        property QtObject passiveNotification
    }

    function showPassiveNotification(message, timeout, actionText, callBack) {
        if (!internal.passiveNotification) {
            var component = Qt.createComponent("qrc:/fishui/kit/Toast.qml")
            internal.passiveNotification = component.createObject(control)
        }

        internal.passiveNotification.showNotification(message, timeout, actionText, callBack)
    }

    function toggleMaximized() {
        if (isMaximized) {
            control.showNormal();
        } else {
            control.showMaximized();
        }
    }
}

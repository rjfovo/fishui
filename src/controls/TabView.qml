/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     Reion Wong <reion@cutefishos.com>
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
import QtQml 6.0
import QtQuick.Window 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import FishUI 1.0 as FishUI

Container {
    id: control

    spacing: 0

    contentItem: ColumnLayout {
        spacing: 0

        ListView {
            id: _view
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: false
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            currentIndex: control.currentIndex

            model: control.contentModel

            boundsBehavior: Flickable.StopAtBounds
            boundsMovement :Flickable.StopAtBounds

            spacing: 0

            preferredHighlightBegin: 0
            preferredHighlightEnd: width

            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 0
            highlightFollowsCurrentItem: true
            highlightResizeDuration: 0
            highlightMoveVelocity: -1
            highlightResizeVelocity: -1

            maximumFlickVelocity: 4 * width

            // 修复 Binding loop：cacheBuffer 依赖 count，count 变化又触发
            // cacheBuffer 重算（TabView.qml:35 的 warning）。TabView 内容项不多，
            // 无需预缓冲，置 0 即可。
            cacheBuffer: 0
            keyNavigationEnabled : false
            keyNavigationWraps : false
        }
    }

    function closeTab(index) {
        control.removeItem(control.takeItem(index))
        control.currentItemChanged()

        if (control.currentItem)
            control.currentItem.forceActiveFocus()
    }

    function addTab(component, properties) {
        // parent 不能传 control.contentModel：它是 QAbstractListModel（非可视 QObject），
        // 作为 Item 的 parent 会导致项不在场景里（parent=null、尺寸 0、编辑区空白）。
        // 先以 TabView 为 parent 创建，再通过 addItem() 由 Container 内部
        // reparent 到 contentItem(ListView) 并进入场景。
        const object = component.createObject(control, properties)

        if (object) {
            // 强制标签项尺寸跟随 TabView：Container 会把 contentModel 项包装进一个
            // 宽度为 0 的中间容器（父链上出现 0 宽节点），标签项若绑定 parent.width
            // 会得到 0（编辑区空白）。这里显式绑定到 TabView 尺寸。
            object.width = Qt.binding(function() { return control.width })
            object.height = Qt.binding(function() { return control.height })
        }

        control.addItem(object)
        control.currentIndex = Math.max(control.count - 1, 0)
        object.forceActiveFocus()

        return object
    }
}

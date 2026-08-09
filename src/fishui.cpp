/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     cutefish <cutefishos@foxmail.com>
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

#include "fishui.h"
#include "thememanager.h"
#include "iconthemeprovider.h"
#include "shadowhelper/windowshadow.h"
#include "blurhelper/windowblur.h"
#include "windowhelper.h"
#include "newiconitem.h"
#include "wheelhandler.h"
#include "qqmlsortfilterproxymodel.h"

#include "desktop/menupopupwindow.h"

#include <QDebug>
#include <QQmlEngine>
#include <QQuickStyle>

void FishUI::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("FishUI"));

    // Set base URL to the plugin URL
    engine->setBaseUrl(baseUrl());

    // For system icons
    engine->addImageProvider(QStringLiteral("icontheme"), new IconThemeProvider());

    // 强制 Qt Quick Controls 使用 fish-style 主题：
    // cutefish-session 设置了 QT_STYLE_OVERRIDE=cutefish，而 QQuickStyle 解析时
    // 优先使用 QGuiApplicationPrivate::styleOverride（来自 QT_STYLE_OVERRIDE），
    // 导致所有 QML 应用的 Qt Quick Controls 走“cutefish”这个不存在的 QML 样式模块，
    // 最终回退到 Basic（看起来就是“默认 demo 样式”）。这里显式指定样式，优先级更高。
    QQuickStyle::setStyle(QStringLiteral("fish-style"));
}

void FishUI::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("FishUI"));

    qmlRegisterSingletonType<ThemeManager>("FishUI.Core", 1, 0, "ThemeManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return new ThemeManager;
    });

    qmlRegisterType<WindowShadow>(uri, 1, 0, "WindowShadow");
    qmlRegisterType<WindowBlur>(uri, 1, 0, "WindowBlur");
    qmlRegisterType<WindowHelper>(uri, 1, 0, "WindowHelper");
    qmlRegisterType<NewIconItem>(uri, 1, 0, "IconItem");
    qmlRegisterType<MenuPopupWindow>(uri, 1, 0, "MenuPopupWindow");
    qmlRegisterType<WheelHandler>(uri, 1, 0, "WheelHandler");
    qmlRegisterType<QQmlSortFilterProxyModel>(uri, 1, 0, "SortFilterProxyModel");

    qmlRegisterSingletonType<MenuManager>(uri, 1, 0, "MenuManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return new MenuManager;
    });

    qmlRegisterSingletonType(componentUrl(QStringLiteral("Theme.qml")), uri, 1, 0, "Theme");
    qmlRegisterSingletonType(componentUrl(QStringLiteral("Units.qml")), uri, 1, 0, "Units");

    qmlRegisterType(componentUrl(QStringLiteral("AboutDialog.qml")), uri, 1, 0, "AboutDialog");
    qmlRegisterType(componentUrl(QStringLiteral("ActionTextField.qml")), uri, 1, 0, "ActionTextField");    
    qmlRegisterType(componentUrl(QStringLiteral("BusyIndicator.qml")), uri, 1, 0, "BusyIndicator");
    qmlRegisterType(componentUrl(QStringLiteral("Icon.qml")), uri, 1, 0, "Icon");
    qmlRegisterType(componentUrl(QStringLiteral("PopupTips.qml")), uri, 1, 0, "PopupTips");
    qmlRegisterType(componentUrl(QStringLiteral("RoundedRect.qml")), uri, 1, 0, "RoundedRect");
    qmlRegisterType(componentUrl(QStringLiteral("TabBar.qml")), uri, 1, 0, "TabBar");
    qmlRegisterType(componentUrl(QStringLiteral("TabButton.qml")), uri, 1, 0, "TabButton");
    qmlRegisterType(componentUrl(QStringLiteral("TabCloseButton.qml")), uri, 1, 0, "TabCloseButton");
    qmlRegisterType(componentUrl(QStringLiteral("TabView.qml")), uri, 1, 0, "TabView");
    qmlRegisterType(componentUrl(QStringLiteral("Toast.qml")), uri, 1, 0, "Toast");
    qmlRegisterType(componentUrl(QStringLiteral("Window.qml")), uri, 1, 0, "Window");
    qmlRegisterType(componentUrl(QStringLiteral("RoundImageButton.qml")), uri, 1, 0, "RoundImageButton");
    qmlRegisterType(componentUrl(QStringLiteral("DesktopMenu.qml")), uri, 1, 0, "DesktopMenu");
    qmlRegisterType(componentUrl(QStringLiteral("MenuItem.qml")), uri, 1, 0, "MenuItem");
    qmlRegisterType(componentUrl(QStringLiteral("MenuSeparator.qml")), uri, 1, 0, "MenuSeparator");

    qmlProtectModule(uri, 1);
}

QUrl FishUI::componentUrl(const QString &fileName) const
{
    return QUrl(QStringLiteral("qrc:/fishui/kit/") + fileName);
}

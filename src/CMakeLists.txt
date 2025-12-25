set(TARGET FishUI)
set(MODULE_VERSION "1.0")

add_library(${TARGET} SHARED "")
target_sources(${TARGET} PRIVATE
    fishui.cpp
    iconthemeprovider.cpp
    thememanager.cpp

    newiconitem.cpp
    managedtexturenode.cpp
    wheelhandler.cpp
    qqmlsortfilterproxymodel.cpp

    desktop/menupopupwindow.cpp

    fishui.qrc
    fish-style/style.qrc
)

if (MSVC)
    target_sources(${TARGET} PRIVATE
        platforms/windows/windowhelper.cpp platforms/windows/windowhelper.h
        platforms/windows/blurhelper/windowblur.cpp platforms/windows/blurhelper/windowblur.h
        platforms/windows/shadowhelper/boxshadowrenderer.cpp platforms/windows/shadowhelper/boxshadowrenderer.h
        platforms/windows/shadowhelper/tileset.cpp platforms/windows/shadowhelper/tileset.h
        platforms/windows/shadowhelper/windowshadow.cpp platforms/windows/shadowhelper/windowshadow.h
    )
    target_include_directories(${TARGET} PRIVATE platforms/windows)
elseif (APPLE)
    target_sources(${TARGET} PRIVATE
        platforms/mac/windowhelper.cpp platforms/mac/windowhelper.h
        platforms/mac/blurhelper/windowblur.cpp platforms/mac/blurhelper/windowblur.h
        platforms/mac/shadowhelper/boxshadowrenderer.cpp platforms/mac/shadowhelper/boxshadowrenderer.h
        platforms/mac/shadowhelper/tileset.cpp platforms/mac/shadowhelper/tileset.h
        platforms/mac/shadowhelper/windowshadow.cpp platforms/mac/shadowhelper/windowshadow.h
    )
    target_include_directories(${TARGET} PRIVATE platforms/mac)
else()
    target_sources(${TARGET} PRIVATE
        platforms/linux/windowhelper.cpp platforms/linux/windowhelper.h
        platforms/linux/blurhelper/windowblur.cpp platforms/linux/blurhelper/windowblur.h
        platforms/linux/shadowhelper/boxshadowrenderer.cpp platforms/linux/shadowhelper/boxshadowrenderer.h
        platforms/linux/shadowhelper/tileset.cpp platforms/linux/shadowhelper/tileset.h
        platforms/linux/shadowhelper/windowshadow.cpp platforms/linux/shadowhelper/windowshadow.h
    )
    target_include_directories(${TARGET} PRIVATE platforms/linux)
endif()

# -------------------------
# Link to Qt6/KF6 targets
# -------------------------
# 必要的 Qt6 组件（顶层 CMakeLists 通常会 find_package(Qt6 ...)）
target_link_libraries(${TARGET}
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::DBus
        Qt6::Widgets
    PRIVATE
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

# 移除对 GuiPrivate 的依赖（这是私有模块，发行版通常不提供）
# 可选：在 UNIX (非 macOS) 上，尝试链接 X11Extras / KF6::WindowSystem（如果可用）
if (UNIX AND NOT APPLE)
    # 对 Qt6::X11Extras 做兼容检测（某些平台/打包不会提供）
    find_package(Qt6 COMPONENTS X11Extras QUIET)
    if (TARGET Qt6::X11Extras)
        target_link_libraries(${TARGET} PRIVATE Qt6::X11Extras)
    endif()

    # KF6 WindowSystem（如果顶层已经 find_package(KF6WindowSystem) 则会有目标）
    find_package(KF6WindowSystem QUIET)
    if (TARGET KF6::WindowSystem)
        target_link_libraries(${TARGET} PRIVATE KF6::WindowSystem)
    endif()
endif()

# 生成导出头
include(GenerateExportHeader)
generate_export_header(${TARGET} BASE_NAME ${TARGET})

# 安装规则
# INSTALL_QMLDIR 期望由顶层 CMake 提供（如果没有则回退到常见的 qml 安装位置）
if (NOT DEFINED INSTALL_QMLDIR OR INSTALL_QMLDIR STREQUAL "")
    # 保守回退：使用 CMAKE_INSTALL_DATAROOTDIR/qml/<target>
    if (NOT DEFINED CMAKE_INSTALL_DATAROOTDIR)
        set(CMAKE_INSTALL_DATAROOTDIR "${CMAKE_INSTALL_PREFIX}/share")
    endif()
    set(INSTALL_QMLDIR "${CMAKE_INSTALL_DATAROOTDIR}/qml")
endif()

# 设置QML模块属性
set_target_properties(${TARGET} PROPERTIES
    QT_QML_MODULE_VERSION "${MODULE_VERSION}"
    QT_QML_MODULE_URI "FishUI"
)

install(TARGETS ${TARGET} EXPORT ${TARGET}Targets ${INSTALL_TARGETS_DEFAULT_ARGS})
install(TARGETS ${TARGET} DESTINATION ${INSTALL_QMLDIR}/FishUI)

# Install Controls (QML modules)
install(DIRECTORY controls/ DESTINATION ${INSTALL_QMLDIR}/FishUI)

# 确保 qmldir 文件被正确安装到 FishUI 目录
install(FILES controls/qmldir DESTINATION ${INSTALL_QMLDIR}/FishUI)

# INSTALL STYLE
# 把 fish-style 作为 Controls.2 下的样式内容安装（保留与原来相同的路径结构）
install(DIRECTORY fish-style DESTINATION ${INSTALL_QMLDIR}/QtQuick/Controls.2)
# 确保 qmldir 文件被正确安装
install(FILES fish-style/qmldir DESTINATION ${INSTALL_QMLDIR}/QtQuick/Controls.2/fish-style)

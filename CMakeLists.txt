cmake_minimum_required(VERSION 3.16)

set(FISHUI_VERSION 1.0)
project(fishui VERSION ${FISHUI_VERSION})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Build options
option(COMPONENT_EDITOR "Build editor component" ON)
option(COMPONENT_FM "Build filemanager component" ON)
option(COMPONENT_ACCOUNTS "Build accounts component" ON)
option(COMPONENT_TERMINAL "Build terminal component" ON)
option(COMPONENT_STORE "Build store component" OFF)
option(COMPONENT_TAGGING "Build tagging component" ON)
option(COMPONENT_SYNCING "Build syncing component" ON)

# ECM + KDE6
find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

# ⚠ 删除 KDEFrameworkCompilerSettings，否则会要求 metainfo.yaml
include(KDEInstallDirs)
include(KDECMakeSettings)

include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(ECMGenerateHeaders)

# Qt6
set(QT_COMPONENTS
    Core
    Widgets
    Quick
    QuickControls2
    DBus
)

find_package(Qt6 REQUIRED COMPONENTS ${QT_COMPONENTS})

# KF6
if (UNIX AND NOT APPLE)
    find_package(KF6WindowSystem REQUIRED)
endif()

# Query QML install dir using qtpaths
execute_process(
    COMMAND qtpaths6 --install-qml
    OUTPUT_VARIABLE INSTALL_QMLDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "QML install directory: ${INSTALL_QMLDIR}")

# Install dir
set(CMAKECONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/FishUI")
message(STATUS "Install directory: ${CMAKECONFIG_INSTALL_DIR}")

add_subdirectory(src)

# Package config
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/FishUIConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/FishUIConfig.cmake"
    INSTALL_DESTINATION ${CMAKECONFIG_INSTALL_DIR}
    PATH_VARS CMAKECONFIG_INSTALL_DIR CMAKE_INSTALL_PREFIX
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/FishUIConfigVersion.cmake"
    VERSION ${FISHUI_VERSION}
    COMPATIBILITY AnyNewerVersion
)

install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/FishUIConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/FishUIConfigVersion.cmake"
    DESTINATION ${CMAKECONFIG_INSTALL_DIR}
)

install(
    EXPORT FishUITargets
    DESTINATION ${CMAKECONFIG_INSTALL_DIR}
    FILE FishUITargets.cmake
)

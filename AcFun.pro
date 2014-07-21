TEMPLATE = app
TARGET = AcFun

VERSION = 2.3.0
DEFINES += VER=\\\"$$VERSION\\\"

QT += network webkit xml
CONFIG += mobility
MOBILITY += multimedia systeminfo

RESOURCES += AcFun-res.qrc

INCLUDEPATH += src

HEADERS += \
    src/utility.h \
    src/acnetworkaccessmanagerfactory.h \
    src/customwebview.h \
    src/qnetworkrequesthelper.h

SOURCES += main.cpp \
    src/utility.cpp \
    src/acnetworkaccessmanagerfactory.cpp \
    src/customwebview.cpp \
    src/qnetworkrequesthelper.cpp

TRANSLATIONS += i18n/AcFun_zh.ts

folder_symbian3.source = qml/AcFun
folder_symbian3.target = qml

folder_harmattan.source = qml/harmattan
folder_harmattan.target = qml

folder_js.source = qml/js
folder_js.target = qml

folder_gfx.source = qml/gfx
folder_gfx.target = qml

DEPLOYMENTFOLDERS = folder_js folder_gfx

simulator {
    DEPLOYMENTFOLDERS += folder_symbian3 folder_harmattan
}

contains(MEEGO_EDITION, harmattan){
    DEFINES += Q_OS_HARMATTAN
    CONFIG += qdeclarative-boostable
    CONFIG += videosuiteinterface-maemo-meegotouch  #video suite
    CONFIG += shareuiinterface-maemo-meegotouch share-ui-plugin share-ui-common #share ui
    CONFIG += mdatauri  #mdatauri

    DEPLOYMENTFOLDERS += folder_harmattan

    splash.files = splash/splash_n9.png
    splash.path = /opt/AcFun/bin

    INSTALLS += splash
}

symbian {
    DEPLOYMENTFOLDERS += folder_symbian3

    CONFIG += qt-components
    CONFIG += localize_deployment

    TARGET.UID3 = 0x2006622C
    TARGET.CAPABILITY *= \
        NetworkServices \
        ReadUserData \
        WriteUserData \
        SwEvent
    TARGET.EPOCHEAPSIZE = 0x40000 0x4000000

    LIBS *= -lapparc -lws32 -lapgrfx

    vendorinfo = "%{\"Yeatse\"}" ":\"Yeatse\""
    my_deployment.pkg_prerules += vendorinfo
    DEPLOYMENT += my_deployment

    # Symbian have a different syntax
    DEFINES -= VER=\\\"$$VERSION\\\"
    DEFINES += VER=\"$$VERSION\"
}

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

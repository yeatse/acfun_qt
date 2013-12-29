import QtQuick 1.1

Item {
    id: root

    property bool running: true;
    visible: pageStack.currentPage.loading||false;

    implicitWidth: app.inPortrait ? screen.displayHeight : screen.displayWidth;
    implicitHeight: constant.paddingMedium;

    Rectangle {
        id: progressRect
        color: "steelblue"
        width: constant.graphicSizeSmall;
        height: constant.paddingMedium;
    }

    SequentialAnimation {
        id: loadingAnimation
        alwaysRunToEnd: true
        loops: Animation.Infinite
        running: root.running && root.visible && Qt.application.active

        PropertyAction { target: progressRect; property: "visible"; value: true }
        PropertyAction { target: progressRect; property: "x"; value: 0 }
        PropertyAnimation { target: progressRect; property: "x"; to: root.width/2; duration: 800; easing.type: Easing.InOutQuad}
        PropertyAnimation { target: progressRect; property: "x"; to: root.width; duration: 800; easing.type: Easing.InOutQuad}
        PropertyAction { target: progressRect; property: "visible"; value: false }
    }
}

import QtQuick 1.1

Item {
    id: root;

    property string title;

    implicitWidth: parent.width;
    implicitHeight: text.height + constant.paddingMedium + constant.paddingLarge;

    Text {
        id: text;
        anchors {
            left: parent.left; leftMargin: constant.paddingSmall;
            top: parent.top; topMargin: constant.paddingLarge;
        }
        font: constant.titleFont;
        color: constant.colorLight;
        text: root.title;
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
        height: 1;
        color: constant.colorDisabled;
    }
}

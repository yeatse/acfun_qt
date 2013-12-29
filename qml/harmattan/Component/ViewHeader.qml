import QtQuick 1.1

Rectangle {
    id: root;

    property alias title: text.text;

    implicitWidth: parent.width;
    implicitHeight: 72;
    color: "#f2b200";
    z: 10;

    Text {
        id: text;
        anchors {
            left: parent.left; right: parent.right;
            margins: constant.paddingLarge;
            verticalCenter: parent.verticalCenter;
        }
        font {
            family: constant.titleFont.family;
            pixelSize: constant.titleFont.pixelSize+2;
        }
        color: "#ffffff";
        style: Text.Raised;
        styleColor: "#666666";
        maximumLineCount: 2;
        elide: Text.ElideRight;
        wrapMode: Text.Wrap;
    }
}

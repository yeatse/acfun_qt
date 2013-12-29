import QtQuick 1.1

Rectangle {
    id: root;

    property alias title: text.text;

    implicitWidth: screen.width;
    implicitHeight: privateStyle.tabBarHeightPortrait;
    color: "#f2b200";
    z: 10;
    Image {
        anchors { left: parent.left; top: parent.top; }
        source: "../../gfx/meegoTLCorner.png";
    }
    Image {
        anchors { right: parent.right; top: parent.top; }
        source: "../../gfx/meegoTRCorner.png";
    }

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
        color: constant.colorLight;
        style: Text.Raised;
        styleColor: constant.colorMid;
        maximumLineCount: 2;
        elide: Text.ElideRight;
        wrapMode: Text.Wrap;
    }
}

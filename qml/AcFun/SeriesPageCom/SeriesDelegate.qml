import QtQuick 1.1

Item {
    id: root;

    implicitWidth: GridView.view.cellWidth;
    implicitHeight: GridView.view.cellHeight;

    Image {
        id: preview;
        anchors {
            left: parent.left; right: parent.right;
            top: parent.top; margins: constant.paddingSmall;
        }
        height: width*4/3;
        sourceSize.width: 120;
        source: model.cover;
        fillMode: Image.PreserveAspectFit;
    }

    Rectangle {
        anchors {
            left: preview.left; right: preview.right;
            bottom: preview.bottom;
        }
        height: platformStyle.fontSizeLarge;
        color: "#801f1f1f";
        Text {
            anchors.fill: parent;
            font { pixelSize: constant.subTitleFont.pixelSize-2; }
            color: constant.colorLight;
            text: model.subhead
            horizontalAlignment: Text.AlignRight;
            verticalAlignment: Text.AlignVCenter;
            elide: Text.ElideRight;
            wrapMode: Text.Wrap;
            maximumLineCount: 1;
            textFormat: Text.PlainText;
        }
    }

    Text {
        id: label;
        anchors {
            left: parent.left; right: parent.right;
            top: preview.bottom; bottom: parent.bottom;
        }
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        elide: Text.ElideRight;
        wrapMode: Text.Wrap;
        maximumLineCount: 1;
        textFormat: Text.PlainText;
        text: model.title;
        font: constant.subTitleFont;
        color: constant.colorLight;
    }

    Rectangle {
        anchors.fill: parent;
        color: "black";
        opacity: mouseArea.pressed ? 0.3 : 0;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: pageStack.push(Qt.resolvedUrl("SeriesDetailPage.qml"),
                                  {acId: model.id});
    }
}

import QtQuick 1.1

AbstractItem {
    id: root;
    implicitHeight: 120 + constant.paddingLarge*2;
    onClicked: signalCenter.viewDetail(model.acId);
    Image {
        id: preview;
        anchors {
            left: root.paddingItem.left;
            top: root.paddingItem.top;
            bottom: root.paddingItem.bottom;
        }
        width: 160;
        sourceSize.width: 160;
        source: model.previewurl
    }
    Text {
        anchors {
            left: preview.right; leftMargin: constant.paddingMedium;
            right: root.paddingItem.right; top: root.paddingItem.top;
        }
        elide: Text.ElideRight;
        wrapMode: Text.Wrap;
        maximumLineCount: 2;
        textFormat: Text.PlainText;
        font: constant.titleFont;
        color: constant.colorLight;
        text: model.name;
    }
    Row {
        anchors {
            left: preview.right; leftMargin: constant.paddingMedium;
            right: root.paddingItem.right; bottom: root.paddingItem.bottom;
        }
        spacing: constant.paddingSmall;
        Image {
            anchors.verticalCenter: parent.verticalCenter;
            sourceSize: Qt.size(constant.graphicSizeTiny,
                                constant.graphicSizeTiny);
            source: "../../gfx/image_upman_small.png";
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            width: parent.width / 2;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.creatorName;
            elide: Text.ElideRight;
        }
        Image {
            anchors.verticalCenter: parent.verticalCenter;
            sourceSize: Qt.size(constant.graphicSizeTiny,
                                constant.graphicSizeTiny);
            source: "../../gfx/image_watches_small.png";
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.viewernum;
            elide: Text.ElideRight;
        }
    }
}

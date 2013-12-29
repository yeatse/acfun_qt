import QtQuick 1.1
import "../Component"

AbstractItem {
    id: root;

    implicitHeight: 90 + constant.paddingLarge*2;
    onClicked: pageStack.push(Qt.resolvedUrl("SeriesDetailPage.qml"),
                              {acId: model.id});

    Image {
        id: preview;
        anchors {
            left: root.paddingItem.left;
            top: root.paddingItem.top;
            bottom: root.paddingItem.bottom;
        }
        clip: true;
        width: 120;
        sourceSize.width: 120;
        fillMode: Image.PreserveAspectCrop;
        source: model.cover;
    }
    Column {
        anchors {
            left: preview.right; leftMargin: constant.paddingMedium;
            right: root.paddingItem.right; top: root.paddingItem.top;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            wrapMode: Text.Wrap;
            maximumLineCount: 2;
            textFormat: Text.PlainText;
            font: constant.titleFont;
            color: constant.colorLight;
            text: model.title;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            wrapMode: Text.Wrap;
            maximumLineCount: 1;
            textFormat: Text.PlainText;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.intro;
        }
        Text {
            width: parent.width;
            elide: Text.ElideRight;
            textFormat: Text.PlainText;
            font: constant.subTitleFont;
            color: constant.colorMid;
            text: model.subhead
        }
    }
}

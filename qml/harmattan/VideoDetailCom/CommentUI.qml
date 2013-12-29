import QtQuick 1.1
import com.nokia.meego 1.1

Sheet {
    id: root;

    property alias text: contentArea.text;

    acceptButtonText: "发送";
    rejectButtonText: "取消";

    content: Flickable {
        id: contentFlickable;
        anchors.fill: parent;
        contentWidth: parent.width;
        contentHeight: contentArea.height + constant.paddingLarge*2;
        clip: true;
        TextArea {
            id: contentArea;
            property int minHeight: contentFlickable.height - constant.paddingLarge*2;
            anchors {
                left: parent.left; right: parent.right;
                top: parent.top;
                margins: constant.paddingLarge;
            }
            focus: true;
            textFormat: TextEdit.PlainText;
            placeholderText: "输入评论内容";
            function setHeight(){ contentArea.height = Math.max(implicitHeight, minHeight) }
            onMinHeightChanged: setHeight();
            onImplicitHeightChanged: setHeight();
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            contentArea.forceActiveFocus();
            contentArea.platformOpenSoftwareInputPanel();
        }
    }
}

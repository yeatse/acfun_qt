import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: root;

    property alias text: contentArea.text;

    titleText: "添加评论";

    buttonTexts: ["发送", "取消"];
    onButtonClicked: if (index === 0) accept();

    content: Item {
        width: parent.width;
        height: root.platformContentMaximumHeight;
        TextArea {
            id: contentArea;
            anchors { fill: parent; margins: constant.paddingLarge; }
            focus: true;
            textFormat: TextEdit.PlainText;
        }
    }

    onStatusChanged: {
        if (status === DialogStatus.Open){
            contentArea.forceActiveFocus();
            contentArea.openSoftwareInputPanel();
        }
    }
}

import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: root;
    titleText: "提醒";
    titleIcon: "../../gfx/error.svg";
    content: Item {
        width: parent.width;
        height: contentCol.height + platformStyle.paddingLarge*2;
        Column {
            id: contentCol;
            anchors {
                left: parent.left; right: parent.right;
                top: parent.top; margins: platformStyle.paddingLarge;
            }
            spacing: platformStyle.paddingMedium;
            Label {
                id: message;
                width: parent.width;
                wrapMode: Text.Wrap;
                text: "为保证视频能够正常播放，使用前请先至手机系统设置→应用程序设置→视频下设置合适的接入点。"
            }
            CheckBox {
                id: checkBox;
                text: "以后不再提示";
            }
        }
    }
    buttonTexts: ["确定"];
    onButtonClicked: accept();
    onAccepted: {
        if (checkBox.checked){
            acsettings.showFirstHelp = false;
        }
    }
    property bool __isClosing: false;
    onStatusChanged: {
        if (status == DialogStatus.Closing){
            __isClosing = true;
        } else if (status == DialogStatus.Closed && __isClosing){
            root.destroy();
        }
    }
    Component.onCompleted: open();
}

import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property int talkwith;
    onTalkwithChanged: internal.getlist();
    property string username;

    title: "与%1对话中".arg(username);

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: internal.getlist();
        }
    }

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

        function getlist(option){
            loading = true;
            var opt = { model: view.model, talkwith: talkwith };
            if (view.count === 0) option = "renew";
            option = option || "renew";
            if (option === "renew"){
                opt.renew = true;
            } else {
                opt.cursor = pageNumber * pageSize;
            }
            function s(obj){
                loading = false;
                pageNumber = obj.page;
                totalNumber = obj.totalCount;
                pageSize = obj.pageSize;
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getPrivateMsgs(opt, s, f);
        }

        function send(){
            loading = true;
            var opt = { content: textField.text, touserName: username };
            function s(){
                loading = false;
                signalCenter.showMessage("发送成功");
                textField.text = "";
                getlist();
            }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.sendPrivteMsg(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; bottomMargin: editArea.height; }
        clip: true;
        model: ListModel {}
        delegate: convDelegate;
        Component {
            id: convDelegate;
            Item {
                id: root;
                anchors.left: model.isMine ? undefined : parent.left;
                anchors.right: model.isMine ? parent.right : undefined;
                implicitWidth: ListView.view.width-constant.graphicSizeSmall;
                implicitHeight: contentCol.height+contentCol.anchors.topMargin*2;
                BorderImage {
                    id: bgImg;
                    source: model.isMine ? "../../gfx/msg_out.png" : "../../gfx/msg_in.png";
                    anchors { fill: parent; margins: constant.paddingMedium; }
                    border { left: 10; top: 10; right: 10; bottom: 15; }
                    mirror: true;
                }
                Column {
                    id: contentCol;
                    anchors {
                        left: parent.left; leftMargin: constant.paddingMedium+10;
                        right: parent.right; rightMargin: constant.paddingMedium+10;
                        top: parent.top; topMargin: constant.paddingLarge*2;
                    }
                    Text {
                        width: parent.width;
                        wrapMode: Text.Wrap;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        text: model.text;
                    }
                    Text {
                        width: parent.width;
                        horizontalAlignment: model.isMine ? Text.AlignRight : Text.AlignLeft;
                        font: constant.subTitleFont;
                        color: constant.colorLight;
                        text: utility.easyDate(model.postTime);
                    }
                }
            }
        }
    }

    Item {
        id: editArea;
        anchors {
            left: parent.left; right: parent.right;
            bottom: parent.bottom;
        }
        height: Math.max(textField.height, sendBtn.height)+constant.paddingMedium;
        TextField {
            id: textField;
            anchors {
                left: parent.left; right: sendBtn.left;
                margins: constant.paddingSmall;
                verticalCenter: parent.verticalCenter;
            }
        }
        Button {
            id: sendBtn;
            anchors { right: parent.right; verticalCenter: parent.verticalCenter; }
            iconSource: "../../gfx/send.svg";
            enabled: !loading && textField.text.length > 0;
            onClicked: internal.send();
        }
    }
}

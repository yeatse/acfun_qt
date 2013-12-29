import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: internal.getlist();
        }
        ToolIcon {
            platformIconId: internal.deleteMode ? "toolbar-done"
                                                : "toolbar-delete";
            onClicked: internal.deleteMode = !internal.deleteMode;
        }
    }

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;
        property bool deleteMode: false;

        function getlist(option){
            loading = true;
            var opt = { model: view.model };
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
        function deleteMsg(idx, mgid, p2p){
            var url = Script.AcApi.users;
            url += "/"+acsettings.userId;
            url += "/privatemsgs/"+mgid;
            url += "/"+p2p;
            url += "?access_token="+acsettings.accessToken;
            helperListener.index = idx;
            helperListener.reqUrl = url;
            networkHelper.createDeleteRequest(url);
            loading = true;
        }
    }

    Connections {
        id: helperListener;
        property string reqUrl;
        property int index;
        target: networkHelper;
        onRequestFinished: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
                view.model.remove(helperListener.index);
            }
        }
        onRequestFailed: {
            if (url.toString() === helperListener.reqUrl){
                loading = false;
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        title: page.title;
    }
    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        delegate: pmDelegate
        footer: FooterItem {
            visible: internal.pageSize * internal.pageNumber < internal.totalNumber;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
        Component {
            id: pmDelegate;
            AbstractItem {
                id: root;
                onClicked: {
                    var prop = { username: model.fromusername, talkwith: fromuId };
                    pageStack.push(Qt.resolvedUrl("ConverPage.qml"), prop);
                }
                implicitHeight: contentCol.height + constant.paddingLarge*2;
                Image {
                    id: avatar;
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                    }
                    width: constant.graphicSizeSmall;
                    height: constant.graphicSizeSmall;
                    source: model.user_img;
                }
                Column {
                    id: contentCol;
                    anchors {
                        left: avatar.right;
                        leftMargin: constant.paddingMedium;
                        right: root.paddingItem.right;
                        top: root.paddingItem.top;
                    }
                    Text {
                        width: parent.width;
                        font: constant.labelFont;
                        color: constant.colorMid;
                        elide: Text.ElideRight;
                        text: model.fromusername
                    }
                    Text {
                        width: parent.width;
                        font: constant.labelFont;
                        color: constant.colorLight;
                        elide: Text.ElideRight;
                        wrapMode: Text.Wrap;
                        maximumLineCount: 2;
                        text: model.lastMessage;
                    }
                    Text {
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: utility.easyDate(model.postTime);
                    }
                }
                Button {
                    anchors {
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    enabled: !loading;
                    platformStyle: ButtonStyle {
                        buttonWidth: buttonHeight;
                    }
                    iconSource: "image://theme/icon-m-toolbar-delete"
                    visible: internal.deleteMode;
                    onClicked: internal.deleteMsg(index, mailGroupId, p2p);
                }
            }
        }
    }
    ScrollDecorator { flickableItem: view; }
    Component.onCompleted: internal.getlist();
}

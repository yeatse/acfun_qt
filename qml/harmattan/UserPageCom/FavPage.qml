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
                pageNumber = obj.pageNo;
                totalNumber = obj.totalCount;
                pageSize = obj.pageSize;
            }
            function f(err){
                loading = false;
                signalCenter.showMessage(err);
            }
            Script.getFavVideos(opt, s, f);
        }

        function unfav(idx, acId){
            var url = Script.AcApi.users;
            url += "/"+acsettings.userId;
            url += "/fav/videos/"+acId;
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
        delegate: CommonDelegate {
            Button {
                anchors {
                    right: parent.right;
                    verticalCenter: parent.verticalCenter;
                }
                platformStyle: ButtonStyle {
                    buttonWidth: buttonHeight;
                }
                enabled: !loading;
                iconSource: "image://theme/icon-m-toolbar-delete"
                visible: internal.deleteMode;
                onClicked: internal.unfav(index, acId);
            }
        }
        footer: FooterItem {
            visible: internal.pageSize * internal.pageNumber < internal.totalNumber;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
    }
    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: internal.getlist();
}

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
    }

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

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
            Script.getUserVideos(opt, s, f);
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
        delegate: deleComp;
        footer: FooterItem {
            visible: internal.pageSize * internal.pageNumber < internal.totalNumber;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
        Component {
            id: deleComp;
            AbstractItem {
                id: root;
                enabled: model.state === "approved";
                implicitHeight: 90 + constant.paddingLarge*2;
                onClicked: signalCenter.viewDetail(model.acId);
                Image {
                    id: preview;
                    anchors {
                        left: root.paddingItem.left;
                        top: root.paddingItem.top;
                        bottom: root.paddingItem.bottom;
                    }
                    width: 120;
                    source: model.previewurl
                }
                Rectangle {
                    id: stateRect;
                    anchors.right: root.paddingItem.right;
                    anchors.verticalCenter: parent.verticalCenter;
                    height: stateLabel.height + constant.paddingMedium*2;
                    width: stateLabel.width + constant.paddingMedium*2;
                    color: "transparent";
                    border { width: 2; color: constant.colorMid; }
                    Text {
                        id: stateLabel;
                        anchors.centerIn: parent;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: {
                            switch(model.state){
                            case "approved": return " 通过 ";
                            case "untreated": return "未处理";
                            case "processing": return "处理中";
                            case "unapprove": return "未通过";
                            default: return " 未知 ";
                            }
                        }
                    }
                }
                Column {
                    anchors {
                        left: preview.right; leftMargin: constant.paddingMedium;
                        right: stateRect.left; rightMargin: constant.paddingMedium;
                        top: root.paddingItem.top;
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        textFormat: Text.PlainText;
                        font: constant.titleFont;
                        color: constant.colorLight;
                        text: model.name;
                    }
                    Text {
                        width: parent.width;
                        elide: Text.ElideRight;
                        textFormat: Text.PlainText;
                        font: constant.subTitleFont;
                        color: constant.colorMid;
                        text: model.desc;
                        maximumLineCount: 2;
                        wrapMode: Text.Wrap;
                    }
                }
            }
        }
    }
    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: internal.getlist();
}

import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

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

    Component.onCompleted: internal.getlist();

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

        property int classId: 1024;
        property bool isoriginal: false;

        function getlist(option){
            loading = true;
            var opt = {
                model: view.model,
                "class": classId,
                isoriginal: isoriginal
            };
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
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getClass(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "排名";
    }

    ButtonRow {
        id: btnRow;
        anchors { top: viewHeader.bottom; left: parent.left; right: parent.right; }
        Button {
            text: "综合";
            onClicked: {
                internal.isoriginal = false;
                internal.getlist();
            }
        }
        Button {
            text: "原创";
            onClicked: {
                internal.isoriginal = true;
                internal.getlist();
            }
        }
    }

    ListView {
        id: view;
        anchors {
            left: parent.left; right: parent.right;
            top: btnRow.bottom; bottom: parent.bottom;
        }
        clip: true;
        model: ListModel {}
        delegate: CommonDelegate {}
        footer: FooterItem {
            visible: internal.pageSize * internal.pageNumber < internal.totalNumber;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
    }
}

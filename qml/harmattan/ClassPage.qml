import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property int cid;
    property string cname;
    property variant subclass;
    onSubclassChanged: internal.loadModel();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: getlist();
        }
    }

    function getlist(){ internal.getlist(); }

    QtObject {
        id: internal;

        property int pageNumber: 1;
        property int totalNumber: 0;
        property int pageSize: 20;

        property int classId;
        property string className;

        function setClass(){
            if (subclass){
                var item = subclass[subclassSelector.selectedIndex];
                if (item){
                    classId = item.id;
                    className = item.name;
                }
            }
        }

        function loadModel(){
            var m = subclassSelector.model;
            m.clear();
            subclass.forEach(function(value){
                                 m.append({name: value.name});
                             })
            subclassSelector.selectedIndex = 0;
        }

        function getlist(option){
            loading = true;
            var opt = { model: view.model, "class": classId };
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

    SelectionDialog {
        id: subclassSelector;
        titleText: cname;
        model: ListModel {}
        onSelectedIndexChanged: internal.setClass();
        onAccepted: internal.getlist();
    }

    ViewHeader {
        id: viewheader;
        title: page.cname + "-" + internal.className;
        ToolIcon {
            anchors {
                right: parent.right; verticalCenter: parent.verticalCenter;
            }
            platformIconId: "toolbar-view-menu";
            onClicked: subclassSelector.open();
        }
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewheader.height; }
        model: ListModel {}
        delegate: CommonDelegate {}
        footer: FooterItem {
            visible: internal.pageSize * internal.pageNumber < internal.totalNumber;
            enabled: !loading;
            onClicked: internal.getlist("next");
        }
    }

    ScrollDecorator { flickableItem: view; }
}

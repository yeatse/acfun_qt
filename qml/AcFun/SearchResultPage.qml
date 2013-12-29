import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    property int orderId: 4;
    property string term;
    property int nextPage: 1;
    property bool hasNext: false;

    function getlist(option){
        loading = true;
        var opt = { orderId: orderId, term: term, model: view.model }
        if (view.count === 0||nextPage === 1) option = "renew";
        option = option || "renew";
        if (option === "renew"){
            opt.renew = true;
            nextPage = 1;
        } else {
            opt.pageNo = nextPage;
        }
        function s(obj){
            loading = false;
            if (nextPage === obj.nextPage){
                hasNext = false;
            } else {
                hasNext = true;
                nextPage = obj.nextPage;
            }
        }
        function f(err){
            loading = false;
            signalCenter.showMessage(err);
        }
        Script.getSearch(opt, s, f);
    }

    title: viewheader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
    }

    ViewHeader {
        id: viewheader;
        title: "搜索结果";
    }

    ButtonRow {
        id: buttonRow;
        anchors { left: parent.left; right: parent.right; top: viewheader.bottom; }
        enabled: !loading;
        TabButton {
            height: privateStyle.tabBarHeightLandscape
            text: "收藏数";
            onClicked: {orderId = 4;getlist();}
        }
        TabButton {
            height: privateStyle.tabBarHeightLandscape
            text: "点击数";
            onClicked: {orderId = 0;getlist();}
        }
        TabButton {
            height: privateStyle.tabBarHeightLandscape
            text: "发布时间"
            onClicked: {orderId = 2;getlist();}
        }
        TabButton {
            height: privateStyle.tabBarHeightLandscape
            text: "评论数"
            onClicked: {orderId = 3;getlist();}
        }
    }

    ListView {
        id: view;
        anchors { left: parent.left; right: parent.right; top: buttonRow.bottom; bottom: parent.bottom; }
        clip: true;
        model: ListModel {}
        delegate: CommonDelegate {}
        footer: FooterItem {
            visible: hasNext;
            enabled: !loading;
            onClicked: getlist("next");
        }
    }

    ScrollDecorator { flickableItem: view; }
}

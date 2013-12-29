import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "MainPageCom"
import "../js/main.js" as Script

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolButton {
            Timer { id: quitTimer; interval: 3000; }
            iconSource: "toolbar-back";
            onClicked: {
                if (quitTimer.running) Qt.quit();
                else { quitTimer.start(); signalCenter.showMessage("再按一次退出程序") }
            }
        }
        ToolButton {
            iconSource: "../gfx/calendar.svg";
            onClicked: pageStack.push(Qt.resolvedUrl("SeriesPage.qml"));
        }
        ToolButton {
            iconSource: "../gfx/rank.svg";
            onClicked: pageStack.push(Qt.resolvedUrl("RankingPage.qml"));
        }
        ToolButton {
            iconSource: "toolbar-menu";
            onClicked: mainMenu.open();
        }
    }

    Connections {
        target: signalCenter;
        onInitialized: {
            internal.refresh();
            if (acsettings.showFirstHelp){
                Qt.createComponent("MainPageCom/FirstStartInfo.qml").createObject(page);
            }
        }
    }

    QtObject {
        id: internal;

        function refresh(){
            Script.getVideoCategories();
            getHeader();
            getCategory();
        }

        function getHeader(){
            headerView.loading = true;
            headerView.error = false;
            var opt = {"model": headerView.model};
            function s(){ headerView.loading = false; }
            function f(err){
                headerView.loading = false;
                signalCenter.showMessage(err);
                headerView.error = true;
            }
            Script.getHomeThumbnails(opt, s, f);
        }
        function getCategory(){
            placeHolder.loading = true;
            placeHolder.error = false;
            var opt = { "model": homeModel };
            function s(){ placeHolder.loading = false; }
            function f(err){
                placeHolder.loading = false;
                signalCenter.showMessage(err);
                placeHolder.error = true;
            }
            Script.getHomeCategroies(opt, s, f);
        }

        function enterClass(id){
            for (var i in signalCenter.videocategories){
                var v = signalCenter.videocategories[i];
                if (id === v.id){
                    var prop = { cid: id, cname: v.name, subclass: v.subclasse };
                    var p = pageStack.push(Qt.resolvedUrl("ClassPage.qml"), prop);
                    p.getlist();
                    break;
                }
            }
        }
    }

    Menu {
        id: mainMenu;
        MenuLayout {
            MenuItem {
                text: "关于";
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"));
            }
            MenuItem {
                text: "个人中心";
                onClicked: {
                    if (Script.checkAuthData()){
                        var prop = { uid: acsettings.userId }
                        pageStack.push(Qt.resolvedUrl("UserPage.qml"), prop);
                    }
                }
            }
            MenuItem {
                text: "里区入口~";
                onClicked: {
                    var p = pageStack.push(Qt.resolvedUrl("SeriesPageCom/WikiPage.qml"));
                    p.load();
                }
            }
        }
    }

    ViewHeader {
        id: viewHeader;
        Image {
            anchors.centerIn: parent;
            sourceSize.height: parent.height - constant.paddingMedium*2;
            source: "../gfx/image_logo.png";
        }
        ToolButton {
            anchors {
                right: parent.right; verticalCenter: parent.verticalCenter;
            }
            iconSource: "toolbar-search";
            onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
        }
    }

    Flickable {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        contentWidth: view.width;
        contentHeight: contentCol.height;
        Column {
            id: contentCol;
            anchors { left: parent.left; right: parent.right; }
            PullToActivate {
                myView: view;
                enabled: !busyInd.visible;
                onRefresh: internal.refresh();
            }
            HeaderView {
                id: headerView;
                onRefresh: {
                    Script.getVideoCategories();
                    internal.getHeader();
                }
            }
            Repeater {
                model: ListModel { id: homeModel; }
                HomeRow {}
            }
            Item {
                id: placeHolder;
                property bool loading: false;
                property bool error: false;
                anchors { left: parent.left; right: parent.right; }
                height: view.height - headerView.height;
                visible: homeModel.count === 0;
                Button {
                    width: height;
                    anchors.centerIn: parent;
                    iconSource: privateStyle.toolBarIconPath("toolbar-refresh");
                    visible: placeHolder.error;
                    onClicked: {
                        Script.getVideoCategories();
                        internal.getCategory();
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: busyInd;
        anchors.centerIn: parent;
        running: true;
        width: constant.graphicSizeLarge;
        height: constant.graphicSizeLarge;
        visible: placeHolder.loading || headerView.loading;
    }

    ScrollDecorator { flickableItem: view; }
}

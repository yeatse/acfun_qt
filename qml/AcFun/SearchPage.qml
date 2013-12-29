import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "../js/main.js" as Script

MyPage {
    id: page;

    title: "搜索";

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active){
            searchInput.forceActiveFocus();
            searchInput.openSoftwareInputPanel();
            getlist();
        }
    }

    function getlist(){
        loading = true;
        function s(){ loading = false; }
        function f(err){ loading = false; signalCenter.showMessage(err); }
        Script.getHotkeys(view.model, s, f);
    }

    ViewHeader {
        id: viewHeader;

        SearchInput {
            id: searchInput;
            anchors {
                left: parent.left; right: searchBtn.left;
                margins: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
        }

        Button {
            id: searchBtn;
            anchors {
                right: parent.right; rightMargin: constant.paddingMedium;
                verticalCenter: parent.verticalCenter;
            }
            text: "搜索";
            platformInverted: true;
            onClicked: {
                if (searchInput.text.length === 0) return;
                var prop = { term: searchInput.text };
                var page = pageStack.push(Qt.resolvedUrl("SearchResultPage.qml"), prop);
                page.getlist();
            }
        }
    }

    ListView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        delegate: AbstractItem {
            Text {
                anchors { left: parent.paddingItem.left; verticalCenter: parent.verticalCenter; }
                font: constant.titleFont;
                color: constant.colorLight;
                text: model.name;
            }
            onClicked: {
                searchInput.text = model.name;
                searchBtn.clicked();
            }
        }
    }
}

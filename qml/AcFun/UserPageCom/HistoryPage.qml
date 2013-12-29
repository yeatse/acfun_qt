import QtQuick 1.1
import com.nokia.symbian 1.1
import "../Component"
import "../../js/database.js" as Database

MyPage {
    id: page;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: Database.loadHistory(view.model);
        }
        ToolButton {
            iconSource: "toolbar-delete";
            onClicked: {
                var s = function(){
                    Database.clearHistory();
                    view.model.clear();
                }
                signalCenter.createQueryDialog("警告",
                                               "确定要清空历史记录？",
                                               "确定",
                                               "取消",
                                               s);
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
        delegate: CommonDelegate {}
    }

    ScrollDecorator { flickableItem: view; }

    Component.onCompleted: Database.loadHistory(view.model);
}

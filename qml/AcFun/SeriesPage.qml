import QtQuick 1.1
import com.nokia.symbian 1.1
import "Component"
import "SeriesPageCom" as Series
import "../js/main.js" as Script

MyPage {
    id: page;

    property int channelId: 1;
    Component.onCompleted: getlist();

    title: viewHeader.title;

    tools: ToolBarLayout {
        ToolButton {
            iconSource: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolButton {
            iconSource: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolButton {
            iconSource: flip.side === Flipable.Front
                        ? "toolbar-list" : "../gfx/grid.svg";
            onClicked: flip.state = flip.state === "" ? "back" : "";
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "追剧"
    }

    ButtonRow {
        id: buttonRow;
        anchors { left: parent.left; right: parent.right; top: viewHeader.bottom }
        TabButton {
            text: "动画"
            height: privateStyle.tabBarHeightLandscape;
            onClicked: refresh(1);
        }
        TabButton {
            text: "剧集"
            height: privateStyle.tabBarHeightLandscape;
            onClicked: refresh(3);
        }
        TabButton {
            text: "综艺"
            height: privateStyle.tabBarHeightLandscape;
            onClicked: refresh(4);
        }
    }

    function refresh(cid){
        if (channelId !== cid){
            channelId = cid;
            getlist();
        }
    }

    function getlist(){
        scroller.listView = null;
        loading = true;
        var opt = {
            channelId: channelId,
            model: seriesModel
        };
        function s(){
            loading = false;
            if (utility.qtVersion > 0x040800){
                scroller.listView = listView;
            }
        }
        function f(err){
            loading = false;
            signalCenter.showMessage(err);
        }
        Script.getPlaybill(opt, s, f);
    }

    ListModel { id: seriesModel; }

    Flipable {
        id: flip;
        anchors {
            left: parent.left; right: parent.right;
            top: buttonRow.bottom; bottom: parent.bottom;
        }
        front: GridView {
            id: gridView;
            clip: true;
            anchors.fill: parent;
            cellWidth: app.inPortrait ? width/3 : width/5;
            cellHeight: cellWidth/3*4+constant.paddingLarge;
            model: seriesModel;
            delegate: Series.SeriesDelegate {}
        }
        back: ListView {
            id: listView;
            clip: true;
            anchors.fill: parent;
            model: seriesModel;
            delegate: Series.SeriesDelegateL {}
            section.property: "day";
            section.delegate: ListHeading {
                ListItemText {
                    anchors.fill: parent.paddingItem;
                    role: "Heading";
                    text: section;
                }
            }
        }
        transform: Rotation {
            id: rotation;
            origin: Qt.vector3d(flip.width/2, flip.height/2, 0);
            axis: Qt.vector3d(0, 1, 0);
            angle: 0;
        }
        states: State {
            name: "back";
            PropertyChanges {
                target: rotation;
                angle: 180;
            }
        }
        transitions: Transition {
            RotationAnimation {
                direction: RotationAnimation.Clockwise;
            }
        }
    }

    ScrollDecorator {
        flickableItem: gridView;
        visible: flip.side === Flipable.Front;
    }
    SectionScroller {
        id: scroller;
        listView: null;
        visible: flip.side === Flipable.Back;
    }
}

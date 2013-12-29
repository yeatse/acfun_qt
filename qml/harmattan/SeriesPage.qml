import QtQuick 1.1
import com.nokia.meego 1.1
import "Component"
import "SeriesPageCom" as Series
import "../js/main.js" as Script

MyPage {
    id: page;

    property int channelId: 1;
    Component.onCompleted: getlist();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
        ToolIcon {
            platformIconId: "toolbar-refresh";
            onClicked: getlist();
        }
        ToolIcon {
            platformIconId: flip.side === Flipable.Front
                            ? "toolbar-list" : "toolbar-grid";
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
        Button {
            text: "动画"
            onClicked: refresh(1);
        }
        Button {
            text: "剧集"
            onClicked: refresh(3);
        }
        Button {
            text: "综艺"
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
        loading = true;
        var opt = {
            channelId: channelId,
            model: seriesModel
        };
        function s(){
            loading = false;
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
            id: listV;
            clip: true;
            anchors.fill: parent;
            model: seriesModel;
            delegate: Series.SeriesDelegateL {}
            section.property: "day";
            section.delegate: SectionHeader {
                title: section;
            }
            FastScroll {
                listView: listV;
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
}

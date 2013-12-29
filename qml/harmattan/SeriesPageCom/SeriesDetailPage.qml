import QtQuick 1.1
import com.nokia.meego 1.1
import "../Component"
import "../../js/main.js" as Script

MyPage {
    id: page;

    property string acId;
    onAcIdChanged: internal.getlist();

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back";
            onClicked: pageStack.pop();
        }
    }

    QtObject {
        id: internal;

        property string name;
        property string previewurl;
        property string desc;
        property string username;

        function getlist(){
            loading = true;
            var opt = {model: view.model, acId: acId};
            function s(obj){
                loading = false;
                previewurl = obj.previewurl;
                name = obj.name;
                desc = obj.desc;
                username = obj.user.name;
            }
            function f(err){ loading = false; signalCenter.showMessage(err); }
            Script.getSeriesEpisodes(opt, s, f);
        }
    }

    ViewHeader {
        id: viewHeader;
        title: "剧集详细";
    }

    GridView {
        id: view;
        anchors { fill: parent; topMargin: viewHeader.height; }
        model: ListModel {}
        cellWidth: app.inPortrait ? width / 3 : width / 5;
        cellHeight: cellWidth + constant.graphicSizeSmall;
        header: episodeHeaderComp;
        delegate: episodeDelegateComp;
    }

    Component {
        id: episodeHeaderComp;
        Column {
            id: headerCol;
            width: GridView.view.width;
            Image {
                anchors { left: parent.left; right: parent.right; }
                height: 150;
                source: internal.previewurl;
                fillMode: Image.PreserveAspectCrop;
                smooth: true;
                clip: true;
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; }
                    height: constant.graphicSizeSmall;
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: "#A0000000" }
                    }
                    Text {
                        anchors { fill: parent; margins: constant.paddingLarge; }
                        horizontalAlignment: Text.AlignLeft;
                        verticalAlignment: Text.AlignVCenter;
                        elide: Text.ElideRight;
                        text: internal.name;
                        font: constant.titleFont;
                        color: constant.colorLight;
                    }
                }
            }
            Row {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                height: constant.graphicSizeSmall;
                spacing: constant.paddingMedium;
                Image {
                    anchors.verticalCenter: parent.verticalCenter;
                    sourceSize: Qt.size(constant.graphicSizeTiny,
                                        constant.graphicSizeTiny);
                    source: "../../gfx/image_upman_small.png";
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter;
                    font: constant.subTitleFont;
                    color: constant.colorMid;
                    text: internal.username;
                }
            }
            Text {
                anchors { left: parent.left; right: parent.right; margins: constant.paddingMedium; }
                wrapMode: Text.Wrap;
                font: constant.subTitleFont;
                color: constant.colorMid;
                text: internal.desc;
            }
            SectionHeader {
                title: "剧集列表"
            }
        }
    }

    Component {
        id: episodeDelegateComp;
        Item {
            id: episodeDelegate;
            implicitWidth: GridView.view.cellWidth;
            implicitHeight: GridView.view.cellHeight;
            Image {
                id: preview;
                anchors {
                    left: parent.left; top: parent.top;
                    right: parent.right; margins: constant.paddingSmall;
                }
                clip: true;
                height: width;
                sourceSize.width: width;
                fillMode: Image.PreserveAspectCrop;
                source: model.previewurl;
            }
            Text {
                anchors {
                    left: parent.left; right: parent.right;
                    top: preview.bottom; bottom: parent.bottom;
                }
                horizontalAlignment: Text.AlignHCenter;
                verticalAlignment: Text.AlignVCenter;
                font: constant.labelFont;
                color: constant.colorLight;
                text: model.subhead;
            }
            Rectangle {
                anchors.fill: parent;
                color: "black";
                opacity: mouseArea.pressed ? 0.3 : 0;
            }
            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                onClicked: signalCenter.viewDetail(model.contentId);
            }
        }
    }
}
